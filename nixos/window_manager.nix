{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    blueman
    bluetui
    cliphist
    firefox
    ghostty
    grim
    gsimplecal
    hyprpaper
    hypridle
    hyprlock
    imagemagick
    libnotify
    mako
    nextcloud-client
    networkmanagerapplet
    noto-fonts
    pavucontrol
    pywal16
    rofi
    shotwell
    slurp
    vlc
    waybar
    wl-clipboard-rs
    zsh-powerlevel10k
  ];

  fonts.packages = with pkgs; [
    font-awesome
    jetbrains-mono
  ];

  programs.hyprland.enable = true;
  programs.zsh.ohMyZsh.enable = true;
 
  services.gnome.gnome-keyring.enable = true;
  services.displayManager.gdm.enable = true; 
  services.displayManager.gdm.wayland = true;
  services.desktopManager.gnome.enable = true;

  security.polkit.enable = true;

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
}
