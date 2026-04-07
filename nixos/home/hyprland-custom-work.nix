# Work machine Hyprland customisation — programs, autostart, window rules.
# Source of truth: dotfiles/fedora/.config/hypr/hyprland.conf.d/ (default-programs, extra-autostart, window-rules, monitors)
# and dotfiles/common/.config/hypr/hyprland.conf.d/inputs.conf.
{...}: {
  wayland.windowManager.hyprland = {
    settings = {
      monitor = [
        # Laptop
        "desc:California Institute of Technology 0x1403,3840x2400@60,0x0,2"
        "desc:Chimei Innolux Corporation 0x1488,1920x1200@60,0x0,1"

        # Office
        "desc:Dell Inc. DELL P3223QE JG6KWN3,3840x2160@60,1920x-1200,1.25"
        "desc:Dell Inc. DELL UP3017 Y7NWN74M118L,2560x1600@60,5000x-1200,1,transform,1"

        # Home
        "desc:BNQ BenQ EW3270U TBK02382019,3840x2160@60,1920x-1200,1"
        "desc:Dell Inc. DELL P2317H 4WY7076L06QB,1920x1080@60,5760x-1200,1,transform,1"
        "Virtual-1,preferred,0x0,1"
      ];
      workspace = [
        "1,monitor:desc:California Institute of Technology 0x1403,default:true"
        "2,monitor:desc:Dell Inc. DELL P3223QE JG6KWN3,default:true"
        "3,monitor:desc:Dell Inc. DELL UP3017 Y7NWN74M118L,default:true"
        "1,monitor:desc:LG Electronics LG TV SSCR2 0x01010101,default:true"
        "1,monitor:desc:BOE 0x0791,default:true"
      ];

      "$terminal" = "ghostty";
      "$fileManager" = "nautilus";
      "$browser" = "google-chrome --ozone-platform=wayland";
      "$clipboardManager" = "cliphist";
      "$locker" = "noctalia-shell ipc call lockScreen lock";
      "$noteEditor" = "gedit";
      "$codeEditor" = "code-fb --ozone-platform-hint=auto";
      "$screenshot_file" = "$(xdg-user-dir PICTURES)/Screenshots/$(date +'screenshot_%Y%m%d_%H%M%S.png')";
      "$clipboardLauncher" = "noctalia-shell ipc call launcher clipboard";
      "$appLauncher" = "noctalia-shell ipc call launcher toggle";
      "$runLauncher" = "noctalia-shell ipc call launcher command";
      "$dismissLastNotification" = "noctalia-shell ipc call notifications dismissOldest";
      "$dismissAllNotification" = "noctalia-shell ipc call notifications clear";
      "$toggleNotification" = "noctalia-shell ipc call notifications toggleHistory";
      "$wallpaperChange" = "noctalia-shell ipc call wallpaper random";
    };

    # exec-once, windowrule, monitors and device in extraConfig to avoid list-key conflicts with shared hyprland.nix
    extraConfig = ''
      exec-once = noctalia-shell
      exec-once = ~/.nix-profile/libexec/xdg-desktop-portal-hyprland
      exec-once = /usr/bin/gnome-keyring-daemon --start --components=pkcs11

      windowrule = workspace 1, match:initial_title Outlook \(PWA\)
      windowrule = float on, match:title Calculator
    '';
  };
}
