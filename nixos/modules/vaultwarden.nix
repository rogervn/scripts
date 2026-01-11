{config, ...}: let
  httpPort = 8002;
in {
  # 1. Define the secret file
  age.secrets.vaultwarden-secrets = {
    file = ./secrets/vaultwarden-secrets.age;
    owner = "vaultwarden"; # Crucial so the service can read it
  };

  # 2. Configure the service
  services.vaultwarden = {
    enable = true;

    environmentFile = config.age.secrets.vaultwarden-secrets.path;

    config = {
      SIGNUPS_ALLOWED = false;
      ROCKET_WORKERS = 4;

      PUSH_ENABLED = true;
      PUSH_RELAY_BASE_URI = "https://push.bitwarden.com";

      ROCKET_PORT = httpPort;
      # most configs are in secrets environment
    };
  };

  networking.firewall.allowedTCPPorts = [httpPort];
}
