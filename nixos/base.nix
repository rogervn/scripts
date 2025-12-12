{ config, lib, pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-vm"; # Define your hostname.

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/London";

  i18n.defaultLocale = "en_US.UTF-8";

  hardware.bluetooth.enable = true;

  # Enable sound.
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

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rogervn = {
    isNormalUser = true;
    extraGroups = [ "wheel" "disk" ];
  };
  home-manager.users.rogervn = {pkgs, ... }: {
    imports = [
      ./dotfiles.nix
    ];

    home.stateVersion = "25.11";
  };

  environment.systemPackages = with pkgs; [
    curl
    chrony
    git
    less
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

  services.openssh.enable = true;
  services.chrony.enable = true;

  # Open ports in the firewall.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };
}
