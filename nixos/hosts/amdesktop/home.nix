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
        (import ../../home/niri.nix {
          inherit pkgs lib;
          # Refresh rates must match `niri msg outputs` exactly (3 decimals); verify on-device.
          monitors = [
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
        })
        (import ../../home/llm-clis.nix { inherit pkgs; })
        (import ../../home/nvim.nix { inherit pkgs nixvim; })
        (import ../../home/zsh.nix { inherit pkgs; })
      ];
    };
}
