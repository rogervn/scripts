{
  config,
  lib,
  pkgs,
  userName,
  hostName,
  nixvim,
  agenixPackage,
  ...
}:
let
  pgBackupDir = "/data/backup/postgresql";
  resticRepo = "/data/backup/restic";
  serversDir = "/data/backup/servers";
  smbUsers = [
    "homeassistant"
    "rogervn"
  ];
in
{
  imports = [
    ../../modules/base.nix
    ../../modules/secrets-datauser.nix
    ../../modules/smtp.nix
    ../../modules/zfs.nix
    ../../modules/authentik.nix
    ../../modules/immich.nix
    ../../modules/paperlessngx.nix
    ../../modules/joplin_server.nix
    ../../modules/nextcloud.nix
    ../../modules/restic-backup.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit nixvim; };
  };

  environment.systemPackages = [ agenixPackage ];

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [ "https://nix-community.cachix.org" ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-users = [ userName ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };
  nixpkgs.config.allowUnfree = true;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  time.timeZone = "Europe/London";

  hardware.enableAllFirmware = true;

  networking = {
    inherit hostName;
    hostId = "1933ff80";
    useNetworkd = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        139
        445
        2049
      ]; # SSH, SMB, NFS
      allowedUDPPorts = [
        137
        138
      ]; # SMB discovery (NetBIOS)
    };
  };

  users = {
    users = {
      ${userName} = {
        isNormalUser = true;
        hashedPasswordFile = config.age.secrets."${userName}_pass_hash".path;
        extraGroups = [
          "wheel"
          "disk"
        ];
      };
      # backupuser — mininixos SFTP-pushes here; backupbox rsync-pulls restic/
      backupuser = {
        isSystemUser = true;
        group = "backupuser";
        home = serversDir;
        shell = pkgs.bash;
      };
    }
    // lib.genAttrs smbUsers (_: {
      isSystemUser = true;
      group = "nogroup";
    });
    groups.backupuser = { };
  };

  age = {
    secrets."${userName}_private_key" = {
      path = "/home/${userName}/.ssh/id_ed25519";
      owner = userName;
      mode = "600";
    };
    secrets."${userName}_authorized_keys" = {
      path = "/home/${userName}/.ssh/authorized_keys";
      owner = userName;
      mode = "600";
    };
  };

  systemd.tmpfiles.rules = [
    "d ${pgBackupDir}          0700 postgres   postgres   -"
    "d ${resticRepo}           0750 backupuser backupuser -"
    "d ${serversDir}           0750 backupuser backupuser -"
    "d ${serversDir}/mininixos 0750 backupuser backupuser -"
  ];

  # restic runs as root and hardcodes 0700 on all repo dirs, ignoring umask.
  # Fix ownership and group-read after each run so backupuser can rsync-pull.
  systemd.services."restic-backups-datanixos".postStart = ''
    chown -R root:backupuser ${resticRepo}
    chmod -R g+rX ${resticRepo}
  '';

  services = {
    # NFS server
    nfs.server = {
      enable = true;
      exports = ''
        /data/share/nfs 10.0.0.0/24(rw,sync,no_subtree_check,no_root_squash)
      '';
    };
    # Samba
    samba = {
      enable = true;
      settings = {
        global = {
          workgroup = "WORKGROUP";
          "server string" = "datanixos";
          "server role" = "standalone server";
          security = "user";
        };
        share = {
          path = "/data/share/smb";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          # After adding a new user to smbUsers and rebuilding, run:
          #   sudo smbpasswd -a <username>
          "valid users" = lib.concatStringsSep " " ([ userName ] ++ smbUsers);
          "create mask" = "0644";
          "directory mask" = "0755";
        };
      };
    };
    samba-wsdd.enable = true; # Windows/macOS network discovery
  };

  myServices = {
    smtp = {
      enable = true;
      host = "smtp-relay.brevo.com";
      port = 587;
      startTls = true;
      user = "piuk-admin@vnunes.win";
      from = "datanixos@vnunes.win";
      passwordSecretPath = config.age.secrets.smtp_password.path;
      recipient = "admin@vnunes.win";
    };
    zfsZed.enableMail = true;
    resticBackup = {
      enable = true;
      repository = resticRepo;
      passwordSecretPath = config.age.secrets.datanixos_restic_pass.path;
      paths = [ "/data/share" ];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 3"
      ];
      timerConfig = {
        OnCalendar = "*-*-* 02:00:00";
        Persistent = true;
      };
      postgresqlBackup = {
        enable = true;
        location = pgBackupDir;
        startAt = "*-*-* 01:00:00";
      };
    };
    repoSyncB2 = {
      enable = true;
      environmentSecretPath = config.age.secrets.datanixos_rclone_env.path;
    };
  };

  system.stateVersion = "26.05";
}
