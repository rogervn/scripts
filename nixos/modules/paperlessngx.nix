{ config, ... }: let
  httpPort = 8015;
  dataDir = "/data/apps/paperlessngx";
in {
  services.redis.servers.paperless = {
    enable = true;
    port = 0; # Unix socket only — no TCP exposure
  };

  services.paperless = {
    enable = true;
    address = "0.0.0.0";
    port = httpPort;
    dataDir = dataDir;
    environmentFile = config.age.secrets.paperlessngx_env_file.path;
    settings = {
      PAPERLESS_URL = "https://paperless.vnunes.win";
      PAPERLESS_TIME_ZONE = "Europe/London";
      PAPERLESS_OCR_LANGUAGE = "eng";
      PAPERLESS_ADMIN_USER = "admin";
      PAPERLESS_EMAIL_HOST = "smtp-relay.brevo.com";
      PAPERLESS_EMAIL_PORT = 587;
      PAPERLESS_EMAIL_USE_TLS = true;
      PAPERLESS_EMAIL_FROM = "paperlessngx@vnunes.win";
      PAPERLESS_REDIS = "unix:///run/redis-paperless/redis.sock";
      PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
      PAPERLESS_SOCIAL_AUTO_SIGNUP = true;
      PAPERLESS_SOCIALACCOUNT_ALLOW_SIGNUPS = true;
      PAPERLESS_ACCOUNT_ALLOW_SIGNUPS = false;
    };
  };

  networking.firewall.allowedTCPPorts = [ httpPort ];
}
