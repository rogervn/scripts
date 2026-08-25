{
  pkgs,
  userName,
  nixvim,
  ...
}:
{
  home-manager.backupFileExtension = "backup";
  home-manager.users.${userName} =
    {
      config,
      lib,
      ...
    }:
    {
      home.stateVersion = "25.11";

      imports = [
        (import ../../home/dotfiles.nix { inherit config lib pkgs; })
        ../../home/llm-clis.nix
        (import ../../home/niri_config.nix {
          inherit pkgs lib;
          monitors = [
            # Left-to-right row: laptop panel | BenQ EW3270U | P2317H (portrait), tops aligned at y=0.
            ''
              output "BOE 0x0791 Unknown" {
                  mode "1920x1080@60.000"
                  scale 1.0
                  position x=0 y=0
              }
            ''
            ''
              output "PNP(BNQ) BenQ EW3270U TBK02382019" {
                  mode "3840x2160@60.000"
                  scale 1.25
                  position x=1920 y=0
              }
            ''
            ''
              output "Dell Inc. DELL P2317H 4WY7076L06QB" {
                  mode "1920x1080@60.000"
                  scale 1.0
                  transform "90"
                  position x=4992 y=0
                  layout {
                      default-column-width { proportion 1.0; }
                      preset-column-widths {
                          proportion 0.5
                          proportion 1.0
                      }
                  }
              }
            ''
          ];
        })
        # Keep Niri available while evaluating the equivalent Hyprland setup.
        (import ../../home/hyprland_config.nix {
          inherit pkgs lib;
          monitors = [
            {
              output = "desc:BOE 0x0791";
              mode = "1920x1080@60";
              position = "0x0";
              scale = 1;
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
          ];
          workspaces = [
            {
              name = "portrait";
              output = "desc:Dell Inc. DELL P2317H 4WY7076L06QB";
              vertical = true;
            }
          ];
        })
        (import ../../home/hyprland_wm.nix { inherit pkgs lib config; })
        (import ../../home/nvim.nix { inherit pkgs nixvim; })
        (import ../../home/zsh.nix { inherit pkgs; })
        ../../home/ghostty.nix
        ../../home/noctalia_config.nix
      ];
    };
}
