{
  config,
  lib,
  pkgs,
  hostName,
  ...
}:
let
  cfg = config.myServices.resticBackup;
  pgCfg = cfg.postgresqlBackup;
  repoSyncCfg = config.myServices.repoSync;
  repoSyncB2Cfg = config.myServices.repoSyncB2;
in
{
  options.myServices = {
    resticBackup = {
      enable = lib.mkEnableOption "restic backup";

      repository = lib.mkOption {
        type = lib.types.str;
        description = "Restic repository — local path or sftp:// URI";
      };

      passwordSecretPath = lib.mkOption {
        type = lib.types.str;
        description = "Path to the restic password file (from age.secrets.*.path)";
      };

      initialize = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };

      paths = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Paths to include in backups; app modules append here";
      };

      exclude = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Paths to exclude; app modules append here";
      };

      timerConfig = lib.mkOption {
        type = lib.types.attrs;
        default = {
          OnCalendar = "daily";
          Persistent = true;
        };
      };

      pruneOpts = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "--keep-daily 7"
          "--keep-weekly 4"
          "--keep-monthly 12"
        ];
      };

      extraOptions = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };

      postgresqlBackup = {
        enable = lib.mkEnableOption "PostgreSQL dump sub-feature";

        location = lib.mkOption {
          type = lib.types.str;
          default = "/var/backup/postgresql";
        };

        startAt = lib.mkOption {
          type = lib.types.str;
          default = "*-*-* 01:00:00";
        };

        compression = lib.mkOption {
          type = lib.types.str;
          default = "gzip";
        };

        databases = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Databases to dump; app modules append here";
        };
      };
    };

    repoSync = {
      enable = lib.mkEnableOption "rsync-based repository sync";

      source = lib.mkOption {
        type = lib.types.str;
        default = "backupuser@datanixos.localdomain:/data/backup/restic/";
        description = "rsync source — SSH remote (user@host:/path) or local path";
      };

      destination = lib.mkOption {
        type = lib.types.str;
        default = "/mnt/external/backup/datanixos";
        description = "Local destination path";
      };

      sshKeyPath = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Path to SSH private key; null for local rsync (no SSH)";
      };

      timerConfig = lib.mkOption {
        type = lib.types.attrs;
        default = {
          OnCalendar = "Sat *-*-* 04:00:00";
          Persistent = true;
        };
      };
    };

    repoSyncB2 = {
      enable = lib.mkEnableOption "rclone Backblaze B2 sync";

      sourceDir = lib.mkOption {
        type = lib.types.str;
        default = "/data/backup";
      };

      environmentSecretPath = lib.mkOption {
        type = lib.types.str;
        description = "Path to env file with B2_ACCOUNT_ID, B2_APPLICATION_KEY, B2_BUCKET";
      };

      timerConfig = lib.mkOption {
        type = lib.types.attrs;
        default = {
          OnCalendar = "Sat *-*-* 04:00:00";
          Persistent = true;
        };
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      services.postgresqlBackup = lib.mkIf pgCfg.enable {
        inherit (pgCfg) location;
        inherit (pgCfg) startAt;
        inherit (pgCfg) compression;
        inherit (pgCfg) databases;
      };

      services.restic.backups.${hostName} = {
        inherit (cfg) repository;
        passwordFile = cfg.passwordSecretPath;
        inherit (cfg) initialize;
        paths = (lib.optional pgCfg.enable pgCfg.location) ++ cfg.paths;
        inherit (cfg) exclude;
        inherit (cfg) timerConfig;
        inherit (cfg) pruneOpts;
        inherit (cfg) extraOptions;
      };

      systemd.services."restic-backups-${hostName}" = lib.mkIf pgCfg.enable {
        wants = lib.mkAfter (map (db: "postgresqlBackup-${db}.service") pgCfg.databases);
        after = lib.mkAfter (map (db: "postgresqlBackup-${db}.service") pgCfg.databases);
      };
    })

    (lib.mkIf repoSyncCfg.enable {
      systemd = {
        services.repo-sync = {
          description = "Rsync ${repoSyncCfg.source} to ${repoSyncCfg.destination}";
          after = lib.optionals (repoSyncCfg.sshKeyPath != null) [
            "network-online.target"
            "nss-lookup.target"
          ];
          wants = lib.optionals (repoSyncCfg.sshKeyPath != null) [
            "network-online.target"
            "nss-lookup.target"
          ];
          serviceConfig.Type = "oneshot";
          script = ''
            ${pkgs.rsync}/bin/rsync -avz --delete \
              ${lib.optionalString (repoSyncCfg.sshKeyPath != null)
                ''-e "${pkgs.openssh}/bin/ssh -i ${repoSyncCfg.sshKeyPath} -o StrictHostKeyChecking=accept-new" \''
              }
              ${repoSyncCfg.source} ${repoSyncCfg.destination}
          '';
        };
        timers.repo-sync = {
          wantedBy = [ "timers.target" ];
          inherit (repoSyncCfg) timerConfig;
        };
      };
    })

    (lib.mkIf repoSyncB2Cfg.enable {
      systemd = {
        services."${hostName}-rclone-b2" = {
          description = "Sync ${repoSyncB2Cfg.sourceDir} to Backblaze B2";
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          serviceConfig = {
            Type = "oneshot";
            EnvironmentFile = repoSyncB2Cfg.environmentSecretPath;
          };
          script = ''
            ${pkgs.rclone}/bin/rclone sync \
              --config /dev/null \
              --b2-account "''${B2_ACCOUNT_ID}" \
              --b2-key    "''${B2_APPLICATION_KEY}" \
              ${repoSyncB2Cfg.sourceDir}/ \
              :b2:''${B2_BUCKET}/${hostName}/
          '';
        };
        timers."${hostName}-rclone-b2" = {
          wantedBy = [ "timers.target" ];
          inherit (repoSyncB2Cfg) timerConfig;
        };
      };
    })
  ];
}
