{
  config,
  pkgs,
  userName,
  hostName,
  ...
}: {
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Uncomment these to be able to build a aarch64 image
  boot.binfmt.emulatedSystems = ["aarch64-linux"];
  nix.settings.trusted-users = [userName];

  time.timeZone = "Europe/London";

  hardware.bluetooth.enable = true;
  hardware.enableAllFirmware = true;
  hardware.xone.enable = true;

  services.kmscon = {
    enable = true;
    hwRender = true;
    fonts = [
      {
        name = "JetbrainsMono NL Nerd Font Mono";
        package = pkgs.nerd-fonts.jetbrains-mono;
      }
    ];
  };

  networking.hostName = hostName;
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  users.users.${userName} = {
    isNormalUser = true;
    hashedPasswordFile = config.age.secrets."${userName}_pass_hash".path;
    extraGroups = [
      "wheel"
      "disk"
    ];
  };
  age.secrets."${userName}_private_key" = {
    path = "/home/${userName}/.ssh/id_ed25519";
    owner = userName;
    mode = "600";
  };
  age.secrets."${userName}_authorized_keys" = {
    path = "/home/${userName}/.ssh/authorized_keys";
    owner = userName;
    mode = "600";
  };

  system.stateVersion = "26.05";
}
