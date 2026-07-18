{
  pkgs,
  lib,
  monitors ? [ ],
  # Raw KDL `workspace` blocks (e.g. named workspaces with open-on-output).
  workspaces ? [ ],
  terminal ? "ghostty",
  fileManager ? "nautilus",
  browser ? "vivaldi",
  locker ? "noctalia-shell ipc call lockScreen lock",
  noteEditor ? "joplin-desktop",
  codeEditor ? "gedit",
  screenshotPath ? "$(xdg-user-dir PICTURES)/Screenshots/$(date +'screenshot_%Y%m%d_%H%M%S.png')",
  clipboardLauncher ? "noctalia-shell ipc call launcher clipboard",
  appLauncher ? "noctalia-shell ipc call launcher toggle",
  runLauncher ? "noctalia-shell ipc call launcher command",
  notifDismissLast ? "noctalia-shell ipc call notifications dismissOldest",
  notifDismissAll ? "noctalia-shell ipc call notifications clear",
  notifToggle ? "noctalia-shell ipc call notifications toggleHistory",
  wallpaper ? "noctalia-shell ipc call wallpaper random all",
  extraConfig ? "",
  extraEnv ? [ ],
  ...
}:
let
  # niri KDL has no variable substitution, so commands are interpolated directly.
  envLines = lib.concatMapStringsSep "\n    " (e: ''"${e}"'') extraEnv;
