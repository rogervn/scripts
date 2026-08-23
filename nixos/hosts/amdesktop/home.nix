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
        (import ../../home/mango_config.nix {
          inherit pkgs lib;
          autostartApps = [
            "blueman-applet"
            "nm-applet"
            "nextcloud --background"
            "NOCTALIA_ASSETS_DIR=${pkgs.noctalia-mango-optional-source-assets} noctalia"
          ];
          monitors = [
            {
              make = "LG Electronics";
              model = "LG TV SSCR2";
              serial = "0x01010101";
              width = 3840;
              height = 2160;
              refresh = 120;
              x = 0;
              y = 0;
              scale = 1.5;
              vrr = true;
            }
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
