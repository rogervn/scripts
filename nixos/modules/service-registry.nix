# Plain data shared across flakes: where each service runs and its public name.
let
  domain = "localdomain";

  mkMachine = name: ip: {
    inherit name ip;
    fqdn = "${name}.${domain}";
  };

  machines = builtins.mapAttrs mkMachine {
    homeassistant = "10.0.0.15";
    kirby = "10.0.0.16";
    mog = "10.0.0.14";
    pikachu = "10.0.0.12";
  };

  rawServices = with machines; {
    adguardhome = {
      hosts = [
        mog
        pikachu
      ];
      port = 8001;
    };
    authentik = {
      hosts = [ kirby ];
      port = 8011;
      domain = "authentik.vnunes.win";
    };
    beszel = {
      hosts = [ kirby ];
      port = 8017;
    };
    # Not deployed from this repo
    homeassistant = {
      hosts = [ homeassistant ];
      port = 8005;
    };
    homepage = {
      hosts = [ pikachu ];
      port = 8016;
      # Not on Cloudflare, so it only resolves through the local AdGuard
      domain = "homepage.vnunes.win";
    };
    immich = {
      hosts = [ kirby ];
      port = 8009;
      domain = "immich.vnunes.win";
    };
    joplin = {
      hosts = [ kirby ];
      port = 8014;
      domain = "joplin.vnunes.win";
    };
    # HTTPS for the public domains on the LAN
    nginx = {
      hosts = [ mog ];
      # Default site, redirects to the homepage
      port = 80;
    };
    nextcloud = {
      hosts = [ kirby ];
      port = 8008;
      domain = "nextcloud.vnunes.win";
    };
    paperless = {
      hosts = [ kirby ];
      port = 8015;
      domain = "paperless.vnunes.win";
    };
    uptimekuma = {
      hosts = [ pikachu ];
      port = 8003;
    };
    vaultwarden = {
      hosts = [ mog ];
      port = 8002;
      domain = "vaultwarden.vnunes.win";
    };
  };

  mkService =
    name: svc:
    let
      entries = map (m: m // { localUrl = "http://${m.fqdn}:${toString svc.port}"; }) svc.hosts;
      count = builtins.length entries;
    in
    svc
    // {
      hosts = {
        getHosts = entries;
        getSingleHost =
          if count == 1 then
            builtins.head entries
          else
            throw "service-registry.nix: ${name} runs on ${toString count} hosts, use hosts.getHosts";
        # Fails the build when a service is deployed somewhere the registry doesn't say
        assertOn = hostName: {
          assertion = builtins.any (h: h.name == hostName) entries;
          message = "${name} is not registered on ${hostName} in service-registry.nix";
        };
      };
    }
    // (if svc ? domain then { publicUrl = "https://${svc.domain}"; } else { });
in
{
  inherit machines;
  services = builtins.mapAttrs mkService rawServices;
}
