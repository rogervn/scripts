{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    bibata-cursors
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
    noctalia-shell
    noto-fonts
    pavucontrol
    shotwell
    slurp
    vlc
    vivaldi
    wl-clipboard
    xdg-user-dirs
  ];

  fonts.packages = with pkgs; [
    font-awesome
    jetbrains-mono
    nerd-fonts.symbols-only
  ];

  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;

  programs.regreet = {
    enable = true;

    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
    };

    settings = {
      background = {
        path = "${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.src}";
        fit = "Cover";
      };
      GTK = {
        application_prefer_dark_theme = true;
      };
    };

  };

  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  security.pam.services.greetd.enableGnomeKeyring = true;

  security.polkit.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-hyprland];
}
