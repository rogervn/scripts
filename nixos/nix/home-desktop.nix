{
  config,
  lib,
  pkgs,
  userName,
  nixvim,
  pam_shim,
  ...
}:
{
  targets.genericLinux.enable = true;
  home = {
    stateVersion = "25.11";
    username = userName;
    homeDirectory = "/home/${userName}";
  };
  programs.home-manager.enable = true;

  # systemd skips symlinked units under XDG_DATA_DIRS, so ~/.nix-profile's units are invisible unless copied in here.
  home.file = builtins.listToAttrs (
    map
      (name: {
        name = ".config/systemd/user/${name}";
        value.source = "${pkgs.uwsm}/share/systemd/user/${name}";
      })
      [
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
      ]
    ++ map
      (name: {
        name = ".config/systemd/user/${name}";
        value.source = "${pkgs.niri}/share/systemd/user/${name}";
      })
      [
        "niri.service"
        "niri-shutdown.target"
      ]
  );

  imports = [
    (import ../home/dotfiles.nix { inherit config lib pkgs; })
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
      browser = "google-chrome --ozone-platform=wayland";
      noteEditor = "gedit";
      codeEditor = "code-fb --ozone-platform-hint=auto";
      extraEnv = [
        "GDK_BACKEND,wayland"
        "CLUTTER_BACKEND,wayland"
        "WLR_NO_HARDWARE_CURSORS,1"
      ];
      extraConfig = ''
        exec-once = uwsm app -- ~/.nix-profile/libexec/xdg-desktop-portal-hyprland
      '';
    })
    (import ../home/niri.nix {
      inherit pkgs lib;
      # Duplicate positions are alternate hardware/dock scenarios, not simultaneous monitors; only the connected one matches.
      monitors = [
        ''
          output "California Institute of Technology 0x1403" {
              mode "3840x2400@60.000"
              position x=0 y=0
              scale 2.0
          }
        ''
        ''
          output "Chimei Innolux Corporation 0x1488 Unknown" {
              mode "1920x1200@60.000"
              position x=0 y=0
              scale 1.0
          }
        ''
        ''
          output "Dell Inc. DELL P3223QE JG6KWN3" {
              mode "3840x2160@60.000"
              position x=1920 y=-1200
              scale 1.25
          }
        ''
        ''
          output "Dell Inc. DELL UP3017 Y7NWN74M118L" {
              mode "2560x1600@60.000"
              position x=5000 y=-1200
              scale 1.0
              transform "90"
          }
        ''
        ''
          output "BNQ BenQ EW3270U TBK02382019" {
              mode "3840x2160@60.000"
              position x=1920 y=-1200
              scale 1.0
          }
        ''
        ''
          output "Dell Inc. DELL P2317H 4WY7076L06QB" {
              mode "1920x1080@60.000"
              position x=5760 y=-1200
              scale 1.0
              transform "90"
          }
        ''
        ''
          output "Virtual-1" {
              scale 1.0
          }
        ''
      ];
      workspaces = [
        ''
          workspace "laptop" {
              open-on-output "Chimei Innolux Corporation 0x1488 Unknown"
          }
        ''
        ''
          workspace "monitor 1" {
              open-on-output "Dell Inc. DELL P3223QE JG6KWN3"
          }
        ''
        ''
          workspace "monitor 2" {
              open-on-output "Dell Inc. DELL UP3017 Y7NWN74M118L"
          }
        ''
      ];
      browser = "google-chrome --ozone-platform=wayland";
      noteEditor = "gedit";
      codeEditor = "code-fb --ozone-platform-hint=auto";
      # GDK_BACKEND omitted: niri's docs warn it breaks the screencast portal.
      extraEnv = [
        "CLUTTER_BACKEND,wayland"
      ];
    })
    (import ../home/zsh.nix { inherit pkgs; })
    (import ../home/nvim.nix { inherit pkgs nixvim; })
    (import ../home/window_manager.nix {
      inherit
        pkgs
        config
        lib
        pam_shim
        ;
      windowManager = [
        "hyprland"
        "niri"
      ];
    })
  ];
}
