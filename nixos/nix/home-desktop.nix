{
  config,
  lib,
  pkgs,
  userName,
  nixvim,
  pam_shim,
  ...
}: {
  targets.genericLinux.enable = true;
  home.stateVersion = "25.11";
  home.username = userName;
  home.homeDirectory = "/home/${userName}";
  programs.home-manager.enable = true;

  # systemd skips symlinks when scanning XDG_DATA_DIRS for unit files, so the
  # UWSM units in ~/.nix-profile (which are all symlinks) are invisible to it.
  # Placing them in ~/.config/systemd/user/ via home.file makes systemd load them.
  home.file = builtins.listToAttrs (map (name: {
    name = ".config/systemd/user/${name}";
    value.source = "${pkgs.uwsm}/share/systemd/user/${name}";
  }) [
    "wayland-session-bindpid@.service"
    "wayland-session-envelope@.target"
    "wayland-session-pre@.target"
    "wayland-session-shutdown.target"
    "wayland-session@.target"
    "wayland-session-waitenv.service"
    "wayland-session-xdg-autostart@.target"
    "wayland-wm-app-daemon.service"
    "wayland-wm-env@.service"
    "wayland-wm@.service"
  ]);

  imports = [
    (import ../home/dotfiles.nix {inherit config lib pkgs;})
    (import ../home/hyprland.nix {
      inherit pkgs lib;
      monitors = [
        "desc:California Institute of Technology 0x1403,3840x2400@60,0x0,2"
        "desc:Chimei Innolux Corporation 0x1488,1920x1200@60,0x0,1"
        "desc:Dell Inc. DELL P3223QE JG6KWN3,3840x2160@60,1920x-1200,1.25"
        "desc:Dell Inc. DELL UP3017 Y7NWN74M118L,2560x1600@60,5000x-1200,1,transform,1"
        "desc:BNQ BenQ EW3270U TBK02382019,3840x2160@60,1920x-1200,1"
        "desc:Dell Inc. DELL P2317H 4WY7076L06QB,1920x1080@60,5760x-1200,1,transform,1"
        "Virtual-1,preferred,0x0,1"
      ];
      workspaces = [
        "1,monitor:desc:California Institute of Technology 0x1403,default:true"
        "2,monitor:desc:Dell Inc. DELL P3223QE JG6KWN3,default:true"
        "3,monitor:desc:Dell Inc. DELL UP3017 Y7NWN74M118L,default:true"
        "1,monitor:desc:LG Electronics LG TV SSCR2 0x01010101,default:true"
        "1,monitor:desc:BOE 0x0791,default:true"
      ];
      browser    = "google-chrome --ozone-platform=wayland";
      noteEditor = "gedit";
      codeEditor = "code-fb --ozone-platform-hint=auto";
      extraEnv = [
        "GDK_BACKEND,wayland"
        "CLUTTER_BACKEND,wayland"
        "WLR_NO_HARDWARE_CURSORS,1"
      ];
    })
    (import ../home/zsh.nix {inherit pkgs;})
    (import ../home/nvim.nix {inherit pkgs nixvim;})
    (import ../home/window_manager.nix {inherit pkgs config lib pam_shim;})
  ];
}
