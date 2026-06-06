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
    ../../modules/vm_guest.nix
    ../../modules/window_manager.nix
    ../../modules/zfs.nix
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

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  time.timeZone = "Europe/London";

  hardware = {
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

  networking = {
    inherit hostName;
    hostId = "8425e349";
    networkmanager.enable = true;
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
