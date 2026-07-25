_: {
  # v5 config schema (docs.noctalia.dev/v5/configuration) is unrelated to the v4
  # settings.json this was ported from; only settings with a clear v5 equivalent
  # are carried over. Everything else keeps v5's default. Verify with
  # `noctalia config validate` after first build (the home-manager module also
  # runs this automatically).
  programs.noctalia.enable = true;

  programs.noctalia.settings = {
    shell = {
      avatar_path = "/home/rogervn/.face";
      telemetry_enabled = true;
      clipboard_enabled = true;
      clipboard_history_max_entries = 100;
      clipboard_auto_paste = "off";
    };

    theme = {
      mode = "dark";
      source = "wallpaper";
      builtin = "Noctalia";
      wallpaper_scheme = "m3-tonal-spot";
      templates.builtin_ids = [
        "gtk3"
        "gtk4"
        "ghostty"
        "niri"
      ];
    };

    location.address = "London";

    lockscreen = {
      enabled = true;
      fingerprint = true;
    };

    notification = {
      enable_daemon = true;
      show_app_name = true;
      show_actions = true;
      position = "top_right";
      layer = "overlay";
      background_opacity = 1.0;
      collapse_on_dismiss = true;

      # v4 behaviour: notifications always toast, but only normal/critical are
      # saved to history, and sound is off entirely regardless of urgency.
      filter_order = [
        "low_no_history"
        "no_sound"
      ];

      filter.low_no_history = {
        enabled = true;
        match_content = ".*";
        allowed_urgencies = [ "low" ];
        show_toast = true;
        save_history = false;
        play_sound = false;
        override_duration = 2000;
      };

      filter.no_sound = {
        enabled = true;
        match_content = ".*";
        show_toast = true;
        save_history = true;
        play_sound = false;
      };
    };

    wallpaper = {
      enabled = true;
      fill_mode = "crop";
      directory = "~/.config/hypr/wallpaper";
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
      };

      notifications.hide_when_no_unread = false;
    };
  };
}
