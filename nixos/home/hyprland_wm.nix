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

  programs.noctalia = {
    enable = true;
    package = config.lib.pamShim.replacePam pkgs.noctalia;
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
    uwsm
    hyprland
    hyprpolkitagent
    xdg-desktop-portal-hyprland
  ];
}
