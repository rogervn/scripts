{ config, pkgs, ... }:

let
  dotfilesRoot = "${config.home.homeDirectory}/dotfiles";
  username = config.home.username;
in
{
  programs.fzf.enable = true;
  home.activation.setupDotfiles = config.lib.dag.entryAfter ["writeBoundary"] ''
    DOTFILES_DIR="${dotfilesRoot}"
    
    if [ ! -d "$DOTFILES_DIR" ]; then
      $DRY_RUN_CMD ${pkgs.git}/bin/git clone https://github.com/rogervn/configs.git "$DOTFILES_DIR"
    else
      $DRY_RUN_CMD cd "$DOTFILES_DIR" && ${pkgs.git}/bin/git pull --ff-only 2>/dev/null || true
    fi
    
    $DRY_RUN_CMD cd "$DOTFILES_DIR"
    $DRY_RUN_CMD ${pkgs.stow}/bin/stow --adopt --ignore default.png common nixos
    $DRY_RUN_CMD ${pkgs.git}/bin/git restore .
    $DRY_RUN_CMD ${pkgs.stow}/bin/stow --ignore default.png common nixos
  '';
}
