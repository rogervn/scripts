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
    home.backupFileExtension = "backup";

    imports = [
      (import ../../home/zsh.nix {inherit pkgs;})
    ];
  };
}
