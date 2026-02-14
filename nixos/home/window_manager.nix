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
}
