{
  config,
  lib,
  hostName,
  ...
}:
let
  cfg = config.myServices.nginx;
  registry = import ./service-registry.nix;
  certName = "vnunes.win";
  publicServices = lib.filterAttrs (_: svc: svc ? domain) registry.services;
in
{
  options.myServices.nginx = {
    enable = lib.mkEnableOption "LAN HTTPS reverse proxy for the public service domains";

    cloudflareTokenFile = lib.mkOption {
      type = lib.types.str;
      description = "Path to a Cloudflare API token with Zone:DNS:Edit on ${certName} (from age.secrets.*.path)";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [ (registry.hostAssertion hostName "nginx") ];

    security.acme = {
      acceptTerms = true;
      certs.${certName} = {
        domain = "*.${certName}";
        # DNS-01 so the host never has to be reachable from the internet
        dnsProvider = "cloudflare";
        # Public resolver so local AdGuard rewrites can't affect the propagation check
        dnsResolver = "1.1.1.1:53";
        credentialFiles.CF_DNS_API_TOKEN_FILE = cfg.cloudflareTokenFile;
        group = config.services.nginx.group;
      };
    };

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      # Immich and Nextcloud uploads
      clientMaxBodySize = "0";
      virtualHosts = lib.mapAttrs' (
        name: svc:
        lib.nameValuePair svc.domain {
          useACMEHost = certName;
          forceSSL = true;
          locations."/" = {
            proxyPass = registry.localUrl name;
            proxyWebsockets = true;
            extraConfig = ''
              proxy_request_buffering off;
              proxy_read_timeout 600s;
              proxy_send_timeout 600s;
            '';
          };
        }
      ) publicServices
      // {
        ${registry.services.nginx.host} = {
          default = true;
          locations."/".return = "301 https://${registry.services.homepage.domain}";
        };
      };
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
  };
}
