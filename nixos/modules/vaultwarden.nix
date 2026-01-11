{config, ...}: let
  httpPort = 8002;
in {
  services.vaultwarden = {
    enable = true;

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

  networking.firewall.allowedTCPPorts = [httpPort];
}
