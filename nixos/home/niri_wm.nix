{
  pkgs,
  config,
  pam_shim,
  noctalia,
  ...
}:
{
  imports = [
    pam_shim.homeModules.default
  ];
  pamShim.enable = true;

  programs.noctalia = {
    enable = true;
    package =
      config.lib.pamShim.replacePam
        noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };

  home.packages = with pkgs; [
    blueman
    bluetui
    cliphist
    font-awesome
    gedit
    ghostty
    grim
    evince
    hypridle
    qt6.qtwayland
    imagemagick
    jetbrains-mono
    libnotify
    networkmanagerapplet
    nerd-fonts.symbols-only
    noto-fonts
    pavucontrol
    shotwell
    slurp
    wl-clipboard
    xdg-user-dirs
    bibata-cursors
    niri
    xwayland-satellite
    polkit_gnome
    xdg-desktop-portal-gnome
    xdg-desktop-portal-gtk
  ];
}
