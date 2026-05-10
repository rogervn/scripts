{
  config,
  pkgs,
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
    ../../modules/window_manager.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit nixvim; };
  };

  environment.systemPackages = [ agenixPackage ];

  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };
  nixpkgs.config.allowUnfree = true;

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    extraModprobeConfig = ''
      options cfg80211 ieee80211_regdom="GB"
    '';
  };

  time.timeZone = "Europe/London";

  hardware = {
    wirelessRegulatoryDatabase = true;
    bluetooth.enable = true;
    enableAllFirmware = true;
  };

  services = {
    kmscon = {
      enable = true;
      hwRender = true;
      fonts = [
        {
          name = "JetbrainsMono NL Nerd Font Mono";
          package = pkgs.nerd-fonts.jetbrains-mono;
        }
      ];
    };
    pipewire = {
      enable = true;
      pulse.enable = true;
    };
    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;
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
