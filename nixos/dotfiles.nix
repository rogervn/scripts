{ config, pkgs, userName, ... }:

{
  home-manager.users.${userName} = {config, pkgs, ... }:
  let
    dotfilesRoot = "${config.home.homeDirectory}/dotfiles";
    dotfilesRepo = "https://github.com/rogervn/configs.git";
  in {
    home.stateVersion = "25.11";
    programs.fzf.enable = true;
    home.activation.setupDotfiles = config.lib.dag.entryAfter ["writeBoundary"] ''
      DOTFILES_DIR="${dotfilesRoot}"
      DOTFILES_REPO="${dotfilesRepo}"
      
      if [ ! -d "$DOTFILES_DIR" ]; then
        $DRY_RUN_CMD ${pkgs.git}/bin/git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
      else
        $DRY_RUN_CMD cd "$DOTFILES_DIR" && ${pkgs.git}/bin/git pull --ff-only 2>/dev/null || true
      fi
      
      $DRY_RUN_CMD cd "$DOTFILES_DIR"
      $DRY_RUN_CMD ${pkgs.stow}/bin/stow --adopt --ignore default.png common nixos
      $DRY_RUN_CMD ${pkgs.git}/bin/git restore .
      $DRY_RUN_CMD ${pkgs.stow}/bin/stow --ignore default.png common nixos
    '';
  };
}
