{
  pkgs,
  lib,
  monitors ? [ ],
  autostartApps ? [ ],
  enableBlur ? true,
  ...
}:
let
  autostart = lib.concatMapStringsSep "\n" (app: "${app} &") autostartApps;

  formatMonitor = monitor:
    lib.concatStringsSep "," (
      (lib.optional (monitor ? name) "name:${monitor.name}")
      ++ (lib.optional (monitor ? make) "make:${monitor.make}")
      ++ (lib.optional (monitor ? model) "model:${monitor.model}")
      ++ (lib.optional (monitor ? serial) "serial:${monitor.serial}")
      ++ [
        "width:${toString monitor.width}"
        "height:${toString monitor.height}"
        "refresh:${toString monitor.refresh}"
        "x:${toString monitor.x}"
        "y:${toString monitor.y}"
        "scale:${toString monitor.scale}"
      ]
      ++ (lib.optional (monitor ? vrr) "vrr:${if monitor.vrr then "1" else "0"}")
      ++ (lib.optional (monitor ? transform) "rr:${toString monitor.transform}")
    );

  monitorRules = map formatMonitor monitors;
  tagIds = lib.range 1 9;
  formatMonitorTagMatch = monitor:
    lib.concatStringsSep "," (
      (lib.optional (monitor ? name) "monitor_name:${monitor.name}")
      ++ (lib.optional (monitor ? make) "monitor_make:${monitor.make}")
      ++ (lib.optional (monitor ? model) "monitor_model:${monitor.model}")
      ++ (lib.optional (monitor ? serial) "monitor_serial:${monitor.serial}")
    );
  verticalScrollerRules = lib.concatMap (
    monitor:
    lib.optionals (
      (monitor.verticalScroller or false)
      || lib.elem (monitor.transform or 0) [ 1 3 ]
    ) (
      map (
        id:
        "id:${toString id},${formatMonitorTagMatch monitor},layout_name:vertical_scroller"
      ) tagIds
    )
  ) monitors;

  settings = {
      numlockon = 1;
      env = [ "GIO_EXTRA_MODULES,${pkgs.dconf.lib}/lib/gio/modules" ];
      trackpad_scroll_factor = 0.8;
      axis_bind_apply_timeout = 150;

      border_radius = 10;
      gappih = 8;
      gappiv = 8;
      gappoh = 8;
      gappov = 8;
      focuscolor = "0x89b4faff";
      bordercolor = "0x45475aff";
      rootcolor = "0x1e1e2eff";
      "source-optional" = "~/.config/mango/noctalia.conf";
      # Keep only a compact active-tab marker, not a title bar.
      group_bar_height = 6;
      group_bar_decorate_font_desc = "monospace 6";
      group_bar_decorate_fg_color = "0xcdd6f400";
      group_bar_decorate_bg_color = "0x00000000";
      group_bar_decorate_focus_fg_color = "0xcdd6f400";
      group_bar_decorate_focus_bg_color = "0x89b4faff";
      group_bar_decorate_border_width = 0;
      group_bar_decorate_padding_x = 0;
      group_bar_decorate_padding_y = 0;
      animation_type_open = "zoom";
      blur = if enableBlur then 1 else 0;
      # Blur Noctalia's transparent layer surfaces when blur is enabled.
      blur_layer = if enableBlur then 1 else 0;
      blur_params_radius = 3;
      blur_params_num_passes = 3;
      blur_params_noise = 0.02;
      blur_params_saturation = 1.5;
      allow_tearing = 2;

      scroller_default_proportion = 0.5;
      scroller_prefer_overspread = 0;
      scroller_ignore_proportion_single = 0;
      scroller_proportion_preset = "1.0,0.66667,0.5,0.33333";
      tagrule = (map (id: "id:${toString id},layout_name:scroller") tagIds) ++ verticalScrollerRules;

      windowrule = [
        "isfloating:1,appid:org.gnome.Calculator"
        "force_tearing:1,appid:^steam_app_.*"
        "force_tearing:1,appid:^(mpv|vlc)$"
      ];

      bind = [
        "SUPER+SHIFT,slash,spawn_shell,noctalia msg panel-toggle keybind-cheatsheet"
        "SUPER,Return,spawn,ghostty"
        "SUPER,t,spawn,joplin-desktop"
        "SUPER,d,spawn_shell,noctalia msg panel-toggle launcher"
        "SUPER,e,spawn,nautilus"
        "SUPER,b,spawn,vivaldi"
        "SUPER,x,spawn,gedit"
        "SUPER,space,spawn_shell,noctalia msg panel-toggle launcher"
        "SUPER,c,spawn_shell,noctalia msg panel-toggle clipboard"
        "SUPER+CTRL,w,spawn_shell,noctalia msg wallpaper-random"
        "SUPER,l,spawn_shell,noctalia msg session lock"
        "SUPER,n,spawn_shell,noctalia msg panel-toggle control-center notifications"
        "SUPER,comma,spawn_shell,noctalia msg settings-toggle"
        "SUPER+SHIFT,n,spawn_shell,noctalia msg notification-clear-active"
        "SUPER+CTRL+SHIFT,n,spawn_shell,noctalia msg notification-clear-history"
        "SUPER,p,spawn_shell,grim -g \"$(slurp)\" \"$(xdg-user-dir PICTURES)/Screenshots/screenshot_$(date +%Y%m%d_%H%M%S).png\""
        "SUPER+SHIFT,p,spawn_shell,grim -o \"$(mmsg -j get focusedmon | jq -r .name)\" \"$(xdg-user-dir PICTURES)/Screenshots/screenshot_$(date +%Y%m%d_%H%M%S).png\""
        "SUPER+SHIFT,s,spawn,systemctl poweroff -i"
        "SUPER+SHIFT,u,spawn,systemctl suspend"
        "SUPER+SHIFT,b,spawn,systemctl reboot"
        "SUPER+SHIFT,y,spawn,systemctl hibernate"
        "SUPER+SHIFT,m,sleep_toggle_monitor,all"
        "SUPER+SHIFT,e,quit"
        "CTRL+ALT,Delete,quit"

        "SUPER,q,killclient"
        "SUPER,o,toggleoverview"
        # Mango does not watch config.conf; reload after a Home Manager switch.
        "SUPER+CTRL,r,reload_config"
        "SUPER,left,focusdir,left"
        "SUPER,down,focusdir,down"
        "SUPER,up,focusdir,up"
        "SUPER,right,focusdir,right"
        "SUPER+CTRL,left,exchange_client,left"
        "SUPER+CTRL,down,exchange_client,down"
        "SUPER+CTRL,up,exchange_client,up"
        "SUPER+CTRL,right,exchange_client,right"
        "SUPER+CTRL+SHIFT,left,tagmon,left,1"
        "SUPER+CTRL+SHIFT,down,tagmon,down,1"
        "SUPER+CTRL+SHIFT,up,tagmon,up,1"
        "SUPER+CTRL+SHIFT,right,tagmon,right,1"
        "SUPER+SHIFT,left,groupfocus,prev"
        "SUPER+SHIFT,right,groupfocus,next"
        "SUPER,u,viewtoleft_have_client"
        "SUPER,i,viewtoright_have_client"
        "SUPER+CTRL,u,tagtoleft"
        "SUPER+CTRL,i,tagtoright"
        "SUPER,v,togglefloating"
        "SUPER,f,togglemaximizescreen"
        "SUPER+SHIFT,f,togglefullscreen"
        "SUPER,w,groupjoin,right"
        "SUPER+SHIFT,w,groupleave"
        "SUPER,r,switch_proportion_preset"
        "SUPER,minus,setmfact,-0.05"
        "SUPER,equal,setmfact,+0.05"
        "SUPER,bracketleft,scroller_stack,left"
        "SUPER,bracketright,scroller_stack,right"
        "SUPER,period,scroller_stack,right"
        "SUPER+SHIFT,c,centerwin"

        "SUPER,1,view,1"
        "SUPER,2,view,2"
        "SUPER,3,view,3"
        "SUPER,4,view,4"
        "SUPER,5,view,5"
        "SUPER,6,view,6"
        "SUPER,7,view,7"
        "SUPER,8,view,8"
        "SUPER,9,view,9"
        "SUPER+CTRL,1,tag,1"
        "SUPER+CTRL,2,tag,2"
        "SUPER+CTRL,3,tag,3"
        "SUPER+CTRL,4,tag,4"
        "SUPER+CTRL,5,tag,5"
        "SUPER+CTRL,6,tag,6"
        "SUPER+CTRL,7,tag,7"
        "SUPER+CTRL,8,tag,8"
        "SUPER+CTRL,9,tag,9"

        "NONE,Print,spawn_shell,grim \"$(xdg-user-dir PICTURES)/Screenshots/Screenshot from $(date +%Y-%m-%d_%H-%M-%S).png\""
        "CTRL,Print,spawn_shell,grim -g \"$(slurp)\" \"$(xdg-user-dir PICTURES)/Screenshots/Screenshot from $(date +%Y-%m-%d_%H-%M-%S).png\""
        "ALT,Print,spawn_shell,grim -g \"$(slurp)\" \"$(xdg-user-dir PICTURES)/Screenshots/Screenshot from $(date +%Y-%m-%d_%H-%M-%S).png\""
      ];

      bindl = [
        "NONE,XF86AudioRaiseVolume,spawn_shell,noctalia msg volume-up"
        "NONE,XF86AudioLowerVolume,spawn_shell,noctalia msg volume-down"
        "NONE,XF86AudioMute,spawn_shell,noctalia msg volume-mute"
        "NONE,XF86AudioMicMute,spawn,wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        "NONE,XF86MonBrightnessUp,spawn_shell,noctalia msg brightness-up"
        "NONE,XF86MonBrightnessDown,spawn_shell,noctalia msg brightness-down"
        "NONE,XF86AudioNext,spawn,playerctl next"
        "NONE,XF86AudioPause,spawn,playerctl play-pause"
        "NONE,XF86AudioPlay,spawn,playerctl play-pause"
        "NONE,XF86AudioPrev,spawn,playerctl previous"
      ];

      mousebind = [
        "SUPER,btn_left,moveresize,curmove"
        "SUPER,btn_right,moveresize,curresize"
      ];
      axisbind = [
        "SUPER,UP,viewtoleft_have_client"
        "SUPER,DOWN,viewtoright_have_client"
        "SUPER+CTRL,UP,tagtoleft"
        "SUPER+CTRL,DOWN,tagtoright"
      ];
      gesturebind = [
        "NONE,left,3,focusdir,left"
        "NONE,right,3,focusdir,right"
        "NONE,up,3,focusdir,up"
        "NONE,down,3,focusdir,down"
        "NONE,left,4,viewtoleft_have_client"
        "NONE,right,4,viewtoright_have_client"
        "NONE,up,4,toggleoverview"
        "NONE,down,4,toggleoverview"
      ];
  } // lib.optionalAttrs (monitors != [ ]) {
    monitorrule = monitorRules;
  };

in
{
  imports = [
    ./window_manager_appearance.nix
  ];

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    config.mango = {
      default = [
        "gnome"
        "gtk"
      ];
      "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
    };
  };

  wayland.windowManager.mango = {
    enable = true;
    package = pkgs.mango;
    inherit settings;
    autostart_sh = autostart;
  };
}
