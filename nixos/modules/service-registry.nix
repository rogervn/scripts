# Plain data shared across flakes: where each service runs and its public name.
let
  hosts = {
    "homeassistant.localdomain" = "10.0.0.15";
    "kirby.localdomain" = "10.0.0.16";
    "mog.localdomain" = "10.0.0.14";
    "pikachu.localdomain" = "10.0.0.12";
  };

  services = {
    # Also runs on every other DNS host; this is the instance others link to
    adguardhome = {
      host = "mog.localdomain";
      port = 8001;
    };
    authentik = {
      host = "kirby.localdomain";
      port = 8011;
      domain = "authentik.vnunes.win";
    };
    beszel = {
      host = "kirby.localdomain";
      port = 8017;
    };
    # Not deployed from this repo
    homeassistant = {
      host = "homeassistant.localdomain";
      port = 8005;
    };
    homepage = {
      host = "pikachu.localdomain";
      port = 8016;
      # Not on Cloudflare, so it only resolves through the local AdGuard
      domain = "homepage.vnunes.win";
    };
    immich = {
      host = "kirby.localdomain";
      port = 8009;
      domain = "immich.vnunes.win";
    };
    joplin = {
      host = "kirby.localdomain";
      port = 8014;
      domain = "joplin.vnunes.win";
    };
    # HTTPS for the public domains on the LAN
    nginx = {
      host = "mog.localdomain";
      # Default site, redirects to the homepage
      port = 80;
    };
    nextcloud = {
      host = "kirby.localdomain";
      port = 8008;
      domain = "nextcloud.vnunes.win";
    };
    paperless = {
      host = "kirby.localdomain";
      port = 8015;
      domain = "paperless.vnunes.win";
    };
    uptimekuma = {
      host = "pikachu.localdomain";
      port = 8003;
    };
    vaultwarden = {
      host = "mog.localdomain";
      port = 8002;
      domain = "vaultwarden.vnunes.win";
    };
  };

  missing = builtins.filter (n: !(hosts ? ${services.${n}.host})) (builtins.attrNames services);
in
assert
  missing == [ ]
  || throw "service-registry.nix: no hosts entry for the host of: ${builtins.concatStringsSep ", " missing}";
{
  inherit hosts services;

  # Lets DNS rewrites and proxy trust lists work without resolving .localdomain
  hostIp = name: hosts.${services.${name}.host};

  localUrl = name: "http://${services.${name}.host}:${toString services.${name}.port}";

  publicUrl = name: "https://${services.${name}.domain}";

  # Fails the build when a service is deployed somewhere the registry doesn't say
  hostAssertion = hostName: name: {
    assertion = "${hostName}.localdomain" == services.${name}.host;
    message = "${name} is registered on ${services.${name}.host} in service-registry.nix, not ${hostName}";
  };
}
