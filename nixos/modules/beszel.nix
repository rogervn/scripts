{ config, lib, ... }:
let
  hubCfg = config.myServices.beszelHub;
  agentCfg = config.myServices.beszelAgent;
in
{
  options.myServices = {
    beszelHub = {
      enable = lib.mkEnableOption "beszel hub";
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
      };
      networking.firewall.allowedTCPPorts = [ config.services.beszel.hub.port ];
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
