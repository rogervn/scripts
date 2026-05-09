{ config, lib, ... }:
let
  cfg = config.myServices.smtp;
in {
  options.myServices.smtp = {
    enable = lib.mkEnableOption "shared SMTP (msmtp + sendmail for system mail/ZED)";
    host = lib.mkOption { type = lib.types.str; };
    port = lib.mkOption { type = lib.types.port; default = 587; };
    startTls = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "STARTTLS on port 587. Set false for implicit TLS (port 465).";
    };
    user = lib.mkOption { type = lib.types.str; description = "SMTP account username"; };
    from = lib.mkOption { type = lib.types.str; description = "From address for system/ZED mail"; };
    passwordSecretPath = lib.mkOption { type = lib.types.str; description = "Path to agenix secret with SMTP password"; };
    recipient = lib.mkOption { type = lib.types.str; description = "Address root mail is forwarded to"; };
  };

  config = lib.mkIf cfg.enable {
    programs.msmtp = {
      enable = true;
      setSendmail = true;
      defaults = {
        aliases = "/etc/aliases";
        port = cfg.port;
        auth = "plain";
        tls = "on";
        tls_starttls = if cfg.startTls then "on" else "off";
      };
      accounts.default = {
        host = cfg.host;
        passwordeval = "cat ${cfg.passwordSecretPath}";
        user = cfg.user;
        from = cfg.from;
      };
    };
    services.mail.sendmailSetuidWrapper.enable = true;
    environment.etc.aliases.text = "root: ${cfg.recipient}\n";
  };
}
