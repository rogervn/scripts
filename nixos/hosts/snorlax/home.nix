{
  pkgs,
  userName,
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
      ];
    };
}
