{
  config,
  pkgs,
  lib,
  userName,
  hostName,
  nixvim,
  agenixPackage,
  ...
}:
{
  imports = [
    ../../modules/base.nix
    ../../modules/secrets-rogervn.nix
    ../../modules/steam.nix
    (import ../../modules/window_manager.nix {
      inherit pkgs lib;
      windowManager = [ "niri" ];
    })
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit nixvim; };
  };

  environment.systemPackages = [ agenixPackage ];

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # Uncomment these to be able to build a aarch64 image
      # trusted-users = [ userName ];
      # Binary cache for the CachyOS kernel (nix-cachyos-kernel flake input)
      extra-substituters = [ "https://attic.xuyh0120.win/lantian" ];
      extra-trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };
  nixpkgs.config = {
    allowUnfree = true;
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-x86_64-v3;
    extraModprobeConfig = ''
      options cfg80211 ieee80211_regdom="GB"
    '';
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  time.timeZone = "Europe/London";

  hardware = {
    wirelessRegulatoryDatabase = true;
    bluetooth.enable = true;
    enableAllFirmware = true;
    xone.enable = true;
  };

  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

  services = {
    kmscon = {
      enable = true;
      config.font-name = "JetbrainsMono NL Nerd Font Mono";
    };
    pipewire = {
      enable = true;
      pulse.enable = true;
    };
  };

  networking = {
    inherit hostName;
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
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
