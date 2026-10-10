{
  config,
  lib,
  hostName,
  ...
}:
let
  registry = import ./service-registry.nix;
  localUrl = name: registry.services.${name}.hosts.getSingleHost.localUrl;
  publicUrl = name: registry.services.${name}.publicUrl;
  cfg = config.myServices.homepage;

  groupedServices = lib.groupBy (entry: entry.group) cfg.entries;
  homepageServices = lib.mapAttrsToList (group: entries: {
    "${group}" = map (entry: {
      "${entry.name}" = {
        inherit (entry) href description icon;
      }
      // lib.optionalAttrs (entry.id != null) {
        inherit (entry) id;
      }
      // lib.optionalAttrs (entry.siteMonitor != null) {
        inherit (entry) siteMonitor;
      }
      // lib.optionalAttrs (entry.widget != { }) {
        inherit (entry) widget;
      };
    }) entries;
  }) groupedServices;

  # Beszel system path IDs, used for the host monitoring cards.
  beszelSystems = {
    kirby = "umkfo0xzaq4gnz1";
    mog = "2larn2dhp2cztxn";
    pikachu = "a7iab7men2vm49v";
  };

  mkServerCard = name: systemPath: {
    group = "Servers";
    inherit name;
    id = "beszel-server-${name}";
    href = "${localUrl "beszel"}/system/${systemPath}";
    description = "Host monitoring for ${name}";
    icon = "mdi-server";
    widget = {
      type = "beszel";
      url = localUrl "beszel";
      username = "{{HOMEPAGE_VAR_BESZEL_USERNAME}}";
      password = "{{HOMEPAGE_VAR_BESZEL_PASSWORD}}";
      version = 2;
      systemId = name;
      fields = [
        "name"
        "cpu"
        "memory"
        "disk"
      ];
    };
  };

  mkAdguardCard = host: {
    group = "Infrastructure";
    name = "AdGuard Home (${host.name})";
    href = host.localUrl;
    description = "DNS and network-wide ad blocking";
    icon = "adguard-home";
    siteMonitor = host.localUrl;
    # This widget is intentionally unauthenticated because AdGuard currently has no configured users.
    widget = {
      type = "adguard";
      url = host.localUrl;
      fields = [
        "queries"
        "blocked"
        "filtered"
        "latency"
      ];
    };
  };

  serverSelector =
    suffix:
    lib.concatMapStringsSep ",\n" (name: ''li.service[data-name="${name}"] ${suffix}'') (
      lib.attrNames beszelSystems
    );
in
{
  options.myServices.homepage = {
    enable = lib.mkEnableOption "Homepage Dashboard";

    listenPort = lib.mkOption {
      type = lib.types.port;
      default = registry.services.homepage.port;
      description = "Port on which Homepage Dashboard listens.";
    };

    allowedHosts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default =
        map (host: "${host}:${toString cfg.listenPort}") [
          "${config.networking.hostName}.localdomain"
          config.networking.hostName
          "localhost"
          "127.0.0.1"
        ]
        # Proxied by nginx on 443, so no port in the Host header
        ++ [ registry.services.homepage.domain ];
      description = "Hostnames allowed to access Homepage Dashboard.";
    };

    entries = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            group = lib.mkOption { type = lib.types.str; };
            name = lib.mkOption { type = lib.types.str; };
            id = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
            };
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
      myServices.homepage.entries = lib.mkAfter (
        map mkAdguardCard registry.services.adguardhome.hosts.getHosts
        ++ [
          {
            group = "Infrastructure";
            name = "Uptime Kuma";
            href = localUrl "uptimekuma";
            description = "Service uptime monitoring";
            icon = "uptime-kuma";
            siteMonitor = localUrl "uptimekuma";
            widget = {
              type = "uptimekuma";
              url = localUrl "uptimekuma";
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
            href = publicUrl "vaultwarden";
            description = "Bitwarden-compatible password manager";
            icon = "vaultwarden";
            siteMonitor = localUrl "vaultwarden";
          }
          {
            group = "Applications";
            name = "Home Assistant";
            href = localUrl "homeassistant";
            description = "Home automation control and monitoring";
            icon = "home-assistant";
            siteMonitor = localUrl "homeassistant";
          }

          # Widget credentials belong in the agenix-managed Homepage env file.
          # kirby
          {
            group = "Applications";
            name = "Nextcloud";
            href = publicUrl "nextcloud";
            description = "File sync and collaboration";
            icon = "nextcloud";
            siteMonitor = localUrl "nextcloud";
            widget = {
              type = "nextcloud";
              url = publicUrl "nextcloud";
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
            href = publicUrl "immich";
            description = "Photo and video library";
            icon = "immich";
            siteMonitor = localUrl "immich";
            widget = {
              type = "immich";
              url = publicUrl "immich";
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
            href = publicUrl "authentik";
            description = "Identity provider and single sign-on";
            icon = "authentik";
            siteMonitor = localUrl "authentik";
          }
          {
            group = "Applications";
            name = "Paperless-ngx";
            href = publicUrl "paperless";
            description = "Document management and OCR";
            icon = "paperless-ngx";
            siteMonitor = localUrl "paperless";
          }
          {
            group = "Infrastructure";
            name = "Beszel";
            href = localUrl "beszel";
            description = "Lightweight server monitoring";
            icon = "beszel";
            siteMonitor = localUrl "beszel";
            # Beszel widget credentials require a superuser account.
            widget = {
              type = "beszel";
              url = localUrl "beszel";
              username = "{{HOMEPAGE_VAR_BESZEL_USERNAME}}";
              password = "{{HOMEPAGE_VAR_BESZEL_PASSWORD}}";
              version = 2;
              fields = [
                "systems"
                "up"
              ];
            };
          }
        ]
        ++ lib.mapAttrsToList mkServerCard beszelSystems
      );
    }

    (lib.mkIf cfg.enable {
      assertions = [ (registry.services.homepage.hosts.assertOn hostName) ];

      services.homepage-dashboard = {
        enable = true;
        inherit (cfg) listenPort;
        # Credential values are supplied through the agenix-managed env file.
        environmentFiles = [ config.age.secrets.homepage_env_file.path ];
        allowedHosts = lib.concatStringsSep "," cfg.allowedHosts;
        services = homepageServices;
        widgets = [
          {
            openmeteo = {
              label = "London";
              latitude = 51.5074;
              longitude = -0.1278;
              timezone = "Europe/London";
              units = "metric";
              cache = 5;
              format.maximumFractionDigits = 1;
            };
          }
        ];
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

          ${serverSelector ".service-card"} {
            align-items: stretch;
            display: flex;
          }

          ${serverSelector ".service-title"} {
            flex: 0 0 3rem;
          }

          ${serverSelector ".service-icon"} {
            width: 100%;
          }

          ${serverSelector ".service-title-text"} {
            display: none;
          }

          ${serverSelector ".service-card > :not(.service-title)"} {
            flex: 1 1 0%;
            min-width: 0;
          }

        '';
        settings = {
          layout = {
            Servers = {
              columns = 1;
            };
          };
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

      systemd.services.homepage-dashboard.environment.HOMEPAGE_PROXY_DISABLE_IPV6 = "true";

      networking.firewall.allowedTCPPorts = [ cfg.listenPort ];
    })
  ];
}
