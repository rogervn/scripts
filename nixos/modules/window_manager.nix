{ config, lib, pkgs, userName, ... }:

{
  environment.systemPackages = with pkgs; [
    bitwarden-desktop
    blueman
    bluetui
    cliphist
    gedit
    ghostty
    grim
    evince
    hypridle
    imagemagick
    joplin-desktop
    libnotify
    matugen
    nautilus
    nextcloud-client
    networkmanagerapplet
    noto-fonts
    pavucontrol
    sddm-astronaut
    shotwell
    slurp
    vlc
    vivaldi
    wl-clipboard
  ];

  fonts.packages = with pkgs; [
    font-awesome
    jetbrains-mono
    nerd-fonts.symbols-only
  ];

  programs.hyprland.enable = true;
 
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    extraPackages = with pkgs; [
      kdePackages.qtsvg
      kdePackages.qtvirtualkeyboard
      kdePackages.qtmultimedia
    ];
    theme = "sddm-astronaut-theme";
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
