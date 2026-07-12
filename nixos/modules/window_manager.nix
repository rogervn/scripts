{
  pkgs,
  lib,
  windowManager ? [ "hyprland" ],
  ...
}:
let
  wantHyprland = lib.elem "hyprland" windowManager;
  wantNiri = lib.elem "niri" windowManager;

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
  environment.systemPackages =
    with pkgs;
    [
      bibata-cursors
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
    ]
    ++ lib.optionals wantNiri [
      xwayland-satellite
    ];

  fonts.packages = with pkgs; [
    font-awesome
    jetbrains-mono
    nerd-fonts.symbols-only
  ];

  programs = {
    hyprland = lib.mkIf wantHyprland {
      enable = true;
      withUWSM = true;
      package = hyprlandUwsmOnly;
    };

    niri = lib.mkIf wantNiri {
      enable = true;
    };

    regreet = {
      enable = true;

      cursorTheme = {
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;
      };

      settings = {
        skip_selection = true;

        background = {
          path = "${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.src}";
          fit = "Cover";
        };
        GTK = {
          application_prefer_dark_theme = true;
        };
      };
    };

    seahorse.enable = true;
  };

  services = {
    gnome.gnome-keyring.enable = true;
    upower.enable = true;
    power-profiles-daemon.enable = true;
  };

  security.pam.services.greetd.enableGnomeKeyring = true;

  security.polkit.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  xdg.portal.extraPortals =
    lib.optionals wantHyprland [ pkgs.xdg-desktop-portal-hyprland ]
    ++ lib.optionals wantNiri [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
}
