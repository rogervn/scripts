{
  pkgs,
  userName,
  nixvim,
  ...
}: {
  home-manager.backupFileExtension = "backup";
  home-manager.users.${userName} = {
    config,
    lib,
    ...
  }: {
    home.stateVersion = "25.11";

    imports = [
      (import ../../home/dotfiles.nix {inherit config lib pkgs;})
      (import ../../home/hyprland.nix {inherit pkgs lib;})
      (import ../../home/hyprland-custom-desktop.nix {inherit pkgs lib;})
      (import ../../home/nvim.nix {inherit pkgs nixvim;})
      (import ../../home/zsh.nix {inherit pkgs;})
    ];
  };
}
