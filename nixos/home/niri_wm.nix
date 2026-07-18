{
  pkgs,
  config,
  pam_shim,
  ...
}:
{
  imports = [
    pam_shim.homeModules.default
  ];
  pamShim.enable = true;
  nixpkgs.overlays = [
    (_: prev: {
      noctalia-shell = config.lib.pamShim.replacePam prev.noctalia-shell;
    })
  ];

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
    noctalia-shell
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
