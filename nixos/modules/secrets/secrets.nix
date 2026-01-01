let
  amdesktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICfXpVArWb1AGjOCRuWDFrd0iAmqaPiemkfyUuKFSp3B";
  thinknixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG2196OLuebzSeUdwtgf/eixm+Lqi0LIk3JBLfOtFWzF";
in {
  "rogervn_pass_hash.age".publicKeys = [amdesktop thinknixos];
  "rogervn_private_key.age".publicKeys = [amdesktop thinknixos];
  "rogervn_authorized_keys.age".publicKeys = [amdesktop thinknixos];
}