in
{
  imports = [
    ./idle_manager.nix
    ./window_manager_appearence.nix
  ];

  # Screencast/screenshot portals need the gnome flavour; don't set GDK_BACKEND globally, it breaks screencast.
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    config = {
      niri = {
        default = [
          "gnome"
          "gtk"
        ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
    };
  };

  xdg.configFile."niri/config.kdl".text = ''
    input {
        keyboard {
            xkb {
                layout "us"
            }
            numlock
        }
        touchpad {
            tap
        }
        mouse {
        }
        focus-follows-mouse
    }

    gestures {
        // Disable the top-left hot corner that opens the overview.
        hot-corners {
            off
        }
    }

    ${lib.concatStringsSep "\n\n" monitors}

    ${lib.concatStringsSep "\n" workspaces}

    // Drop CSD so the focus-ring/border draws cleanly around the window edge.
    prefer-no-csd

    layout {
        gaps 8

        focus-ring {
            width 2
            active-color "#89b4fa"
            inactive-color "#45475a"
        }

        border {
            off
        }

        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
            proportion 1.0
        }

        preset-window-heights {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
            proportion 1.0
        }

        default-column-width { proportion 0.5; }
    }

    // Disables all background blur, including app-requested (e.g. noctalia-shell's bar).
    blur {
        off
    }

    // Positional: must follow layout to override its colors; optional since noctalia-shell may not have generated this file yet.
    include optional=true "noctalia.kdl"

    window-rule {
        geometry-corner-radius 10
        clip-to-geometry true

        // Stops niri filling an opaque backing behind CSD/transparent windows.
        draw-border-with-background false
    }

    window-rule {
        match app-id="org.gnome.Calculator"
        open-floating true
    }

    environment {
        XCURSOR_SIZE "24"
        HYPRCURSOR_SIZE "24"
        ${envLines}
    }

    hotkey-overlay {
        skip-at-startup
    }

    screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

    spawn-at-startup "xwayland-satellite"
    spawn-at-startup "noctalia-shell"
    spawn-at-startup "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
    spawn-at-startup "blueman-applet"
    spawn-at-startup "nm-applet"

    binds {
        // ---- Suggested-by-niri hotkey help ----
        Mod+Shift+Slash { show-hotkey-overlay; }

        // ---- App launching ----
        Mod+Return       { spawn "${terminal}"; }
        // Mod+Return covers the terminal, so Mod+T is free for the note editor.
        Mod+T            { spawn-sh "${noteEditor}"; }
        Mod+D            { spawn-sh "${runLauncher}"; }
        Mod+E            { spawn "${fileManager}"; }
        Mod+B            { spawn-sh "${browser}"; }
        Mod+X            { spawn-sh "${codeEditor}"; }
        Mod+Space        { spawn-sh "${appLauncher}"; }
        // Frees Mod+C (niri default: center-column, now Mod+Shift+C) for clipboard.
        Mod+C            { spawn-sh "${clipboardLauncher}"; }
        Mod+Shift+W      { spawn-sh "${wallpaper}"; }
        Mod+L            { spawn-sh "${locker}"; }

        Mod+N            { spawn-sh "${notifToggle}"; }
        Mod+Shift+N      { spawn-sh "${notifDismissLast}"; }
        Mod+Ctrl+Shift+N { spawn-sh "${notifDismissAll}"; }

        // niri's own Print-key screenshot actions are also bound below.
        Mod+P       { spawn-sh "grim -g \"$(slurp)\" ${screenshotPath}"; }
        Mod+Shift+P { spawn-sh "grim -o \"$(niri msg -j focused-output | jq -r .name)\" ${screenshotPath}"; }

        Mod+Shift+S { spawn "systemctl" "poweroff" "-i"; }
        Mod+Shift+U { spawn "systemctl" "suspend"; }
        Mod+Shift+B { spawn "systemctl" "reboot"; }
        Mod+Shift+Y { spawn "systemctl" "hibernate"; }
        // niri's default power-off-monitors bind, freed by the screenshot bind above.
        Mod+Ctrl+Shift+P { power-off-monitors; }
        // Mod+Shift+E already quits niri, covering "log out" without uwsm.

        // ---- niri defaults: arrows=focus, Ctrl=move, Shift=focus monitor, Ctrl+Shift=move to monitor ----
        Mod+O repeat=false { toggle-overview; }
        Mod+Q repeat=false { close-window; }

        Mod+Left  { focus-column-left; }
        Mod+Down  { focus-window-down; }
        Mod+Up    { focus-window-up; }
        Mod+Right { focus-column-right; }

        Mod+Ctrl+Left  { move-column-left; }
        Mod+Ctrl+Down  { move-window-down; }
        Mod+Ctrl+Up    { move-window-up; }
        Mod+Ctrl+Right { move-column-right; }

        Mod+Home { focus-column-first; }
        Mod+End  { focus-column-last; }
        Mod+Ctrl+Home { move-column-to-first; }
        Mod+Ctrl+End  { move-column-to-last; }

        Mod+Shift+Left  { focus-monitor-left; }
        Mod+Shift+Down  { focus-monitor-down; }
        Mod+Shift+Up    { focus-monitor-up; }
        Mod+Shift+Right { focus-monitor-right; }

        Mod+Shift+Ctrl+Left  { move-column-to-monitor-left; }
        Mod+Shift+Ctrl+Down  { move-column-to-monitor-down; }
        Mod+Shift+Ctrl+Up    { move-column-to-monitor-up; }
        Mod+Shift+Ctrl+Right { move-column-to-monitor-right; }

        // Moves the whole workspace, not just the column.
        Mod+Alt+Shift+Left  { move-workspace-to-monitor-left; }
        Mod+Alt+Shift+Down  { move-workspace-to-monitor-down; }
        Mod+Alt+Shift+Up    { move-workspace-to-monitor-up; }
        Mod+Alt+Shift+Right { move-workspace-to-monitor-right; }

        Mod+Page_Down      { focus-workspace-down; }
        Mod+Page_Up        { focus-workspace-up; }
        Mod+U              { focus-workspace-down; }
        Mod+I              { focus-workspace-up; }
        Mod+Ctrl+Page_Down { move-column-to-workspace-down; }
        Mod+Ctrl+Page_Up   { move-column-to-workspace-up; }
        Mod+Ctrl+U         { move-column-to-workspace-down; }
        Mod+Ctrl+I         { move-column-to-workspace-up; }

        Mod+Shift+Page_Down { move-workspace-down; }
        Mod+Shift+Page_Up   { move-workspace-up; }

        Mod+WheelScrollDown      cooldown-ms=150 { focus-workspace-down; }
        Mod+WheelScrollUp        cooldown-ms=150 { focus-workspace-up; }
        Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
        Mod+Ctrl+WheelScrollUp   cooldown-ms=150 { move-column-to-workspace-up; }

        // Swapped: MX Master thumbwheel horizontal direction feels inverted for column nav.
        Mod+WheelScrollRight      { focus-column-left; }
        Mod+WheelScrollLeft       { focus-column-right; }
        Mod+Ctrl+WheelScrollRight { move-column-left; }
        Mod+Ctrl+WheelScrollLeft  { move-column-right; }

        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }
        Mod+0 { focus-workspace 10; }
        Mod+Ctrl+1 { move-column-to-workspace 1; }
        Mod+Ctrl+2 { move-column-to-workspace 2; }
        Mod+Ctrl+3 { move-column-to-workspace 3; }
        Mod+Ctrl+4 { move-column-to-workspace 4; }
        Mod+Ctrl+5 { move-column-to-workspace 5; }
        Mod+Ctrl+6 { move-column-to-workspace 6; }
        Mod+Ctrl+7 { move-column-to-workspace 7; }
        Mod+Ctrl+8 { move-column-to-workspace 8; }
        Mod+Ctrl+9 { move-column-to-workspace 9; }
        Mod+Ctrl+0 { move-column-to-workspace 10; }

        Mod+BracketLeft  { consume-or-expel-window-left; }
        Mod+BracketRight { consume-or-expel-window-right; }
        Mod+Comma  { consume-window-into-column; }
        Mod+Period { expel-window-from-column; }

        // Wraps to the first preset after the last (1/3 -> 1/2 -> 2/3 -> 100% -> ...).
        Mod+R       { switch-preset-column-width; }
        Mod+Shift+R { switch-preset-window-height; }
        Mod+Ctrl+R  { reset-window-height; }

        Mod+F       { maximize-window-to-edges; }
        Mod+Shift+F { fullscreen-window; }
        Mod+M       { maximize-column; }
        Mod+Ctrl+F  { expand-column-to-available-width; }

        Mod+Shift+C { center-column; }
        Mod+Ctrl+C  { center-visible-columns; }

        Mod+Minus { set-column-width "-10%"; }
        Mod+Equal { set-column-width "+10%"; }
        Mod+Shift+Minus { set-window-height "-10%"; }
        Mod+Shift+Equal { set-window-height "+10%"; }

        Mod+V       { toggle-window-floating; }
        Mod+Shift+V { switch-focus-between-floating-and-tiling; }
        Mod+W       { toggle-column-tabbed-display; }

        Print { screenshot; }
        Ctrl+Print { screenshot-screen; }
        Alt+Print { screenshot-window; }

        Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }
        Mod+Shift+E { quit; }
        Ctrl+Alt+Delete { quit; }

        XF86AudioRaiseVolume  allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"; }
        XF86AudioLowerVolume  allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"; }
        XF86AudioMute         allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
        XF86AudioMicMute      allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }
        XF86MonBrightnessUp   allow-when-locked=true { spawn "brightnessctl" "s" "10%+"; }
        XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "s" "10%-"; }

        XF86AudioNext  allow-when-locked=true { spawn-sh "playerctl next"; }
        XF86AudioPause allow-when-locked=true { spawn-sh "playerctl play-pause"; }
        XF86AudioPlay  allow-when-locked=true { spawn-sh "playerctl play-pause"; }
        XF86AudioPrev  allow-when-locked=true { spawn-sh "playerctl previous"; }
    }

    ${extraConfig}
  '';
}
