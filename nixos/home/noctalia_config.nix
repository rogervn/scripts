_:
let
  rightCapsuleGroups = [
    {
      id = "connectivity";
      widget_spacing = 10;
      members = [
        "network"
        "bluetooth"
      ];
    }
    {
      id = "device-status";
      widget_spacing = 10;
      members = [
        "privacy"
        "volume"
        "input_volume"
        "brightness"
        "battery"
      ];
    }
    {
      id = "clock-session";
      widget_spacing = 10;
      members = [
        "clock"
        "notifications"
        "session"
      ];
    }
  ];
  sysmonFullGroup = {
    id = "sysmon-full";
    widget_spacing = 10;
    members = [
      "cpu"
      "cpu-temp"
      "ram"
      "disk"
      "power_profile"
      "caffeine"
    ];
  };
  sysmonShortGroup = {
    id = "sysmon-short";
    widget_spacing = 10;
    members = [
      "sysmon-short-cpu"
      "sysmon-short-cpu-temp"
      "sysmon-short-ram"
      "sysmon-short-disk"
      "power_profile"
      "caffeine"
    ];
  };
  portraitBar = {
    start = [
      "control-center"
      "workspaces"
      "weather"
      "group:sysmon-short"
    ];
    center = [ "active_window" ];
    end = [
      "group:device-status"
      "group:connectivity"
      "group:clock-session"
    ];
    capsule_group = [ sysmonShortGroup ] ++ rightCapsuleGroups;
  };
  lowResBar = {
    start = [
      "control-center"
      "workspaces"
      "weather"
      "group:sysmon-short"
    ];
    center = [ "active_window" ];
    end = [
      "group:device-status"
      "tray-short"
      "group:connectivity"
      "group:clock-session"
    ];
    capsule_group = [ sysmonShortGroup ] ++ rightCapsuleGroups;
  };
in
{
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
      niri_overview_type_to_launch_enabled = true;
      password_style = "random";
      panel = {
        transparency_mode = "glass";
        control_center_placement = "floating";
        control_center_position = "auto";
      };
    };

    backdrop = {
      enabled = true;
      blur_intensity = 0.5;
      tint_intensity = 0.3;
    };

    theme = {
      mode = "dark";
      source = "wallpaper";
      builtin = "Noctalia";
      wallpaper_scheme = "m3-content";
      templates.builtin_ids = [ "ghostty" ];
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
        "group:sysmon-full"
      ];
      center = [ "active_window" ];
      end = [
        "group:device-status"
        "tray"
        "group:connectivity"
        "group:clock-session"
      ];
      capsule_group = [ sysmonFullGroup ] ++ rightCapsuleGroups;
      monitor = {
        # Noctalia matches whole-word substrings of the Wayland description;
        # omit connector names and serial numbers so these survive replugging.
        "DELL UP3017" = portraitBar;
        "DELL P2317H" = portraitBar;
        "0x0791" = lowResBar;
      };
    };

    widget = {
      active_window = {
        max_length = 180;
        title_scroll = "on_hover";
      };

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
      disk = {
        type = "sysmon";
        stat = "disk_used";
      };

      sysmon-short-cpu = {
        type = "sysmon";
        stat = "cpu_usage";
        visualization = "none";
        show_value = true;
      };
      sysmon-short-cpu-temp = {
        type = "sysmon";
        stat = "cpu_temp";
        visualization = "none";
        show_value = true;
      };
      sysmon-short-ram = {
        type = "sysmon";
        stat = "ram_pct";
        visualization = "none";
        show_value = true;
      };
      sysmon-short-disk = {
        type = "sysmon";
        stat = "disk_used_pct";
        visualization = "none";
        show_value = true;
      };

      input_volume = {
        type = "volume";
        device = "input";
      };

      clock = {
        format = "{:%a %d %b - %H:%M}";
        tooltip_format = "{:%H:%M %a, %b %d}";
      };

      tray = {
        drawer = false;
        scale = 1.2;
      };
      tray-short = {
        type = "tray";
        drawer = true;
        scale = 1.2;
      };

      notifications.hide_when_no_unread = false;

      privacy.hide_inactive = true;
    };
  };
}
