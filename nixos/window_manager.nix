{ config, lib, pkgs, userName, ... }:

let 
  regreetWallpaper = "${pkgs.nixos-artwork.wallpapers.nineish-dark-gray}/share/backgrounds/nixos/nix-wallpaper-nineish-dark-gray.png";
in
{
  environment.systemPackages = with pkgs; [
    blueman
    bluetui
    cliphist
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
    matugen
    nautilus
    nextcloud-client
    networkmanagerapplet
    noto-fonts
    pavucontrol
    rofi
    shotwell
    slurp
    vlc
    vivaldi
    wallust
    waybar
    wl-clipboard
    zsh-powerlevel10k
  ];

  fonts.packages = with pkgs; [
    font-awesome
    jetbrains-mono
    nerd-fonts.symbols-only
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

  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true; # enable the graphical frontend for managing

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  security.pam.services = {
    greetd.enableGnomeKeyring = true;
    greetd-password.enableGnomeKeyring = true;
    login.enableGnomeKeyring = true;
  };

  home-manager.users.${userName} = {
    gtk = {
      enable = true;
      theme = {
        name = "Orchis-Dark";
        package = pkgs.orchis-theme;
      };

      iconTheme = {
        name = "Tela-blue-dark";
        package = pkgs.tela-icon-theme;
      };

      gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    };

    # Dconf Settings for Global Dark Mode (Libadwaita/Modern GTK4)
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };

  security.polkit.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
}
