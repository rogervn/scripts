{config, ...}: {
  services.tailscale = {
    enable = true;
    port = 41641;
    authKeyFile = config.age.secrets.tailscale_auth_key.path;
    useRoutingFeatures = "server";
    extraUpFlags = [
      "--accept-routes"
      "--advertise-exit-node"
      "--advertise-tags=tag:server"
      "--advertise-routes=10.0.0.0/24"
    ];
  };
  networking.firewall.allowedUDPPorts = [41641];
}
