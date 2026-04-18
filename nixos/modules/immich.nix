let
  httpPort = 8009;
in {
  services.immich = {
    enable = true;
    port = httpPort;
    host = "0.0.0.0";
    mediaLocation = "/data/apps/immich";
    # database.createLocally and redis.createLocally default to true
    # machine-learning.enable defaults to true
  };

  networking.firewall.allowedTCPPorts = [httpPort];
}
