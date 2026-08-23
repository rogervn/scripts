{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bibata-cursors
    blueman
    bluetui
    cliphist
    gedit
    ghostty
    gnome-calculator
    grim
    evince
    imagemagick
    joplin-desktop
    libnotify
    matugen
    nautilus
    nextcloud-client
    networkmanagerapplet
    noto-fonts
    pavucontrol
    shotwell
    slurp
    vlc
    vivaldi
    wl-clipboard
    xdg-user-dirs
    xwayland-satellite
  ];

  fonts.packages = with pkgs; [
    font-awesome
    jetbrains-mono
    nerd-fonts.symbols-only
  ];

  programs = {
    dconf.enable = true;
    niri.enable = true;

    seahorse.enable = true;

    noctalia = {
      enable = true;
      recommendedServices.enable = true;
    };
  };

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
    };
    gnome.gnome-keyring.enable = true;
    gvfs.enable = true;
    upower.enable = true;
    power-profiles-daemon.enable = true;
  };

  security.polkit.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gnome
    xdg-desktop-portal-gtk
  ];
}
