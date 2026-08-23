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
        (import ../../home/mango_config.nix {
          inherit pkgs lib;
          enableBlur = false;
          autostartApps = [
            "blueman-applet"
            "nm-applet"
            "nextcloud --background"
            "NOCTALIA_ASSETS_DIR=${pkgs.noctalia-mango-optional-source-assets} noctalia"
          ];
          monitors = [
            {
              serial = "TBK02382019";
              width = 3840;
              height = 2160;
              refresh = 60;
              x = 1920;
              y = 0;
              scale = 1.25;
            }
            {
              make = "BOE";
              model = "0x0791";
              width = 1920;
              height = 1080;
              refresh = 60;
              x = 0;
              y = 0;
              scale = 1;
            }
            {
              serial = "4WY7076L06QB";
              width = 1920;
              height = 1080;
              refresh = 60;
              x = 4992;
              y = 0;
              scale = 1;
              transform = 1;
            }
          ];
        })
        (import ../../home/nvim.nix { inherit pkgs nixvim; })
        (import ../../home/zsh.nix { inherit pkgs; })
        ../../home/ghostty.nix
        ../../home/noctalia_config.nix
      ];
    };
}
