_: {
  # v5 config schema (docs.noctalia.dev/v5/configuration) is unrelated to the v4
  # settings.json this was ported from; only settings with a clear v5 equivalent
  # are carried over. Everything else keeps v5's default. Verify with
  # `noctalia config validate` after first build (the home-manager module also
  # runs this automatically).
  programs.noctalia.enable = true;

  # Custom niri template: adds a two-color (gradient) border/focus-ring instead
  # of the builtin's flat active-color. Replaces the "niri" builtin template
  # (see theme.templates below) since noctalia only writes one noctalia.kdl.
  xdg.configFile."noctalia/templates/niri.kdl".text = ''
    layout {

        focus-ring {
            active-gradient from="{{colors.primary_container.default.hex}}" to="{{colors.tertiary.default.hex}}" angle=45 relative-to="workspace-view"
            inactive-color "{{colors.surface.default.hex}}"
            urgent-color "{{colors.error.default.hex}}"
        }

        border {
            active-gradient from="{{colors.primary_container.default.hex}}" to="{{colors.tertiary.default.hex}}" angle=45 relative-to="workspace-view"
            inactive-color "{{colors.surface.default.hex}}"
            urgent-color "{{colors.error.default.hex}}"
        }

        shadow {
            color "{{colors.shadow.default.hex}}70"
        }

        tab-indicator {
            active-gradient from="{{colors.primary_container.default.hex}}" to="{{colors.tertiary.default.hex}}" angle=45 relative-to="workspace-view"
            inactive-color "{{colors.surface.default.hex}}"
            urgent-color "{{colors.error.default.hex}}"
        }

        insert-hint {
            color "{{colors.primary.default.hex}}80"
        }
    }

    recent-windows {
        highlight {
            active-color "{{colors.primary.default.hex}}"
            urgent-color "{{colors.error.default.hex}}"
        }
    }
  '';

  programs.noctalia.settings = {
    shell = {
      avatar_path = "/home/rogervn/.face";
      telemetry_enabled = true;
      clipboard_enabled = true;
      clipboard_history_max_entries = 100;
      clipboard_auto_paste = "off";
      password_style = "random";
    };

    theme = {
      mode = "dark";
      source = "wallpaper";
      builtin = "Noctalia";
      wallpaper_scheme = "m3-content";
      templates.builtin_ids = [
        "gtk3"
        "gtk4"
        "ghostty"
      ];
      templates.user.niri = {
        input_path = "templates/niri.kdl";
        output_path = "$XDG_CONFIG_HOME/niri/noctalia.kdl";
      };
    };

    location.address = "London";

    lockscreen = {
      enabled = true;
      fingerprint = true;
    };

    idle.behavior = {
      lock = {
        enabled = true;
        timeout = 300;
        action = "lock";
      };
      "screen-off" = {
        enabled = true;
        timeout = 330;
        action = "screen_off";
      };
      "lock-and-suspend" = {
        enabled = true;
        timeout = 900;
        action = "lock_and_suspend";
      };
    };

    notification = {
      enable_daemon = true;
      show_app_name = true;
      show_actions = true;
      position = "top_right";
      layer = "overlay";
      background_opacity = 1.0;
      collapse_on_dismiss = true;

      # Keep command-line test notifications brief and out of history. All
      # other notifications remain until dismissed and are saved to history.
      filter_order = [
        "clip_pastry"
        "default"
      ];

      filter.clip_pastry = {
        enabled = true;
        match = "clip-pastry";
        show_toast = true;
        save_history = false;
        override_duration = 2000;
      };

      filter.default = {
        enabled = true;
        match_content = ".*";
        show_toast = true;
        save_history = true;
        override_duration = 0;
      };
    };

    wallpaper = {
      enabled = true;
      fill_mode = "crop";
      directory = "~/.config/wallpapers";
      automation = {
        enabled = true;
        interval_seconds = 7200;
        order = "random";
      };
    };

    dock.enabled = false;

    bar.main = {
      position = "top";
      background_opacity = 0.0;
      capsule = true;
      capsule_padding = 10.0;
      margin_ends = 0;
      start = [
        "control-center"
        "workspaces"
        "weather"
        "cpu"
        "cpu-temp"
        "ram"
        "power_profile"
      ];
      center = [ "active_window" ];
      end = [
        "caffeine"
        "volume"
        "brightness"
        "battery"
        "bluetooth"
        "tray"
        "network"
        "clock"
        "notifications"
        "session"
      ];
    };

    widget = {
      cpu = {
        type = "sysmon";
        stat = "cpu_usage";
      };
      "cpu-temp" = {
        type = "sysmon";
        stat = "cpu_temp";
      };
      ram = {
        type = "sysmon";
        stat = "ram_used";
      };

      clock = {
        format = "{:%a %d %b - %H:%M}";
        tooltip_format = "{:%H:%M %a, %b %d}";
      };

      tray = {
        pinned = [ "nm-applet" ];
        drawer = false;
        scale = 1.2;
      };

      notifications.hide_when_no_unread = false;
    };
  };
}
