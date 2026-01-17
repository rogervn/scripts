{
  config,
  hostName,
  ...
}: let
  backupDir = "/var/backup";
  backupUser = "backupuser";
  remoteBackupServer = "truenas.localdomain";
  remoteBackupDir = "/mnt/zfspool/backup/${hostName}";
in {
  services.restic.backups."${hostName}" = {
    paths = [backupDir];
    repository = "sftp://${backupUser}@${remoteBackupServer}:${remoteBackupDir}";
    initialize = true;
    passwordFile = config.age.secrets.mininixos_backup_restic_pass.path;
    timerConfig = {
      OnCalendar = "daily";
      RandomizedDelaySec = "1h";
    };
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 12"
    ];
  };
}
