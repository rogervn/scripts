{
  pkgs,
  lib,
  # { output, mode ? "preferred", position ? "auto", scale ? 1,
  #   transform ? 0, vrr ? 0 }; use `desc:` in output for EDID descriptions.
  monitors ? [ ],
  # { name ? null, id ? null, output ? null, vertical ? false, default ? false,
  #   persistent ? false }. `vertical` enables the native scrolling layout's
  # top-to-bottom tape.
  workspaces ? [ ],
  terminal ? "ghostty",
  fileManager ? "nautilus",
  browser ? "vivaldi",
  locker ? "noctalia msg session lock",
  noteEditor ? "joplin-desktop",
  codeEditor ? "gedit",
  screenshotPath ? "$(xdg-user-dir PICTURES)/Screenshots/$(date +'screenshot_%Y%m%d_%H%M%S.png')",
  clipboardLauncher ? "noctalia msg panel-toggle clipboard",
  appLauncher ? "noctalia msg panel-toggle launcher",
  runLauncher ? "noctalia msg panel-toggle launcher",
  notifClearActive ? "noctalia msg notification-clear-active",
  notifClearHistory ? "noctalia msg notification-clear-history",
  notifToggle ? "noctalia msg panel-toggle control-center notifications",
  wallpaper ? "noctalia msg wallpaper-random",
  ...
}:
let
  inherit (lib.generators) mkLuaInline;
  q = builtins.toJSON;
  dispatcher = mkLuaInline;
  bind = keys: action: {
    _args = [
      keys
      (dispatcher action)
    ];
  };
  bindWith = keys: action: flags: {
    _args = [
      keys
      (dispatcher action)
      flags
    ];
  };
  command = keys: cmd: bind keys "hl.dsp.exec_cmd(${q cmd})";
  focus = direction: "hl.dsp.layout(\"focus ${direction}\")";
  # Native scrolling has no `movewindowto` layout message.  The normal window
  # move dispatcher is layout-aware and is the supported equivalent.
  move = direction: "hl.dsp.window.move({ direction = \"${direction}\" })";
  workspaceBinds = lib.concatMap (i: [
    (bind "SUPER + ${toString i}" "hl.dsp.focus({ workspace = \"${toString i}\" })")
    (bind "SUPER + CTRL + ${toString i}" "hl.dsp.window.move({ workspace = \"${toString i}\" })")
  ]) (lib.range 1 9);
  directionBinds =
    lib.concatMap
      (
        direction:
        let
          inherit (direction) key value;
        in
        [
          (bind "SUPER + ${key}" (focus value))
          (bind "SUPER + CTRL + ${key}" "hl.dsp.window.swap({ direction = \"${value}\" })")
          (bind "SUPER + SHIFT + ${key}" "hl.dsp.focus({ monitor = \"${value}\" })")
          (bind "SUPER + CTRL + SHIFT + ${key}" "hl.dsp.workspace.move({ monitor = \"${value}\" })")
        ]
      )
      [
        {
          key = "Left";
          value = "l";
        }
        {
          key = "Down";
          value = "d";
        }
        {
          key = "Up";
          value = "u";
        }
        {
          key = "Right";
          value = "r";
        }
      ];
  startup = dispatcher ''
    function()
      hl.exec_cmd(${q "uwsm finalize"})
      hl.exec_cmd(${q "uwsm app -- noctalia"})
    end
  '';
  groupNext = ''
    function()
      local window = hl.get_active_window()
      local group = window and window.group
      if group and group.current_index < group.size then
        hl.dispatch(hl.dsp.group.active({ index = group.current_index + 1 }))
      end
    end
  '';
  groupPrevious = ''
    function()
      local window = hl.get_active_window()
      local group = window and window.group
      if group and group.current_index > 1 then
        hl.dispatch(hl.dsp.group.active({ index = group.current_index - 1 }))
      end
    end
  '';
  toggleColumnFullWidth = ''
    (function()
      local previousWidths = {}

      return function()
        local window = hl.get_active_window()
        local layout = window and window.layout
        local column = layout and layout.column
        if not column or layout.name ~= "scrolling" then
          return
        end

        local firstWindow = column.windows[1]
        local key = firstWindow and firstWindow.stable_id
        if not key then
          return
        end

        if column.width >= 0.999 then
          local width = previousWidths[key] or 0.5
          previousWidths[key] = nil
          hl.dispatch(hl.dsp.layout("colresize " .. width))
        else
          previousWidths[key] = column.width
          hl.dispatch(hl.dsp.layout("colresize 1"))
        end
      end
    end)()
  '';
