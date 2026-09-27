let
  amdesktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICfXpVArWb1AGjOCRuWDFrd0iAmqaPiemkfyUuKFSp3B";
  thinknixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG2196OLuebzSeUdwtgf/eixm+Lqi0LIk3JBLfOtFWzF";
  megaman = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIND2J9suKBk/hgBXe7kwpZC3btO7iFkodaaziatObduP";
  piuk = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFFCnPLdKwtfQ/MmwhQnHwOunOpEQ9f6jCg0AYfbytPx";
  snorlax = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA7oBoq6qfSegWYiov46W11wuOZMq+B4zaGt45SfN/g/";
  mog = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINeIjCWbfG/0k8wpBAN5WQu5ikl8mSAOiLEbqsSD0WaP";
  datanixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIflQBy+YtPvpu2N5XVAsUn3c6lY8uNYExDv2THYFyYA";
in
{
  "rogervn_pass_hash.age".publicKeys = [
    amdesktop
    thinknixos
    megaman
  ];
  "rogervn_private_key.age".publicKeys = [
    amdesktop
    thinknixos
    megaman
  ];
  "rogervn_authorized_keys.age".publicKeys = [
    amdesktop
    thinknixos
    megaman
  ];
  "openrouter_api_key.age".publicKeys = [
    amdesktop
    thinknixos
    megaman
  ];
  "piuk_authorized_keys.age".publicKeys = [
    amdesktop
    piuk
  ];
  "backupuser_pass_hash.age".publicKeys = [
    amdesktop
    snorlax
  ];
  "backupuser_private_key.age".publicKeys = [
    amdesktop
    snorlax
  ];
  "backupuser_authorized_keys.age".publicKeys = [
    amdesktop
    snorlax
  ];
  "serveruser_pass_hash.age".publicKeys = [
    amdesktop
    mog
  ];
  "serveruser_authorized_keys.age".publicKeys = [
    amdesktop
    mog
  ];
  "datauser_pass_hash.age".publicKeys = [
    amdesktop
    datanixos
  ];
  "datauser_private_key.age".publicKeys = [
    amdesktop
    datanixos
  ];
  "datauser_authorized_keys.age".publicKeys = [
    amdesktop
    datanixos
  ];
  "cloudflared_token.age".publicKeys = [
    amdesktop
    mog
  ];
  "tailscale_auth_key.age".publicKeys = [
    amdesktop
    mog
  ];
  "vaultwarden_env_file.age".publicKeys = [
    amdesktop
    mog
  ];
  "mog_backup_restic_pass.age".publicKeys = [
    amdesktop
    mog
  ];
  "authentik_env_file.age".publicKeys = [
    amdesktop
    datanixos
  ];
  "paperlessngx_env_file.age".publicKeys = [
    amdesktop
    datanixos
  ];
  "joplin_server_env_file.age".publicKeys = [
    amdesktop
    datanixos
  ];
  "joplin_idp_file.age".publicKeys = [
    amdesktop
    datanixos
  ];
  "nextcloud_admin_pass.age".publicKeys = [
    amdesktop
    datanixos
  ];
  "smtp_password.age".publicKeys = [
    amdesktop
    datanixos
  ];
  "datanixos_restic_pass.age".publicKeys = [
    amdesktop
    datanixos
  ];
  "datanixos_rclone_env.age".publicKeys = [
    amdesktop
    datanixos
  ];
  "datanixos_backupuser_authorized_keys.age".publicKeys = [
    amdesktop
    datanixos
  ];
  "beszel_hub_key_file.age".publicKeys = [
    amdesktop
    datanixos
    mog
  ];
  "datanixos_beszel_token_file.age".publicKeys = [
    amdesktop
    datanixos
  ];
  "mog_beszel_token_file.age".publicKeys = [
    amdesktop
    mog
  ];
  "homepage_env_file.age".publicKeys = [
    amdesktop
    mog
  ];
}
