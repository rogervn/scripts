{
  config,
  pkgs,
  hostName,
  ...
}: let
  port = 8008;
  externalUrl = "nextcloud.vnunes.win";
in {
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud33;

    hostName = externalUrl;
    home = "/data/apps/nextcloud";
    https = false; # reverse proxy handles TLS

    database.createLocally = true; # PostgreSQL via Unix socket, no password needed

    configureRedis = true; # auto-wires Redis memcache + file locking

    config = {
      adminuser = "admin";
      adminpassFile = config.age.secrets.nextcloud_admin_pass.path;
      dbtype = "pgsql";
    };

    extraApps = {
      inherit (pkgs.nextcloud33.packages.apps) user_oidc;
    };
    extraAppsEnable = true;

    settings = {
      trusted_domains = [hostName externalUrl];
      default_phone_region = "GB";
      maintenance_window_start = 2;
      overwriteprotocol = "https";
    };

    phpOptions = {
      "opcache.memory_consumption" = "256";
      "opcache.max_accelerated_files" = "20000";
      "opcache.interned_strings_buffer" = "16";
    };
  };

  # Override nginx vhost to listen on port 8008 instead of default 80/443
  services.nginx.virtualHosts.${externalUrl} = {
    forceSSL = false;
    listen = [
      {
        addr = "0.0.0.0";
        port = port;
        ssl = false;
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [port];
}
