{
  config,
  pkgs,
  nixpkgs-master,
  ...
}:
let
  # TODO: Drop nixpkgs-master once nixos-unstable has NixOS/nixpkgs#576762.
  cloudflared = nixpkgs-master.legacyPackages.${pkgs.stdenv.hostPlatform.system}.cloudflared;
in
{
  systemd.services.cloudflared = {
    description = "Cloudflare Tunnel";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${cloudflared}/bin/cloudflared tunnel run --protocol quic --token-file %d/cloudflared_token";
      LoadCredential = "cloudflared_token:${config.age.secrets.cloudflared_token.path}";
      Restart = "on-failure";
      DynamicUser = true;
    };
  };
}
