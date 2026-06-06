{ config, lib, ... }:
let
  httpPort = 8011;
  httpsPort = 8012;
  inherit (config.myServices) smtp;
in
{
  imports = [ ./smtp.nix ];

  services.authentik = {
    enable = true;
    environmentFile = config.age.secrets.authentik_env_file.path;
    settings = {
      listen = {
        http = [ "0.0.0.0:${toString httpPort}" ];
        https = [ "0.0.0.0:${toString httpsPort}" ];
      };
      email = {
        host = if smtp.enable then smtp.host else "smtp-relay.brevo.com";
        port = if smtp.enable then smtp.port else 587;
        use_tls = if smtp.enable then smtp.startTls else true;
        use_ssl = if smtp.enable then !smtp.startTls else true;
        timeout = 10;
        from = "authentik-admin@vnunes.win";
      };
      disable_startup_analytics = true;
    };
  };
  myServices.resticBackup.postgresqlBackup.databases = lib.mkAfter [ "authentik" ];
  myServices.resticBackup.paths = lib.mkAfter [ "/var/lib/authentik" ];

  networking.firewall.allowedTCPPorts = [
    httpPort
    httpsPort
  ];
}
