{
  pkgs,
  ...
}:
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

  # Workaround for regreet 0.4.0 crashing on NixOS due to missing GStreamer
  # dependencies (nixpkgs PR #530302). Wraps the binary with GST plugin paths
  # so GStreamer can find its plugins at runtime.
  regreetWithGst = pkgs.runCommand "regreet-with-gst" {
    nativeBuildInputs = [ pkgs.makeWrapper ];
    version = pkgs.regreet.version;
    meta = pkgs.regreet.meta // { mainProgram = "regreet"; };
  } ''
    mkdir -p $out/bin
    makeWrapper ${pkgs.regreet}/bin/regreet $out/bin/regreet \
      --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${pkgs.gst_all_1.gstreamer.out}/lib/gstreamer-1.0" \
      --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${pkgs.gst_all_1.gst-plugins-base}/lib/gstreamer-1.0" \
      --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${pkgs.gst_all_1.gst-plugins-good}/lib/gstreamer-1.0"
  '';
in
{
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

  programs = {
    hyprland = {
      enable = true;
      withUWSM = true;
      package = hyprlandUwsmOnly;
    };

    regreet = {
      enable = true;
      package = regreetWithGst;

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

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    GSK_RENDERER = "ngl";
  };

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
}
