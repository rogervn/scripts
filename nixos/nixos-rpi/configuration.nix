{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.loader.raspberryPi.bootloader = "kernel";
  system.stateVersion = "26.05";
}
