{
  config,
  lib,
  pkgs,
  hostName,
  ...
}:
let
  registry = import ./service-registry.nix { inherit pkgs; };
  httpPort = registry.services.vaultwarden.port;
  backupDir = "/var/backup/vaultwarden";
in
{
  services.vaultwarden = {
    enable = true;
    inherit backupDir;

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

  assertions = [ (registry.services.vaultwarden.hosts.assertOn hostName) ];

  myServices.resticBackup.paths = lib.mkAfter [ backupDir ];

  systemd.tmpfiles.rules = [
    "d ${backupDir} 0700 vaultwarden vaultwarden -"
  ];
  networking.firewall.allowedTCPPorts = [ httpPort ];
}
