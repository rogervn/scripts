{ config, lib, ... }:
let
  cfg = config.myServices.homepage;

  groupedServices = lib.groupBy (entry: entry.group) cfg.entries;
  homepageServices = lib.mapAttrsToList (group: entries: {
    "${group}" = map (entry: {
      "${entry.name}" = {
        inherit (entry) href description icon;
      }
      // lib.optionalAttrs (entry.siteMonitor != null) {
        inherit (entry) siteMonitor;
      }
      // lib.optionalAttrs (entry.widget != { }) {
        inherit (entry) widget;
      };
    }) entries;
  }) groupedServices;
in
{
  options.myServices.homepage = {
    enable = lib.mkEnableOption "Homepage Dashboard";

    listenPort = lib.mkOption {
      type = lib.types.port;
      default = 8016;
      description = "Port on which Homepage Dashboard listens.";
    };

    allowedHosts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = map (host: "${host}:${toString cfg.listenPort}") [
        "mininixos.localdomain"
        "mininixos"
        "localhost"
        "127.0.0.1"
      ];
      description = "Hostnames allowed to access Homepage Dashboard.";
    };

    entries = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            group = lib.mkOption { type = lib.types.str; };
            name = lib.mkOption { type = lib.types.str; };
            href = lib.mkOption { type = lib.types.str; };
            description = lib.mkOption { type = lib.types.str; };
            icon = lib.mkOption { type = lib.types.str; };
            siteMonitor = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
            };
            widget = lib.mkOption {
              type = lib.types.attrs;
              default = { };
            };
          };
        }
      );
      default = [ ];
      description = "Service cards shown in Homepage Dashboard.";
    };
  };

  config = lib.mkMerge [
    {
      myServices.homepage.entries = lib.mkAfter [
        # mininixos
        {
          group = "Infrastructure";
          name = "AdGuard Home";
          href = "http://mininixos.localdomain:8001";
          description = "DNS and network-wide ad blocking";
          icon = "adguard-home";
          siteMonitor = "http://mininixos.localdomain:8001";
          # This widget is intentionally unauthenticated because AdGuard currently has no configured users.
          widget = {
            type = "adguard";
            url = "http://127.0.0.1:8001";
            fields = [
              "queries"
              "blocked"
              "filtered"
              "latency"
            ];
          };
        }
        {
          group = "Infrastructure";
          name = "Uptime Kuma";
          href = "http://mininixos.localdomain:8003";
          description = "Service uptime monitoring";
          icon = "uptime-kuma";
          widget = {
            type = "uptimekuma";
            url = "http://127.0.0.1:8003";
            slug = "home-services";
            fields = [
              "up"
              "down"
              "uptime"
              "incident"
            ];
          };
        }
        {
          group = "Applications";
          name = "Vaultwarden";
          href = "https://vaultwarden.vnunes.win";
          description = "Bitwarden-compatible password manager";
          icon = "vaultwarden";
          siteMonitor = "http://mininixos.localdomain:8002";
        }
        {
          group = "Applications";
          name = "Home Assistant";
          href = "http://10.0.0.15:8005";
          description = "Home automation control and monitoring";
          icon = "home-assistant";
        }

        # Widget credentials belong in the agenix-managed Homepage env file.
        # datanixos
        {
          group = "Applications";
          name = "Nextcloud";
          href = "https://nextcloud.vnunes.win";
          description = "File sync and collaboration";
          icon = "nextcloud";
          siteMonitor = "http://datanixos.localdomain:8008";
          widget = {
            type = "nextcloud";
            url = "https://nextcloud.vnunes.win";
            username = "admin";
            password = "{{HOMEPAGE_VAR_NEXTCLOUD_TOKEN}}";
            fields = [
              "freespace"
              "activeusers"
              "numfiles"
              "numshares"
            ];
          };
        }
        {
          group = "Applications";
          name = "Immich";
          href = "https://immich.vnunes.win";
          description = "Photo and video library";
          icon = "immich";
          siteMonitor = "http://datanixos.localdomain:8009";
          widget = {
            type = "immich";
            url = "https://immich.vnunes.win";
            key = "{{HOMEPAGE_VAR_IMMICH_TOKEN}}";
            version = 2;
            fields = [
              "users"
              "photos"
              "videos"
              "storage"
            ];
          };
        }
        {
          group = "Applications";
          name = "Authentik";
          href = "https://authentik.vnunes.win";
          description = "Identity provider and single sign-on";
          icon = "authentik";
          siteMonitor = "http://datanixos.localdomain:8011";
        }
        {
          group = "Applications";
          name = "Paperless-ngx";
          href = "https://paperless.vnunes.win";
          description = "Document management and OCR";
          icon = "paperless-ngx";
          siteMonitor = "http://datanixos.localdomain:8015";
        }
        {
          group = "Infrastructure";
          name = "Beszel";
          href = "http://datanixos.localdomain:8017";
          description = "Lightweight server monitoring";
          icon = "beszel";
          siteMonitor = "http://datanixos.localdomain:8017";
          # Beszel widget credentials require a superuser account.
          widget = {
            type = "beszel";
            url = "http://datanixos.localdomain:8017";
            username = "{{HOMEPAGE_VAR_BESZEL_USERNAME}}";
            password = "{{HOMEPAGE_VAR_BESZEL_PASSWORD}}";
            version = 2;
            fields = [
              "systems"
              "up"
            ];
          };
        }
      ];
    }

    (lib.mkIf cfg.enable {
      services.homepage-dashboard = {
        enable = true;
        inherit (cfg) listenPort;
        # Credential values are supplied through the agenix-managed env file.
        environmentFiles = [ config.age.secrets.homepage_env_file.path ];
        allowedHosts = lib.concatStringsSep "," cfg.allowedHosts;
        services = homepageServices;
        customCSS = ''
          html,
          body,
          #__next {
            min-height: 100%;
            background-color: #11161d;
            background-image:
              linear-gradient(rgba(2, 6, 23, 0.72), rgba(2, 6, 23, 0.72)),
              url("https://images.unsplash.com/photo-1502790671504-542ad42d5189?auto=format&fit=crop&w=2560&q=80");
            background-attachment: fixed;
            background-position: center;
            background-repeat: no-repeat;
            background-size: cover;
            color: #e2e8f0;
          }

          main,
          .bg-background,
          .bg-slate-900,
          .bg-slate-950 {
            background: transparent !important;
          }

          .service-card {
            background-color: rgba(30, 41, 59, 0.88);
            border: 1px solid rgba(148, 163, 184, 0.18);
            box-shadow: none;
          }

          .service-card:hover,
          .service-card:focus-within {
            border-color: rgba(148, 163, 184, 0.4);
            transform: translateY(-1px);
          }

          h2 {
            color: #cbd5e1;
            letter-spacing: 0.02em;
          }
        '';
        settings = {
          title = "Home Services";
          theme = "dark";
          color = "slate";
          headerStyle = "clean";
          cardBlur = "sm";
          statusStyle = "dot";
          useEqualHeights = true;
          disableCollapse = true;
          hideVersion = true;
        };
      };

      networking.firewall.allowedTCPPorts = [ cfg.listenPort ];
    })
  ];
}
