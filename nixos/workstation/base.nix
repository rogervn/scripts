{ config, lib, pkgs, userName, hostName, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = hostName;
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  time.timeZone = "Europe/London";

  i18n.defaultLocale = "en_US.UTF-8";

  hardware.bluetooth.enable = true;
  hardware.enableAllFirmware = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  services.kmscon = {
    enable = true;
    hwRender = true;
    fonts = [ { name = "JetbrainsMono NL Nerd Font Mono"; package = pkgs.nerd-fonts.jetbrains-mono; } ];
  };

  services.openssh.enable = true;
  services.chrony.enable = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  users.users.${userName} = {
    isNormalUser = true;
    hashedPasswordFile = config.age.secrets."${userName}_pass_hash".path;
    extraGroups = [ "wheel" "disk" ];
  };
  age.secrets."${userName}_private_key" = {
    path = "/home/${userName}/.ssh/id_rsa";
    owner = userName;
    mode = "600";
  };

  environment.systemPackages = with pkgs; [
    curl
    chrony
    git
    killall
    less
    linux-firmware
    man-db
    noto-fonts
    openssh
    tmux
    rsync
    stow
    vim-full
    wget
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
  };

  users.defaultUserShell = pkgs.zsh;
}
