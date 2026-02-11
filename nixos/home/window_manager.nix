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

  home.packages = [
    pkgs.hyprland
    pkgs.hyprpolkitagent
    pkgs.noctalia-shell
    pkgs.xdg-desktop-portal-hyprland
  ];

  systemd.user.services.hyprpolkitagent = {
    Unit = {
      Description = "Hyprland Polkit Agent";
      After = ["graphical-session.target"];
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
