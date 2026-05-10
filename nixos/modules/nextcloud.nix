{
  config,
  lib,
  pkgs,
  hostName,
  ...
}:
let
  port = 8008;
  externalUrl = "nextcloud.vnunes.win";
in
{
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
      inherit (pkgs.nextcloud33.packages.apps) user_oidc gpoddersync news;
    };
    extraAppsEnable = true;

    settings = {
      trusted_domains = [
        hostName
        externalUrl
      ];
      default_phone_region = "GB";
      maintenance_window_start = 2;
      overwriteprotocol = "https";
      trusted_proxies = [ "127.0.0.1" "::1" ];
    };

    phpOptions = {
      "opcache.memory_consumption" = "256";
      "opcache.max_accelerated_files" = "20000";
      "opcache.interned_strings_buffer" = "16";
    };
  };

  services.nextcloud.notify_push = {
    enable = true;
    nextcloudUrl = "http://127.0.0.1:${toString port}";
  };

  # Override nginx vhost to listen on port 8008 instead of default 80/443
  services.nginx.virtualHosts.${externalUrl} = {
    forceSSL = false;
    listen = [
      {
        addr = "0.0.0.0";
        inherit port;
        ssl = false;
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [ port ];

  myServices.resticBackup = {
    postgresqlBackup.databases = lib.mkAfter [ "nextcloud" ];
    paths = lib.mkAfter [ config.services.nextcloud.home ];
    exclude = lib.mkAfter [ "${config.services.nextcloud.home}/.opcache" ];
  };

  systemd.services."nextcloud-maintenance-mode" = {
    description = "Nextcloud maintenance mode for DB backup";
    before = [ "postgresqlBackup-nextcloud.service" ];
    wantedBy = [ "postgresqlBackup-nextcloud.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${config.services.nextcloud.occ}/bin/nextcloud-occ maintenance:mode --on";
      ExecStop = "${config.services.nextcloud.occ}/bin/nextcloud-occ maintenance:mode --off";
      User = "nextcloud";
    };
  };
  systemd.services."postgresqlBackup-nextcloud" = {
    after = lib.mkAfter [ "nextcloud-maintenance-mode.service" ];
    requires = lib.mkAfter [ "nextcloud-maintenance-mode.service" ];
  };
}
