{ config, pkgs, ... }: {
  systemd.services.cloudflared = {
    description = "Cloudflare Tunnel";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel run --protocol quic --token-file %d/cloudflared_token";
      LoadCredential = "cloudflared_token:${config.age.secrets.cloudflared_token.path}";
      Restart = "on-failure";
      DynamicUser = true;
    };
  };
}
