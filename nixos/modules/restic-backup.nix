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
  b2Cfg = cfg.rcloneB2;
in
{
  options.myServices.resticBackup = {
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

    rcloneB2 = {
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

  config = lib.mkIf cfg.enable {
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

    systemd = {
      services = {
        "restic-backups-${hostName}" = lib.mkIf pgCfg.enable {
          wants = lib.mkAfter (map (db: "postgresqlBackup-${db}.service") pgCfg.databases);
          after = lib.mkAfter (map (db: "postgresqlBackup-${db}.service") pgCfg.databases);
        };
        "${hostName}-rclone-b2" = lib.mkIf b2Cfg.enable {
          description = "Sync ${b2Cfg.sourceDir} to Backblaze B2";
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          serviceConfig = {
            Type = "oneshot";
            EnvironmentFile = b2Cfg.environmentSecretPath;
          };
          script = ''
            ${pkgs.rclone}/bin/rclone sync \
              --config /dev/null \
              --b2-account "''${B2_ACCOUNT_ID}" \
              --b2-key    "''${B2_APPLICATION_KEY}" \
              ${b2Cfg.sourceDir}/ \
              b2:''${B2_BUCKET}/${hostName}/
          '';
        };
      };
      timers."${hostName}-rclone-b2" = lib.mkIf b2Cfg.enable {
        wantedBy = [ "timers.target" ];
        inherit (b2Cfg) timerConfig;
      };
    };
  };
}
