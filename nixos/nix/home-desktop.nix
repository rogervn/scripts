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
  );

  imports = [
    (import ../home/dotfiles.nix { inherit config lib pkgs; })
    (import ../home/hyprland_config.nix {
      inherit pkgs lib;
      # Duplicate positions are alternate hardware/dock scenarios, not simultaneous monitors; only the connected one matches.
      monitors = [
        {
          output = "desc:California Institute of Technology 0x1403";
          mode = "3840x2400@60";
          position = "0x0";
          scale = 2;
        }
        {
          output = "desc:Dell Inc. DELL P3223QE JG6KWN3";
          mode = "3840x2160@60";
          position = "1920x-1200";
          scale = 1.25;
        }
        {
          output = "desc:Dell Inc. DELL UP3017 Y7NWN74M118L";
          mode = "2560x1600@60";
          position = "5000x-1200";
          scale = 1;
          transform = 1;
        }
        # Left-to-right row: Chimei | BenQ EW3270U | P2317H (portrait), tops aligned at y=0.
        {
          output = "desc:Chimei Innolux Corporation 0x1488 Unknown";
          mode = "1920x1200@60";
          position = "0x0";
          scale = 1;
          vrr = 2;
        }
        {
          output = "desc:PNP(BNQ) BenQ EW3270U TBK02382019";
          mode = "3840x2160@60";
          position = "1920x0";
          scale = 1.25;
        }
        {
          output = "desc:Dell Inc. DELL P2317H 4WY7076L06QB";
          mode = "1920x1080@60";
          position = "4992x0";
          scale = 1;
          transform = 1;
        }
        {
          output = "Virtual-1";
          scale = 1;
        }
      ];
      workspaces = [
        {
          name = "laptop";
          output = "desc:Chimei Innolux Corporation 0x1488 Unknown";
        }
        {
          name = "monitor 1";
          output = "desc:Dell Inc. DELL P3223QE JG6KWN3";
        }
        # The UP3017 is rotated; its named workspace scrolls top-to-bottom.
        {
          name = "monitor 2";
          output = "desc:Dell Inc. DELL UP3017 Y7NWN74M118L";
          vertical = true;
        }
        # The alternate P2317H portrait arrangement gets the same behaviour.
        {
          name = "portrait";
          output = "desc:Dell Inc. DELL P2317H 4WY7076L06QB";
          vertical = true;
        }
      ];
      browser = "google-chrome --ozone-platform=wayland";
      noteEditor = "gedit";
      codeEditor = "code-fb --ozone-platform-hint=auto";
    })
    (import ../home/zsh.nix { inherit pkgs; })
    (import ../home/nvim.nix { inherit pkgs nixvim; })
    (import ../home/hyprland_wm.nix {
      inherit
        pkgs
        lib
        config
        pam_shim
        ;
    })
    (import ../home/solaar.nix { inherit pkgs; })
    ../home/ghostty.nix
    ../home/noctalia_config.nix
  ];
}
