# Plain data shared across flakes: where each service runs and its public name.
rec {
  services = {
    authentik = {
      host = "kirby";
      port = 8011;
      domain = "authentik.vnunes.win";
    };
    immich = {
      host = "kirby";
      port = 8009;
      domain = "immich.vnunes.win";
    };
    joplin = {
      host = "kirby";
      port = 8014;
      domain = "joplin.vnunes.win";
    };
    nextcloud = {
      host = "kirby";
      port = 8008;
      domain = "nextcloud.vnunes.win";
    };
    paperless = {
      host = "kirby";
      port = 8015;
      domain = "paperless.vnunes.win";
    };
    vaultwarden = {
      host = "mog";
      port = 8002;
      domain = "vaultwarden.vnunes.win";
    };
  };

  # Fails the build when a service is deployed somewhere the registry doesn't say
  hostAssertion = hostName: name: {
    assertion = hostName == services.${name}.host;
    message = "${name} is registered on ${services.${name}.host} in service-registry.nix, not ${hostName}";
  };
}
