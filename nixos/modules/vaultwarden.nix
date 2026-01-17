{config, ...}: let
  httpPort = 8002;
  backupDir = "/var/backup/vaultwarden";
in {
  services.vaultwarden = {
    enable = true;
    backupDir = backupDir;

    environmentFile = config.age.secrets.vaultwarden_env_file.path;

    config = {
      SIGNUPS_ALLOWED = false;
      ROCKET_WORKERS = 4;

      PUSH_ENABLED = true;
      PUSH_RELAY_BASE_URI = "https://push.bitwarden.com";

      ROCKET_ADDRESS = "0.0.0.0";
      ROCKET_PORT = httpPort;
      # most configs are in secrets environment
    };
  };

  systemd.tmpfiles.rules = [
    "d ${backupDir} 0700 vaultwarden vaultwarden -"
  ];
  networking.firewall.allowedTCPPorts = [httpPort];
}
