# This is today just an rsync from a borg repo, which is not advised.
# Hopefully with borg2 it will be able to move to synced-repos.
# This does requires private-key ssh login to be set on the base repo server
# and passwordless sudo both on source and destination to backup root files.
{ config, lib, pkgs, userName, ... }:
let
  borgrepo_unit = "borgrepo_sync";
  cfg = config.services.borgrepoSync;
in {
  options.services.borgrepoSync = {
    baseRepoLocation = lib.mkOption {
      type = lib.types.str;
      default = "truenas.localdomain:/mnt/zfspool/backup/borgrepo/";
      description = "SSH remote borg repo source (user@host:/path)";
    };
    backupRepoLocation = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/external/backup/borgrepo";
      description = "Local destination path for synced borg repo";
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
        --rsync-path="sudo rsync" \
        ${userName}@${cfg.baseRepoLocation} ${cfg.backupRepoLocation}
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
