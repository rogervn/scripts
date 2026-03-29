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
    (sddm-astronaut.override {
      themeConfig = {
        Background = "${nixos-artwork.wallpapers.nineish-dark-gray.src}";
        ScreenWidth = "1920";
        ScreenHeight = "1080";
        FormPosition = "left";
        CursorTheme = "Bibata-Modern-Classic";
      };
    })
  ];

  fonts.packages = with pkgs; [
    font-awesome
    jetbrains-mono
    nerd-fonts.symbols-only
  ];

  programs.hyprland.enable = true;

  # This is needed for sddm as wayland has an invisible cursor bug
  services.xserver.enable = true;

  services.displayManager = {
    defaultSession = "hyprland";
    sddm = {
      enable = true;
      extraPackages = with pkgs; [
        kdePackages.qtsvg
        kdePackages.qtvirtualkeyboard
        kdePackages.qtmultimedia
      ];
      package = pkgs.kdePackages.sddm;
      theme = "sddm-astronaut-theme";
      settings = {
        General = {
          CursorTheme = "Bibata-Modern-Classic";
          CursorSize = 24;
        };
      };
    };
  };

  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  security.pam.services.login.enableGnomeKeyring = true;

  security.polkit.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-hyprland];
}
