_: {
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # Upstream repos aren't ours to dirty with direnv's files.
  xdg.configFile."git/ignore".text = ''
    **/.claude/settings.local.json
    .direnv/
    .envrc
  '';
}
