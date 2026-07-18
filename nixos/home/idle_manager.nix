_:
let
  # NIRI_SOCKET is only set inside a niri session; picks the right dpms command at runtime.
  dpmsOn = ''sh -c 'if [ -n "$NIRI_SOCKET" ]; then niri msg action power-on-monitors; else hyprctl dispatch dpms on; fi' '';
  dpmsOff = ''sh -c 'if [ -n "$NIRI_SOCKET" ]; then niri msg action power-off-monitors; else hyprctl dispatch dpms off; fi' '';
in
{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "noctalia-shell ipc call lockScreen lock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = dpmsOn;
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 330;
          on-timeout = dpmsOff;
          on-resume = dpmsOn;
        }
        {
          timeout = 900;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
