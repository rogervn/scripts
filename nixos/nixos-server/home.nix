{
  pkgs,
  userName,
  ...
}: {
  home-manager.users.${userName} = {
    config,
    lib,
    ...
  }: {
    home.stateVersion = "26.05";

    imports = [
      (import ../home/zsh.nix {inherit pkgs;})
    ];
  };
}
