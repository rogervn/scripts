# Home machine Hyprland customisation — programs, autostart, window rules.
# Imported by: amdesktop, thinknixos, nixos-vm.
# Source of truth: dotfiles/nixos/.config/hypr/hyprland.conf.d/ (default-programs, extra-autostart, window-rules)
# and dotfiles/common/.config/hypr/hyprland.conf.d/inputs.conf.
{...}: {
  wayland.windowManager.hyprland = {
    settings = {
      monitor = [
        "desc:LG Electronics LG TV SSCR2 0x01010101,3840x2160@120,auto,1.5,vrr,3,bitdepth,10,cm,auto"
        "desc:BOE 0x0791,1920x1080@60,auto,1"
        ",preferred,auto,auto"
      ];
      workspace = [
        "1,monitor:desc:LG Electronics LG TV SSCR2 0x01010101,default:true"
        "1,monitor:desc:BOE 0x0791,default:true"
      ];

      "$terminal" = "ghostty";
      "$fileManager" = "nautilus";
      "$browser" = "vivaldi";
      "$clipboardManager" = "cliphist";
      "$locker" = "noctalia-shell ipc call lockScreen lock";
      "$noteEditor" = "joplin-desktop";
      "$codeEditor" = "gedit";
      "$screenshot_file" = "$(xdg-user-dir PICTURES)/Screenshots/$(date +'screenshot_%Y%m%d_%H%M%S.png')";
      "$clipboardLauncher" = "noctalia-shell ipc call launcher clipboard";
      "$appLauncher" = "noctalia-shell ipc call launcher toggle";
      "$runLauncher" = "noctalia-shell ipc call launcher command";
      "$dismissLastNotification" = "noctalia-shell ipc call notifications dismissOldest";
      "$dismissAllNotification" = "noctalia-shell ipc call notifications clear";
      "$toggleNotification" = "noctalia-shell ipc call notifications toggleHistory";
      "$wallpaperChange" = "noctalia-shell ipc call wallpaper random";
    };

    # exec-once and windowrule in extraConfig to avoid list-key conflicts with shared hyprland.nix
    extraConfig = ''
      exec-once = noctalia-shell
      exec-once = nextcloud --background

      windowrule = float on, match:title Calculator

      # Logitech K830 (was inputs.conf)
      device {
          name = logitech-k830
          kb_layout = us
      }
      device {
          name = logitech-k830-1
          sensitivity = 0
          natural_scroll = false
      }
    '';
  };
}
