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
        (import ../../home/hyprland_config.nix {
          inherit pkgs lib;
          monitors = [
            {
              output = "desc:LG Electronics LG TV SSCR2 0x01010101";
              mode = "3840x2160@120";
              scale = 1.5;
              vrr = 2;
            }
          ];
        })
        (import ../../home/hyprland_wm.nix { inherit pkgs lib config; })
        ../../home/llm-clis.nix
        (import ../../home/nvim.nix { inherit pkgs nixvim; })
        (import ../../home/zsh.nix { inherit pkgs; })
        ../../home/ghostty.nix
        ../../home/noctalia_config.nix
        ../../home/devshells.nix
      ];
    };
}
