{
  pkgs,
  userName,
  nixvim,
  ...
}:
{
  home-manager.backupFileExtension = "backup";
  home-manager.users.${userName} =
    { ... }:
    {
      home.stateVersion = "26.05";

      imports = [
        (import ../../home/zsh.nix { inherit pkgs; })
        (import ../../home/nvim.nix { inherit pkgs nixvim; })
      ];
    };
}
