{
  pkgs,
  userName,
  ...
}:

{
  home-manager.users.${userName} =
    { config, lib, ... }:
    {
      home.stateVersion = "25.11";

      imports = [
        (import ../home/dotfiles.nix { inherit config lib pkgs; })
        (import ../home/vim.nix { inherit pkgs; })
        (import ../home/zsh.nix { inherit pkgs; })
      ];

    };
}
