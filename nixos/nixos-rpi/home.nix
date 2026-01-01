{
  pkgs,
  inputs,
  userName,
  ...
}: {
  home-manager.users.${userName} = {
    config,
    lib,
    ...
  }: {
    home.stateVersion = "25.11";

    imports = [
      (import ../home/dotfiles.nix {inherit config lib pkgs;})
      (import ../home/nvim.nix {inherit inputs pkgs;})
      (import ../home/zsh.nix {inherit pkgs;})
    ];
  };
}
