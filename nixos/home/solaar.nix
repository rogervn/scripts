{ pkgs, ... }:
{
  home.packages = [ pkgs.solaar ];

  systemd.user.services.solaar = {
    Unit = {
      Description = "Solaar - Logitech device manager";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.solaar}/bin/solaar --window=hide";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # Mask the dnf RPM's autostart (kept only for its udev rule) so its crashing GTK build can't clash with the service above.
  xdg.configFile."autostart/solaar.desktop".text = ''
    [Desktop Entry]
    Hidden=true
  '';
}
