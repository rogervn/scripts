{
  pkgs,
  lib,
  # { output, mode ? "preferred", position ? "auto", scale ? 1,
  #   transform ? 0, vrr ? 0 }; use `desc:` in output for EDID descriptions.
  monitors ? [ ],
  # { name, output ? null, vertical ? false }. `vertical` enables the native
  # scrolling layout's top-to-bottom tape for that workspace.
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
          horizontal = builtins.elem value [
            "l"
            "r"
          ];
        in
        [
          (bind "SUPER + ${key}" (focus value))
          (bind "SUPER + CTRL + ${key}" (
            if horizontal then "hl.dsp.window.swap({ direction = \"${value}\" })" else move value
          ))
          (bind "SUPER + SHIFT + ${key}" "hl.dsp.focus({ monitor = \"${value}\" })")
          (bind "SUPER + CTRL + SHIFT + ${key}" "hl.dsp.window.move({ monitor = \"${value}\" })")
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
in
{
  imports = [ ./window_manager_appearance.nix ];

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
          column_width = 0.5;
          explicit_column_widths = "0.33333, 0.5, 0.66667, 1.0";
          # A single scrolling column fills the output; focus keeps the
          # column in view instead of re-centering the whole tape.
          fullscreen_on_one_column = true;
          focus_fit_method = 1;
          follow_focus = true;
          follow_min_visible = 0.4;
          wrap_focus = false;
          wrap_swapcol = false;
          direction = "right";
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
            passes = 3;
            noise = 0.02;
          };
        };
        group = {
          auto_group = false;
          groupbar.disable_when_only = true;
        };
        input = {
          kb_layout = "us";
          numlock_by_default = true;
          follow_mouse = 1;
          natural_scroll = false;
          touchpad = {
            tap_to_click = true;
            disable_while_typing = true;
            scroll_factor = 0.8;
            natural_scroll = false;
          };
        };
        gestures.workspace_swipe_invert = false;
        binds.scroll_event_delay = 150;
        misc = {
          force_default_wallpaper = 0;
          disable_hyprland_logo = true;
        };
      };

      monitor = monitors;
      curve = [
        {
          _args = [
            "workspace-slide"
            {
              type = "bezier";
              points = [
                [
                  0.25
                  0.1
                ]
                [
                  0.25
                  1.0
                ]
              ];
            }
          ];
        }
      ];
      animation = [
        {
          leaf = "workspaces";
          enabled = true;
          speed = 6;
          bezier = "workspace-slide";
          style = "slidevert";
        }
      ];
      gesture = [
        {
          fingers = 3;
          direction = "horizontal";
          action = "scroll_move";
        }
        {
          fingers = 3;
          direction = "vertical";
          action = "workspace";
        }
      ];
      workspace_rule = map (
        workspace:
        (lib.optionalAttrs ((workspace.output or null) != null) { monitor = workspace.output; })
        // (lib.optionalAttrs (workspace.vertical or false) { layout_opts.direction = "down"; })
        // {
          workspace = workspace.name;
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
          match.namespace = "^noctalia-bar-";
          blur = false;
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
        (bind "SUPER + F" "hl.dsp.window.fullscreen({ mode = \"maximized\" })")
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

        (bind "SUPER + Page_Down" "hl.dsp.group.next()")
        (bind "SUPER + Page_Up" "hl.dsp.group.prev()")
        (bind "SUPER + U" "hl.dsp.focus({ workspace = \"e+1\" })")
        (bind "SUPER + I" "hl.dsp.focus({ workspace = \"e-1\" })")
        (bind "SUPER + CTRL + Page_Down" "hl.dsp.window.move({ workspace = \"e+1\" })")
        (bind "SUPER + CTRL + Page_Up" "hl.dsp.window.move({ workspace = \"e-1\" })")
        (bind "SUPER + CTRL + U" "hl.dsp.window.move({ workspace = \"e+1\" })")
        (bind "SUPER + CTRL + I" "hl.dsp.window.move({ workspace = \"e-1\" })")
        (bind "SUPER + mouse_down" "hl.dsp.focus({ workspace = \"e+1\" })")
        (bind "SUPER + mouse_up" "hl.dsp.focus({ workspace = \"e-1\" })")
        (bind "SUPER + CTRL + mouse_down" "hl.dsp.window.move({ workspace = \"e+1\" })")
        (bind "SUPER + CTRL + mouse_up" "hl.dsp.window.move({ workspace = \"e-1\" })")
        (bind "SUPER + mouse_right" (focus "r"))
        (bind "SUPER + mouse_left" (focus "l"))
        (bind "SUPER + CTRL + mouse_right" (move "r"))
        (bind "SUPER + CTRL + mouse_left" (move "l"))
        (bind "SUPER + 0" "hl.dsp.focus({ workspace = \"10\" })")
        (bind "SUPER + CTRL + 0" "hl.dsp.window.move({ workspace = \"10\" })")
        (bind "SUPER + S" "hl.dsp.workspace.toggle_special(\"magic\")")
        (bind "SUPER + SHIFT + S" "hl.dsp.window.move({ workspace = \"special:magic\" })")
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
