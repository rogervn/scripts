{config, ...}: let
  httpPort = 8011;
  httpsPort = 8012;
in {
  services.authentik = {
    enable = true;
    environmentFile = config.age.secrets.authentik_env_file.path;
    settings = {
      listen = {
        http = "0.0.0.0:${toString httpPort}";
        https = "0.0.0.0:${toString httpsPort}";
      };
      email = {
        host = "smtp-relay.brevo.com";
        port = 587;
        use_tls = true;
        use_ssl = true;
        timeout = 10;
        from = "authentik-admin@vnunes.win";
      };
      disable_startup_analytics = true;
    };
  };
  networking.firewall.allowedTCPPorts = [httpPort httpsPort];
}
