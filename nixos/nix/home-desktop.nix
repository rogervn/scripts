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

  # systemd skips symlinks when scanning XDG_DATA_DIRS for unit files, so the
  # UWSM units in ~/.nix-profile (which are all symlinks) are invisible to it.
  # Placing them in ~/.config/systemd/user/ via home.file makes systemd load them.
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
  );

  imports = [
    (import ../home/dotfiles.nix { inherit config lib pkgs; })
    (import ../home/niri.nix {
      inherit pkgs lib;
      # Two physical setups share this list; overlapping positions (e.g.
      # x=1920,y=-1200 twice) are expected since only connected outputs apply.
      monitors = [
        ''
          output "California Institute of Technology 0x1403" {
              mode "3840x2400@60.000"
              position x=0 y=0
              scale 2.0
          }
        ''
        ''
          output "Chimei Innolux Corporation 0x1488" {
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
          output "LG Electronics LG TV SSCR2 0x01010101" {
              mode "3840x2160@120.000"
              scale 1.5
              variable-refresh-rate
          }
        ''
        ''
          output "BOE 0x0791" {
              mode "1920x1080@60.000"
              scale 1.0
          }
        ''
      ];
      browser = "google-chrome --ozone-platform=wayland";
      noteEditor = "gedit";
      codeEditor = "code-fb --ozone-platform-hint=auto";
      extraEnv = [
        "GDK_BACKEND,wayland"
        "CLUTTER_BACKEND,wayland"
        "WLR_NO_HARDWARE_CURSORS,1"
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
      windowManager = [ "niri" ];
    })
  ];
}
