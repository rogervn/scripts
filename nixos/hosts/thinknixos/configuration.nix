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
    ../../modules/mango_wm.nix
    ../../modules/display_manager.nix
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
      # Keep the boot menu hidden; hold a key during startup to show it.
      timeout = 0;
    };
    plymouth.enable = true;
    # Keep Plymouth on screen without kernel or initrd status messages until
    # the display manager takes over.
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "rd.udev.log_level=3"
      "rd.systemd.show_status=auto"
    ];
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
    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;
  };

  myServices.noctaliaGreeter = {
    sessionDefault = "mango";
    output = {
      name = "eDP-1";
      width = 1920;
      height = 1080;
      scale = 1.0;
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
  systemd.tmpfiles.rules = [
    "d /home/${userName}/.ssh 0700 ${userName} users -"
  ];
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
