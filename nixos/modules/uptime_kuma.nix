{ hostName, ... }:
let
  registry = import ./service-registry.nix;
  httpPort = registry.services.uptimekuma.port;
in
{
  assertions = [ (registry.hostAssertion hostName "uptimekuma") ];

  services.uptime-kuma = {
    enable = true;
    settings = {
      HOST = "0.0.0.0";
      PORT = toString httpPort;
    };
  };
  networking.firewall.allowedTCPPorts = [ httpPort ];
}
