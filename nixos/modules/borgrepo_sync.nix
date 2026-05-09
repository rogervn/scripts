# Rsync backup from datanixos /data/backup/ to local external drive.
# Requires private-key SSH login to datanixos as datauser, and passwordless
# sudo for rsync on datanixos.
{ config, lib, pkgs, userName, ... }:
let
  borgrepo_unit = "borgrepo_sync";
  cfg = config.services.borgrepoSync;
in {
  options.services.borgrepoSync = {
    baseRepoLocation = lib.mkOption {
      type = lib.types.str;
      default = "backupuser@datanixos.localdomain:/data/backup/restic/";
      description = "SSH remote source in user@host:/path format";
    };
    backupRepoLocation = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/external/backup/datanixos";
      description = "Local destination path for synced backup";
    };
  };

  config = {
    environment.systemPackages = with pkgs; [
      rsync
    ];
    security.sudo.extraRules = [
      {
        users = ["${userName}"];
        commands = [
          {
            command = "/run/current-system/sw/bin/rsync";
            options = ["NOPASSWD"];
          }
          {
            command = "/run/current-system/sw/bin/poweroff";
            options = ["NOPASSWD"];
          }
        ];
      }
    ];

    systemd.timers."${borgrepo_unit}" = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "Sat *-*-* 4:00:00";
        Persistent = true;
        Unit = "${borgrepo_unit}.service";
      };
    };

    systemd.services."${borgrepo_unit}" = {
      script = ''
        ${pkgs.rsync}/bin/rsync \
        -avz \
        --delete \
        -e "${pkgs.openssh}/bin/ssh -i /home/${userName}/.ssh/id_ed25519 -o StrictHostKeyChecking=accept-new" \
        ${cfg.baseRepoLocation} ${cfg.backupRepoLocation}
      '';

      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };

      # Wait for both network AND the resolver to be ready
      after = [ "network-online.target" "nss-lookup.target" ];
      wants = [ "network-online.target" "nss-lookup.target" ];
    };
  };
}
