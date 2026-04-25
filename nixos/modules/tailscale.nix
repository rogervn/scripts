{config, ...}: {
  services.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscale_auth_key.path;
    useRoutingFeatures = "both"; # enables IP forwarding + loose rp_filter
    extraUpFlags = [
      "--accept-routes"
      "--advertise-exit-node"
      "--advertise-tags=tag:server"
      "--advertise-routes=10.0.0.0/24"
    ];
  };
}
