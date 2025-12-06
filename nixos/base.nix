{ config, lib, pkgs, ... }:

let 
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-${lib.versions.majorMinor lib.version}.tar.gz";
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-vm"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable sound.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

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
    openssh
    tmux
    rsync
    stow
    vim
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
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
}
