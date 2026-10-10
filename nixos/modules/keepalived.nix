{
  config,
  lib,
  pkgs,
  hostName,
  ...
}:
let
  cfg = config.myServices.keepalived;
  registry = import ./service-registry.nix { inherit pkgs; };
  enabledServices = lib.filterAttrs (_: svc: svc.enable) cfg.services;

  mkInstance =
    name:
    let
      svc = registry.services.${name};
      hosts = svc.hosts.getHosts;
      isMaster = (builtins.head hosts).name == hostName;
    in
    {
      inherit (cfg) interface;
      state = if isMaster then "MASTER" else "BACKUP";
      priority = if isMaster then 150 else 100;
      # Unique per VIP on the LAN, so reuse its last octet
      virtualRouterId = lib.toInt (lib.last (lib.splitString "." svc.vip));
      unicastSrcIp = registry.machines.${hostName}.ip;
      unicastPeers = map (h: h.ip) (builtins.filter (h: h.name != hostName) hosts);
      virtualIps = [ { addr = "${svc.vip}/24"; } ];
      trackScripts = [ name ];
    };
in
{
  options.myServices.keepalived = {
    interface = lib.mkOption {
      type = lib.types.str;
      description = "LAN interface that holds the VIPs";
    };

    services = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options.enable = lib.mkEnableOption "this host's part in the service's VIP";
        }
      );
      default = { };
      description = "Registry services whose vip this host takes part in";
    };
  };

  config = lib.mkIf (enabledServices != { }) {
    assertions = lib.mapAttrsToList (
      name: _: registry.services.${name}.hosts.assertOn hostName
    ) enabledServices;

    services.keepalived = {
      enable = true;
      openFirewall = true;
      # Scripts run as nobody from read-only store paths
      enableScriptSecurity = true;
      vrrpScripts = lib.mapAttrs (name: _: {
        script = registry.services.${name}.check;
        # Module defaults to keepalived_script but never creates it
        user = "nobody";
        interval = 2;
        timeout = 3;
        fall = 2;
        rise = 2;
        # Master drops to 90, below the backup's 100
        weight = -60;
      }) enabledServices;
      vrrpInstances = lib.mapAttrs (name: _: mkInstance name) enabledServices;
    };
  };
}
