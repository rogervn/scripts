{
  pkgs,
  userName,
  nixvim,
  ...
}: {
  home-manager.users.${userName} = {
    config,
    lib,
    ...
  }: {
    home.stateVersion = "25.11";

    imports = [
      (import ../../home/dotfiles.nix {inherit config lib pkgs;})
      (import ../../home/llm-clis.nix {inherit pkgs;})
      (import ../../home/nvim.nix {inherit pkgs nixvim;})
      (import ../../home/zsh.nix {inherit pkgs;})
    ];
  };
}
