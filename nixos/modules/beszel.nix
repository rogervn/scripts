{ config, lib, ... }:
let
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
        description = "URL of the beszel hub this agent registers with";
        example = "http://datanixos.localdomain:8017";
      };

      keySecretPath = lib.mkOption {
        type = lib.types.str;
        description = "Path to a file containing the hub's public SSH key (from age.secrets.*.path)";
      };

      tokenSecretPath = lib.mkOption {
        type = lib.types.str;
        description = "Path to a file containing the hub's universal registration token (from age.secrets.*.path)";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf hubCfg.enable {
      services.beszel.hub = {
        enable = true;
        host = "0.0.0.0";
        port = 8017;
        dataDir = hubCfg.dataDir;
      };
      networking.firewall.allowedTCPPorts = [ config.services.beszel.hub.port ];
      myServices.resticBackup.paths = lib.mkAfter [ hubCfg.dataDir ];
    })

    # Upstream module derives StateDirectory from baseNameOf dataDir, which only
    # resolves correctly when dataDir lives under /var/lib. Only when dataDir is
    # overridden away from that default do we need a static user + tmpfiles rule
    # instead of DynamicUser/StateDirectory, so the service actually reads/writes
    # dataDir. Otherwise leave the upstream module's default behaviour untouched.
    (lib.mkIf (hubCfg.enable && hubDataDirOverridden) {
      users.users.beszel-hub = {
        isSystemUser = true;
        group = "beszel-hub";
      };
      users.groups.beszel-hub = { };
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
      };
    })
  ];
}
