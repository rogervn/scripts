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
    fonts = [ { name = "Noto Sans Mono"; package = pkgs.noto-fonts; } ];
  };

  services.openssh.enable = true;
  services.chrony.enable = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${userName} = {
    isNormalUser = true;
    hashedPasswordFile = config.age.secrets.rogervn_pass_hash.path;
    extraGroups = [ "wheel" "disk" ];
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
    ohMyZsh = {
      enable = true;
      theme = "powerlevel10k";
      custom = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k";
    };
  };
  programs.tmux.enable = true;

  users.defaultUserShell = pkgs.zsh;
}
