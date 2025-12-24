{ config, lib, pkgs, userName, inputs, ... }:

{
  home-manager.users.${userName} = { config, lib, ... }: {
    home.stateVersion = "25.11";
    programs.fzf.enable = true;

    imports = [
      (import home/noctalia-shell.nix {inherit inputs;})
      (import home/dotfiles.nix {inherit config lib pkgs;})
    ];

  };
}
