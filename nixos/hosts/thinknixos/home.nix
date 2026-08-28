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
              output = "desc:BNQ BenQ EW3270U TBK02382019";
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
              id = 3;
              output = "desc:Dell Inc. DELL P2317H 4WY7076L06QB";
              vertical = true;
              default = true;
              persistent = true;
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
