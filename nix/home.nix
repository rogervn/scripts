{ pkgs, userName, ... }:

{
  home.stateVersion = "25.11";
  home.username = userName;
  home.homeDirectory = "/home/${userName}";
  programs.home-manager.enable = true;

  imports = [
    (import home/zsh.nix {inherit pkgs;})
  ];
}
