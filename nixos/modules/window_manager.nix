{
  pkgs,
  userName,
  ...
}: let
  # Makes it so hyprland non-uwsm will be hidden
  hyprlandFiltered = pkgs.symlinkJoin {
    name = "hyprland-uwsm-only";
    paths = [pkgs.hyprland];
    postBuild = ''
      cat $out/share/wayland-sessions/hyprland.desktop > $out/share/wayland-sessions/hyprland.desktop.tmp
      mv $out/share/wayland-sessions/hyprland.desktop.tmp $out/share/wayland-sessions/hyprland.desktop
      echo "NoDisplay=true" >> $out/share/wayland-sessions/hyprland.desktop
    '';
  };
  hyprlandUwsmOnly =
    pkgs.hyprland
    // {
      outPath = hyprlandFiltered.outPath;
      drvPath = hyprlandFiltered.drvPath;
      override = _: hyprlandUwsmOnly;
    };
in {
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

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    package = hyprlandUwsmOnly;
  };

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

  # Sets hyprland uwsm as the default session
  systemd.tmpfiles.settings."10-regreet-state" = {
    "/var/lib/regreet/state.toml" = {
      C = {
        user = "greeter";
        group = "greeter";
        mode = "0644";
        argument = toString (pkgs.writeText "regreet-state-default.toml" ''
          [user_to_last_sess]
          ${userName} = "Hyprland (uwsm-managed)"
        '');
      };
    };
  };
}
