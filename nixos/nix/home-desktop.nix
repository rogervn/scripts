{
  config,
  lib,
  pkgs,
  userName,
  nixvim,
  pam_shim,
  ...
}: {
  targets.genericLinux.enable = true;
  home.stateVersion = "25.11";
  home.backupFileExtension = "backup";
  home.username = userName;
  home.homeDirectory = "/home/${userName}";
  programs.home-manager.enable = true;

  imports = [
    (import ../home/dotfiles.nix {inherit config lib pkgs;})
    (import ../home/hyprland.nix {inherit pkgs lib;})
    (import ../home/zsh.nix {inherit pkgs;})
    (import ../home/nvim.nix {inherit pkgs nixvim;})
    (import ../home/window_manager.nix {inherit pkgs config pam_shim;})
    (import ../home/hyprland-custom-work.nix {inherit pkgs lib;})
  ];
}
