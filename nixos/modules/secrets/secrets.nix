let
  amdesktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICfXpVArWb1AGjOCRuWDFrd0iAmqaPiemkfyUuKFSp3B";
  thinknixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG2196OLuebzSeUdwtgf/eixm+Lqi0LIk3JBLfOtFWzF";
  piuk = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFFCnPLdKwtfQ/MmwhQnHwOunOpEQ9f6jCg0AYfbytPx";
  backupbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA7oBoq6qfSegWYiov46W11wuOZMq+B4zaGt45SfN/g/";
  mininixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINeIjCWbfG/0k8wpBAN5WQu5ikl8mSAOiLEbqsSD0WaP";
in {
  "rogervn_pass_hash.age".publicKeys = [amdesktop thinknixos];
  "rogervn_private_key.age".publicKeys = [amdesktop thinknixos];
  "rogervn_authorized_keys.age".publicKeys = [amdesktop thinknixos];
  "piuk_authorized_keys.age".publicKeys = [amdesktop piuk];
  "backupuser_pass_hash.age".publicKeys = [amdesktop backupbox];
  "backupuser_private_key.age".publicKeys = [amdesktop backupbox];
  "backupuser_authorized_keys.age".publicKeys = [amdesktop backupbox];
  "serveruser_pass_hash.age".publicKeys = [amdesktop mininixos];
  "serveruser_authorized_keys.age".publicKeys = [amdesktop mininixos];
  "vaultwarden_env_file.age".publicKeys = [amdesktop mininixos];
  "mininixos_backup_restic_pass.age".publicKeys = [amdesktop mininixos];
}
