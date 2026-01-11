let
  httpPort = 8003;
in {
  services.uptime-kuma = {
    enable = true;
    settings = {
      HOST = "0.0.0.0";
      PORT = toString httpPort;
    };
  };
  networking.firewall.allowedTCPPorts = [httpPort];
}
