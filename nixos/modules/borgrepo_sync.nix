# This is today just an rsync from a borg repo, which is not advised.
# Hopefully with borg2 it will be able to move to synced-repos.
# This does requires private-key ssh login to be set on the base repo server
# and passwordless sudo both on source and destination to backup root files.
{
  pkgs,
  userName,
  ...
}: let
  borgrepo_unit = "borgrepo_sync";
  baserepo_location = "truenas.localdomain:/mnt/zfspool/backup/borgrepo/";
  backuprepo_location = "/mnt/external/backup/borgrepo";
in {
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
      ${userName}@${baserepo_location} ${backuprepo_location}
    '';

    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
