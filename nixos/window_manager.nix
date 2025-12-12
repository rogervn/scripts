{ config, lib, pkgs, ... }:

let 
  regreetWallpaper = "${pkgs.nixos-artwork.wallpapers.nineish-dark-gray}/share/backgrounds/nixos/nix-wallpaper-nineish-dark-gray.png";
in
{
  environment.systemPackages = with pkgs; [
    blueman
    bluetui
    cliphist
    firefox
    gedit
    ghostty
    grim
    gsimplecal
    evince
    hyprpaper
    hypridle
    hyprlock
    imagemagick
    libnotify
    mako
    nautilus
    nextcloud-client
    networkmanagerapplet
    noto-fonts
    pavucontrol
    rofi
    shotwell
    slurp
    vlc
    wallust
    waybar
    wl-clipboard
    zsh-powerlevel10k
  ];

  fonts.packages = with pkgs; [
    font-awesome
    jetbrains-mono
  ];

  programs.hyprland.enable = true;
  programs.zsh.ohMyZsh.enable = true;
 
  programs.regreet = {
    enable = true;
    settings = {
      background = {
        path = regreetWallpaper;
        fit = "Cover";
      };
      GTK = {
        application_prefer_dark_theme = true;
        theme_name = lib.mkForce "Adwaita-dark";
        font_name = lib.mkForce "Noto Serif 16";
      };
    };
  };

  security.polkit.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
}
