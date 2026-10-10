{
  config,
  lib,
  options,
  hostName,
  ...
}:
let
  registry = import ./service-registry.nix;
  hubCfg = config.myServices.beszelHub;
  agentCfg = config.myServices.beszelAgent;
  hubDataDirOverridden = hubCfg.dataDir != "/var/lib/beszel-hub";
in
{
  options.myServices = {
    beszelHub = {
      enable = lib.mkEnableOption "beszel hub";

      dataDir = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/beszel-hub";
        example = "/data/apps/beszel";
        description = "Data directory of beszel-hub.";
      };
    };

    beszelAgent = {
      enable = lib.mkEnableOption "beszel agent";

      hubUrl = lib.mkOption {
        type = lib.types.str;
        default = registry.services.beszel.hosts.getSingleHost.localUrl;
        description = "URL of the beszel hub this agent registers with";
      };

      keySecretPath = lib.mkOption {
        type = lib.types.str;
        description = "Path to a file containing the hub's public SSH key (from age.secrets.*.path)";
      };

      tokenSecretPath = lib.mkOption {
        type = lib.types.str;
        description = "Path to a file containing the hub's universal registration token (from age.secrets.*.path)";
      };

      smartmon = lib.mkEnableOption "S.M.A.R.T. disk monitoring (per-drive health and temperature)";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf hubCfg.enable (
      {
        assertions = [ (registry.services.beszel.hosts.assertOn hostName) ];
        services.beszel.hub = {
          enable = true;
          host = "0.0.0.0";
          inherit (registry.services.beszel) port;
          inherit (hubCfg) dataDir;
        };
        networking.firewall.allowedTCPPorts = [ config.services.beszel.hub.port ];
      }
      # Only back up the data dir on hosts that import restic-backup.nix
      // lib.optionalAttrs (options.myServices ? resticBackup) {
        myServices.resticBackup.paths = lib.mkAfter [ hubCfg.dataDir ];
      }
    ))

    # Upstream module derives StateDirectory from baseNameOf dataDir, which only
    # resolves correctly when dataDir lives under /var/lib. Only when dataDir is
    # overridden away from that default do we need a static user + tmpfiles rule
    # instead of DynamicUser/StateDirectory, so the service actually reads/writes
    # dataDir. Otherwise leave the upstream module's default behaviour untouched.
    (lib.mkIf (hubCfg.enable && hubDataDirOverridden) {
      # Pinned so a reinstall keeps ownership of dataDir
      users.users.beszel-hub = {
        uid = 996;
        isSystemUser = true;
        group = "beszel-hub";
      };
      users.groups.beszel-hub.gid = 996;
      systemd.tmpfiles.rules = [
        "d ${hubCfg.dataDir} 0750 beszel-hub beszel-hub -"
      ];
      systemd.services.beszel-hub.serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = lib.mkForce "beszel-hub";
        StateDirectory = lib.mkForce "";
        RuntimeDirectory = lib.mkForce "";
      };
    })

    (lib.mkIf agentCfg.enable {
      services.beszel.agent = {
        enable = true;
        openFirewall = true;
        environment = {
          HUB_URL = agentCfg.hubUrl;
          KEY_FILE = agentCfg.keySecretPath;
          TOKEN_FILE = agentCfg.tokenSecretPath;
        };
        smartmon = lib.mkIf agentCfg.smartmon {
          enable = true;
          # Needed when a host restricts the agent's DeviceAllow (e.g. kirby for /dev/zfs)
          deviceAllow = [
            "char-nvme"
            "block-blkext"
            "block-sd"
          ];
        };
      };
    })
  ];
}
