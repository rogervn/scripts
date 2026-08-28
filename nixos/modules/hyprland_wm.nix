{ pkgs, ... }:
let
  # Makes it so hyprland non-uwsm will be hidden
  hyprlandFiltered = pkgs.symlinkJoin {
    name = "hyprland-uwsm-only";
    paths = [ pkgs.hyprland ];
    postBuild = ''
      cat $out/share/wayland-sessions/hyprland.desktop > $out/share/wayland-sessions/hyprland.desktop.tmp
      mv $out/share/wayland-sessions/hyprland.desktop.tmp $out/share/wayland-sessions/hyprland.desktop
      echo "NoDisplay=true" >> $out/share/wayland-sessions/hyprland.desktop
    '';
  };
  hyprlandUwsmOnly = pkgs.hyprland // {
    inherit (hyprlandFiltered) outPath;
    inherit (hyprlandFiltered) drvPath;
    override = _: hyprlandUwsmOnly;
  };

in
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
  ];

  fonts.packages = with pkgs; [
    font-awesome
    jetbrains-mono
    nerd-fonts.symbols-only
  ];

  programs = {
    hyprland = {
      enable = true;
      withUWSM = true;
      package = hyprlandUwsmOnly;
    };

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

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
}
