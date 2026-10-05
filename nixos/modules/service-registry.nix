# Plain data shared across flakes: where each service runs and its public name.
rec {
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
      port = 443;
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

  localUrl = name: "http://${services.${name}.host}:${toString services.${name}.port}";

  # Fails the build when a service is deployed somewhere the registry doesn't say
  hostAssertion = hostName: name: {
    assertion = "${hostName}.localdomain" == services.${name}.host;
    message = "${name} is registered on ${services.${name}.host} in service-registry.nix, not ${hostName}";
  };
}
