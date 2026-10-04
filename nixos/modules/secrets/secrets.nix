let
  kratos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICfXpVArWb1AGjOCRuWDFrd0iAmqaPiemkfyUuKFSp3B";
  deckard = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG2196OLuebzSeUdwtgf/eixm+Lqi0LIk3JBLfOtFWzF";
  megaman = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIND2J9suKBk/hgBXe7kwpZC3btO7iFkodaaziatObduP";
  # Shared age identity of the Raspberry Pis (pico, pichu)
  rpi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFFCnPLdKwtfQ/MmwhQnHwOunOpEQ9f6jCg0AYfbytPx";
  pikachu = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHlMwEhHRTS4l1Nv+yKHcmw1RrIdj8TjVe87639Jx2TL";
  snorlax = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA7oBoq6qfSegWYiov46W11wuOZMq+B4zaGt45SfN/g/";
  mog = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINeIjCWbfG/0k8wpBAN5WQu5ikl8mSAOiLEbqsSD0WaP";
  kirby = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIflQBy+YtPvpu2N5XVAsUn3c6lY8uNYExDv2THYFyYA";
in
{
  "rogervn_pass_hash.age".publicKeys = [
    kratos
    deckard
    megaman
  ];
  "rogervn_private_key.age".publicKeys = [
    kratos
    deckard
    megaman
  ];
  "rogervn_authorized_keys.age".publicKeys = [
    kratos
    deckard
    megaman
  ];
  "openrouter_api_key.age".publicKeys = [
    kratos
    deckard
    megaman
  ];
  "backupuser_pass_hash.age".publicKeys = [
    kratos
    snorlax
  ];
  "backupuser_private_key.age".publicKeys = [
    kratos
    snorlax
  ];
  "backupuser_authorized_keys.age".publicKeys = [
    kratos
    snorlax
  ];
  "serveruser_pass_hash.age".publicKeys = [
    kratos
    mog
    rpi
    pikachu
  ];
  "serveruser_authorized_keys.age".publicKeys = [
    kratos
    mog
    rpi
    pikachu
  ];
  "datauser_pass_hash.age".publicKeys = [
    kratos
    kirby
  ];
  "datauser_private_key.age".publicKeys = [
    kratos
    kirby
  ];
  "datauser_authorized_keys.age".publicKeys = [
    kratos
    kirby
  ];
  "cloudflared_token.age".publicKeys = [
    kratos
    mog
  ];
  "tailscale_auth_key.age".publicKeys = [
    kratos
    mog
    pikachu
  ];
  "vaultwarden_env_file.age".publicKeys = [
    kratos
    mog
  ];
  "mog_backup_restic_pass.age".publicKeys = [
    kratos
    mog
  ];
  "authentik_env_file.age".publicKeys = [
    kratos
    kirby
  ];
  "paperlessngx_env_file.age".publicKeys = [
    kratos
    kirby
  ];
  "joplin_server_env_file.age".publicKeys = [
    kratos
    kirby
  ];
  "joplin_idp_file.age".publicKeys = [
    kratos
    kirby
  ];
  "nextcloud_admin_pass.age".publicKeys = [
    kratos
    kirby
  ];
  "smtp_password.age".publicKeys = [
    kratos
    kirby
  ];
  "kirby_restic_pass.age".publicKeys = [
    kratos
    kirby
  ];
  "kirby_rclone_env.age".publicKeys = [
    kratos
    kirby
  ];
  "kirby_backupuser_authorized_keys.age".publicKeys = [
    kratos
    kirby
  ];
  "beszel_hub_key_file.age".publicKeys = [
    kratos
    kirby
    mog
    pikachu
  ];
  "kirby_beszel_token_file.age".publicKeys = [
    kratos
    kirby
  ];
  "mog_beszel_token_file.age".publicKeys = [
    kratos
    mog
  ];
  "homepage_env_file.age".publicKeys = [
    kratos
    pikachu
  ];
  "pikachu_beszel_token_file.age".publicKeys = [
    kratos
    pikachu
  ];
  "cloudflare_ddns_token.age".publicKeys = [
    kratos
    pikachu
  ];
  "cloudflare_ddns_env_file.age".publicKeys = [
    kratos
    pikachu
  ];
}
