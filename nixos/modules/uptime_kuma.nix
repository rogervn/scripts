{ pkgs, hostName, ... }:
let
  registry = import ./service-registry.nix { inherit pkgs; };
  httpPort = registry.services.uptimekuma.port;
in
{
  assertions = [ (registry.services.uptimekuma.hosts.assertOn hostName) ];

  services.uptime-kuma = {
    enable = true;
    settings = {
      HOST = "0.0.0.0";
      PORT = toString httpPort;
    };
  };
  networking.firewall.allowedTCPPorts = [ httpPort ];
}
