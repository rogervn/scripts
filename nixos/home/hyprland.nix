{
  pkgs,
  lib,
  monitors ? [],
  workspaces ? [],
  terminal ? "ghostty",
  fileManager ? "nautilus",
  browser ? "vivaldi",
  locker ? "noctalia-shell ipc call lockScreen lock",
  noteEditor ? "joplin-desktop",
  codeEditor ? "gedit",
  screenshotPath ? "$(xdg-user-dir PICTURES)/Screenshots/$(date +'screenshot_%Y%m%d_%H%M%S.png')",
  clipboardManager ? "cliphist",
  clipboardLauncher ? "noctalia-shell ipc call launcher clipboard",
  appLauncher ? "noctalia-shell ipc call launcher toggle",
  runLauncher ? "noctalia-shell ipc call launcher command",
  notifDismissLast ? "noctalia-shell ipc call notifications dismissOldest",
  notifDismissAll ? "noctalia-shell ipc call notifications clear",
  notifToggle ? "noctalia-shell ipc call notifications toggleHistory",
  wallpaper ? "noctalia-shell ipc call wallpaper random all",
  extraConfig ? "",
  extraEnv ? [],
  ...
}: {
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };

  # systemd.user.services.hyprpolkitagent = {
  #   Unit = {
  #     Description = "Hyprland Polkit Agent";
  #     After = [
  #       "graphical-session.target"
  #       "wayland-session-waitenv.service"
  #       "dbus.service"
  #       "xdg-desktop-portal.service"
  #     ];
  #   };
  #   Service = {
  #     ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
  #     Restart = "on-failure";
  #     Environment = [
  #       "QT_QPA_PLATFORM=wayland"
  #       "QT_PLUGIN_PATH=${pkgs.qt6.qtwayland}/${pkgs.qt6.qtbase.qtPluginPrefix}"
  #     ];
  #   };
  #   Install = {
  #     WantedBy = ["graphical-session.target"];
  #   };
  # };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [xdg-desktop-portal-hyprland xdg-desktop-portal-gtk];
    config = {
      hyprland = {
        default = ["hyprland" "gtk"];
        "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
        "org.freedesktop.impl.portal.Screenshot" = ["hyprland"];
        "org.freedesktop.impl.portal.ScreenCast" = ["hyprland"];
      };
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

    gtk4.theme = null;
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
  };

  # Dconf Settings for Global Dark Mode (Libadwaita/Modern GTK4)
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;

    extraConfig =
      ''
        source = ~/.config/hypr/noctalia/noctalia-colors.conf
        exec-once = uwsm app -- noctalia-shell
        exec-once = uwsm app -- ${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent
        windowrule = float on, match:title Calculator
      ''
      + extraConfig;

    settings = {
      general = {
        border_size = 2;
      };

      decoration = {
        rounding = 10;
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
        blur = {
          enabled = true;
          size = 3;
          vibrancy = 0.1696;
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "easeInOutCubic,0.65,0.05,0.36,1"
          "linear,0,0,1,1"
          "almostLinear,0.5,0.5,0.75,1.0"
          "quick,0.15,0,0.1,1"
        ];
        animation = [
          "global, 1, 10, default"
          "border, 1, 5.39, easeOutQuint"
          "windows, 1, 4.79, easeOutQuint"
          "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.49, linear, popin 87%"
          "fadeIn, 1, 1.73, almostLinear"
          "fadeOut, 1, 1.46, almostLinear"
          "fade, 1, 3.03, quick"
          "layers, 1, 3.81, easeOutQuint"
          "layersIn, 1, 4, easeOutQuint, fade"
          "layersOut, 1, 1.5, linear, fade"
          "fadeLayersIn, 1, 1.79, almostLinear"
          "fadeLayersOut, 1, 1.39, almostLinear"
          "workspaces, 1, 1.94, almostLinear, fade"
          "workspacesIn, 1, 1.21, almostLinear, fade"
          "workspacesOut, 1, 1.94, almostLinear, fade"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };
      master.new_status = "master";
      misc.force_default_wallpaper = -1;

      env =
        [
          "XCURSOR_SIZE,24"
          "HYPRCURSOR_SIZE,24"
        ]
        ++ extraEnv;

      input = {
        kb_layout = "us";
        numlock_by_default = true;
      };

      monitor = monitors;
      workspace = workspaces;

      "$mainMod" = "SUPER";
      "$terminal" = terminal;
      "$fileManager" = fileManager;
      "$browser" = browser;
      "$locker" = locker;
      "$noteEditor" = noteEditor;
      "$codeEditor" = codeEditor;
      "$screenshot_file" = screenshotPath;
      "$clipboardManager" = clipboardManager;
      "$clipboardLauncher" = clipboardLauncher;
      "$appLauncher" = appLauncher;
      "$runLauncher" = runLauncher;
      "$dismissLastNotification" = notifDismissLast;
      "$dismissAllNotification" = notifDismissAll;
      "$toggleNotification" = notifToggle;
      "$wallpaperChange" = wallpaper;

      exec-once = [
        "uwsm app -- blueman-applet"
        "uwsm app -- nm-applet"
      ];

      bind = let
        n = toString;
        wsBinds =
          builtins.concatLists (map (i: [
            "$mainMod, ${n i}, workspace, ${n i}"
            "$mainMod SHIFT, ${n i}, movetoworkspace, ${n i}"
          ]) (lib.range 1 9))
          ++ [
            "$mainMod, 0, workspace, 10"
            "$mainMod SHIFT, 0, movetoworkspace, 10"
          ];
        monitorNumBinds =
          lib.imap0
          (i: key: "CTRL $mainMod, ${n key}, movecurrentworkspacetomonitor, ${n i}")
          [1 2 3 4 5];
      in
        [
          "$mainMod, return, exec, $terminal"
          "$mainMod, q, killactive,"
          "$mainMod, f, fullscreen,"
          "$mainMod, E, exec, $fileManager"
          "$mainMod, V, togglefloating,"
          "$mainMod, space, exec, $appLauncher"
          "$mainMod, d, exec, $runLauncher"
          "$mainMod, b, exec, $browser"
          "$mainMod, x, exec, $codeEditor"
          "$mainMod, t, exec, $noteEditor"
          "$mainMod, c, exec, $clipboardLauncher"
          "$mainMod, w, exec, $wallpaperChange"
          ''$mainMod, p, exec, grim -g "$(slurp)" $screenshot_file''
          "$mainMod SHIFT, p, exec, grim -o $(hyprctl -j activeworkspace | jq '.monitor') $screenshot_file"
          "$mainMod, n, exec, $toggleNotification"
          "$mainMod SHIFT, n, exec, $dismissLastNotification"
          "$mainMod CTRL SHIFT, n, exec, $dismissAllNotification"
          "$mainMod SHIFT, s, exec, systemctl poweroff -i"
          "$mainMod SHIFT, u, exec, systemctl suspend"
          "$mainMod SHIFT, r, exec, systemctl reboot"
          "$mainMod SHIFT, h, exec, systemctl hybernate"
          "$mainMod SHIFT, e, exec, uwsm stop"
          "$mainMod, l, exec, $locker"
          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"
          "$mainMod SHIFT, left, movewindow, l"
          "$mainMod SHIFT, right, movewindow, r"
          "$mainMod SHIFT, up, movewindow, u"
          "$mainMod SHIFT, down, movewindow, d"
          "CTRL $mainMod, left, movecurrentworkspacetomonitor, l"
          "CTRL $mainMod, right, movecurrentworkspacetomonitor, r"
          "$mainMod, S, togglespecialworkspace, magic"
          "$mainMod SHIFT, S, movetoworkspace, special:magic"
          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"
        ]
        ++ wsBinds ++ monitorNumBinds;

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      bindel = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, brightnessctl s 10%+"
        ",XF86MonBrightnessDown, exec, brightnessctl s 10%-"
      ];

      bindl = [
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      windowrule = ["suppress_event maximize, match:class .*"];
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "noctalia-shell ipc call lockScreen lock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 330;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 900;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
