{
  config,
  pkgs,
  pam_shim,
  ...
}: {
  imports = [pam_shim.homeModules.default];
  pamShim.enable = true;
  nixpkgs.overlays = [
    (final: prev: {
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
    hyprland
    hyprpolkitagent
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
    xdg-desktop-portal-hyprland
  ];

  systemd.user.services.hyprpolkitagent = {
    Unit = {
      Description = "Hyprland Polkit Agent";
      After = [
        "graphical-session.target"
        "dbus.service"
      ];
    };
    Service = {
      ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

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
}
