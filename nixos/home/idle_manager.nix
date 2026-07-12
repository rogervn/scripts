{ ... }:
let
  # hypridle only needs ext-idle-notify-v1, so the same daemon works under
  # both Hyprland and niri; only the dpms toggle command differs per
  # compositor. NIRI_SOCKET is set by niri, HYPRLAND_INSTANCE_SIGNATURE by
  # Hyprland, so detect at runtime which one is actually running.
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