in
{
  imports = [ ./window_manager_appearance.nix ];

  home.packages = with pkgs; [
    brightnessctl
    jq
    playerctl
  ];

  services = {
    blueman-applet.enable = true;
    network-manager-applet.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config.hyprland = {
      default = [
        "hyprland"
        "gtk"
      ];
      "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    systemd.enable = false;
    extraConfig = ''
      local xdg_config_home = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
      local noctalia_file = io.open(xdg_config_home .. "/hypr/noctalia.lua", "r")
      if noctalia_file then
        noctalia_file:close()
        require("noctalia").apply_theme()
      end
    '';

    # Home Manager renders every entry below to the corresponding `hl.*` Lua
    # call in ~/.config/hypr/hyprland.lua.
    settings = {
      config = {
        general = {
          layout = "scrolling";
          border_size = 4;
          "col.active_border" = "rgb(89b4fa)";
          "col.inactive_border" = "rgb(45475a)";
          allow_tearing = true;
        };
        scrolling = {
          follow_min_visible = 0.0;
          wrap_focus = false;
          wrap_swapcol = false;
        };
        decoration = {
          rounding = 10;
          blur = {
            size = 3;
            passes = 3;
            noise = 0.02;
          };
        };
        group = {
          auto_group = false;
          groupbar = {
            disable_when_only = true;
            render_titles = false;
            height = 6;
            indicator_height = 1;
            rounding = 3;
          };
        };
        input = {
          numlock_by_default = true;
          follow_mouse_shrink = 24;
          touchpad.scroll_factor = 0.8;
        };
        gestures.workspace_swipe_invert = false;
        binds = {
          scroll_event_delay = 150;
          window_direction_monitor_fallback = false;
        };
        misc = {
          force_default_wallpaper = 0;
          disable_hyprland_logo = true;
          focus_on_activate = true;
        };
      };

      env = [
        {
          _args = [
            "GIO_EXTRA_MODULES"
            "${pkgs.dconf.lib}/lib/gio/modules"
          ];
        }
      ];
      monitor = monitors;
      gesture = [
        {
          fingers = 3;
          direction = "horizontal";
          action = "scroll_move";
        }
        {
          fingers = 3;
          direction = "vertical";
          action = "scroll_move";
        }
        {
          fingers = 4;
          direction = "vertical";
          action = "workspace";
        }
      ];
      curve = [
        {
          _args = [
            "easy"
            {
              type = "spring";
              mass = 1;
              stiffness = 238.1191;
              dampening = 24.21279333;
            }
          ];
        }
      ];
      animation = [
        {
          leaf = "windows";
          enabled = true;
          speed = 4.79;
          spring = "easy";
          style = "slide";
        }
        {
          leaf = "windowsMove";
          enabled = true;
          speed = 4.79;
          spring = "easy";
        }
        {
          leaf = "workspaces";
          enabled = true;
          speed = 4.79;
          spring = "easy";
          style = "slidevert";
        }
      ];
      workspace_rule = map (
        workspace:
        (lib.optionalAttrs ((workspace.output or null) != null) { monitor = workspace.output; })
        // (lib.optionalAttrs (workspace.vertical or false) { layout_opts.direction = "down"; })
        // (lib.optionalAttrs (workspace.default or false) { default = true; })
        // (lib.optionalAttrs (workspace.persistent or false) { persistent = true; })
        // {
          workspace =
            if (workspace.id or null) != null then toString workspace.id else "name:${workspace.name}";
        }
      ) workspaces;

      window_rule = [
        {
          match.class = "org.gnome.Calculator";
          float = true;
        }
        {
          match.class = "^steam_app_";
          immediate = true;
        }
        {
          match.class = "^(mpv|vlc)$";
          immediate = true;
        }
      ];
      layer_rule = [
        {
          match.namespace = "^noctalia-bar-main$";
          blur = false;
          ignore_alpha = 1.0;
        }
        {
          match.namespace = "^noctalia-.*click-shield$";
          blur = false;
        }
      ];

      on = {
        _args = [
          "hyprland.start"
          startup
        ];
      };

      bind = [
        (command "SUPER + Return" terminal)
        (command "SUPER + T" noteEditor)
        (command "SUPER + D" runLauncher)
        (command "SUPER + E" fileManager)
        (command "SUPER + B" browser)
        (command "SUPER + X" codeEditor)
        (command "SUPER + Space" appLauncher)
        (command "SUPER + C" clipboardLauncher)
        (command "SUPER + SHIFT + W" wallpaper)
        (command "SUPER + L" locker)
        (command "SUPER + N" notifToggle)
        (command "SUPER + SHIFT + N" notifClearActive)
        (command "SUPER + CTRL + SHIFT + N" notifClearHistory)
        (command "SUPER + P" "grim -g \"$(slurp)\" ${screenshotPath}")
        (command "SUPER + SHIFT + P" "grim -o $(hyprctl -j focusedmonitor | jq -r .name) ${screenshotPath}")
        (command "SUPER + SHIFT + S" "systemctl poweroff -i")
        (command "SUPER + SHIFT + U" "systemctl suspend")
        (command "SUPER + SHIFT + B" "systemctl reboot")
        (command "SUPER + SHIFT + Y" "systemctl hibernate")
        (command "SUPER + SHIFT + E" "uwsm stop")

        (bind "SUPER + Q" "hl.dsp.window.close()")
        (command "SUPER + O" appLauncher)
        (bind "SUPER + V" "hl.dsp.window.float()")
        (bind "SUPER + F" toggleColumnFullWidth)
        (bind "SUPER + SHIFT + F" "hl.dsp.window.fullscreen({ mode = \"fullscreen\" })")
        (bind "SUPER + W" "hl.dsp.group.toggle()")

        (bind "SUPER + BracketLeft" "hl.dsp.layout(\"consume_or_expel prev\")")
        (bind "SUPER + BracketRight" "hl.dsp.layout(\"consume_or_expel next\")")
        (bind "SUPER + Comma" "hl.dsp.layout(\"consume\")")
        (bind "SUPER + Period" "hl.dsp.layout(\"expel\")")
        (bind "SUPER + SHIFT + Comma" "hl.dsp.window.move({ into_or_create_group = \"l\" })")
        (bind "SUPER + SHIFT + Period" "hl.dsp.window.move({ out_of_group = true })")
        (bind "SUPER + R" "hl.dsp.layout(\"colresize +conf\")")
        (bind "SUPER + Minus" "hl.dsp.layout(\"colresize -0.1\")")
        (bind "SUPER + Equal" "hl.dsp.layout(\"colresize +0.1\")")
        (bind "SUPER + SHIFT + C" "hl.dsp.layout(\"fit active\")")
        (bind "SUPER + CTRL + C" "hl.dsp.layout(\"fit visible\")")

        (bind "SUPER + Page_Down" groupNext)
        (bind "SUPER + Page_Up" groupPrevious)
        (bind "SUPER + U" "hl.dsp.focus({ workspace = \"e+1\" })")
        (bind "SUPER + I" "hl.dsp.focus({ workspace = \"e-1\" })")
        (bind "SUPER + CTRL + Page_Down" "hl.dsp.window.move({ workspace = \"e+1\" })")
        (bind "SUPER + CTRL + Page_Up" "hl.dsp.window.move({ workspace = \"e-1\" })")
        (bind "SUPER + CTRL + U" "hl.dsp.window.move({ workspace = \"e+1\" })")
        (bind "SUPER + CTRL + I" "hl.dsp.window.move({ workspace = \"e-1\" })")
        (bind "SUPER + SHIFT + mouse_down" "hl.dsp.focus({ workspace = \"m+1\" })")
        (bind "SUPER + SHIFT + mouse_up" "hl.dsp.focus({ workspace = \"m-1\" })")
        (bind "SUPER + mouse_down" "hl.dsp.layout(\"move +col\")")
        (bind "SUPER + mouse_up" "hl.dsp.layout(\"move -col\")")
        (bind "SUPER + CTRL + mouse_down" "hl.dsp.window.move({ workspace = \"e+1\" })")
        (bind "SUPER + CTRL + mouse_up" "hl.dsp.window.move({ workspace = \"e-1\" })")
        (bind "SUPER + mouse_right" "hl.dsp.layout(\"move +col\")")
        (bind "SUPER + mouse_left" "hl.dsp.layout(\"move -col\")")
        (bind "SUPER + CTRL + mouse_right" (move "r"))
        (bind "SUPER + CTRL + mouse_left" (move "l"))
        (bind "SUPER + 0" "hl.dsp.focus({ workspace = \"10\" })")
        (bind "SUPER + CTRL + 0" "hl.dsp.window.move({ workspace = \"10\" })")
        (bind "SUPER + S" "hl.dsp.workspace.toggle_special(\"magic\")")
        (bind "SUPER + CTRL + S" "hl.dsp.window.move({ workspace = \"special:magic\" })")
        (bindWith "SUPER + mouse:272" "hl.dsp.window.drag()" { mouse = true; })
        (bindWith "SUPER + mouse:273" "hl.dsp.window.resize()" { mouse = true; })
        (command "Print" "grim ${screenshotPath}")
      ]
      ++ directionBinds
      ++ workspaceBinds
      ++ [
        (bindWith "XF86AudioRaiseVolume" "hl.dsp.exec_cmd(\"wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+\")" {
          repeating = true;
          locked = true;
        })
        (bindWith "XF86AudioLowerVolume" "hl.dsp.exec_cmd(\"wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-\")" {
          repeating = true;
          locked = true;
        })
        (bindWith "XF86AudioMute" "hl.dsp.exec_cmd(\"wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle\")" {
          locked = true;
        })
        (bindWith "XF86AudioMicMute" "hl.dsp.exec_cmd(\"wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle\")" {
          locked = true;
        })
        (bindWith "XF86MonBrightnessUp" "hl.dsp.exec_cmd(\"brightnessctl s 10%+\")" {
          repeating = true;
          locked = true;
        })
        (bindWith "XF86MonBrightnessDown" "hl.dsp.exec_cmd(\"brightnessctl s 10%-\")" {
          repeating = true;
          locked = true;
        })
        (bindWith "XF86AudioNext" "hl.dsp.exec_cmd(\"playerctl next\")" { locked = true; })
        (bindWith "XF86AudioPause" "hl.dsp.exec_cmd(\"playerctl play-pause\")" { locked = true; })
        (bindWith "XF86AudioPlay" "hl.dsp.exec_cmd(\"playerctl play-pause\")" { locked = true; })
        (bindWith "XF86AudioPrev" "hl.dsp.exec_cmd(\"playerctl previous\")" { locked = true; })
      ];
    };
  };
}
