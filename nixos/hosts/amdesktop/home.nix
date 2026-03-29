{
  pkgs,
  lib,
  userName,
  nixvim,
  ...
}: {
  home-manager.users.${userName} = {config, lib, ...}: {
    home.stateVersion = "25.11";

    imports = [
      (import ../../home/dotfiles.nix {inherit config lib pkgs;})
      (import ../../home/hyprland.nix {inherit pkgs lib;})
      (import ../../home/hyprland-custom-home.nix {inherit pkgs lib;})
      (import ../../home/llm-clis.nix {inherit pkgs;})
      (import ../../home/nvim.nix {inherit pkgs nixvim;})
      (import ../../home/zsh.nix {inherit pkgs;})
    ];

    wayland.windowManager.hyprland = {
      settings = {
        monitor = [
          "desc:LG Electronics LG TV SSCR2 0x01010101,3840x2160@120,auto,1.5,vrr,3,bitdepth,10,cm,auto"
          "desc:BOE 0x0791,1920x1080@60,auto,1"
          ",preferred,auto,auto"
        ];
        workspace = [
          "1,monitor:desc:Samsung Electric Company SAMSUNG 0x01000E00,default:true"
          "1,monitor:desc:BOE 0x0791,default:true"
        ];
      };
    };
  };
}
