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
        (import ../../home/niri_config.nix {
          inherit pkgs lib;
          # Refresh rates must match `niri msg outputs` exactly (3 decimals); verify on-device.
          monitors = [
            ''
              output "LG Electronics LG TV SSCR2 0x01010101" {
                  mode "3840x2160@120.000"
                  scale 1.5
                  variable-refresh-rate on-demand=true
              }
            ''
          ];
        })
        ../../home/llm-clis.nix
        (import ../../home/nvim.nix { inherit pkgs nixvim; })
        (import ../../home/zsh.nix { inherit pkgs; })
        ../../home/ghostty.nix
        ../../home/noctalia_config.nix
        ../../home/devshells.nix
      ];
    };
}
