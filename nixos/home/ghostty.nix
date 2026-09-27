_: {
  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "JetBrainsMono Nerd Font Mono";
      background-opacity = 0.8;
      title = "Ghostty";
      gtk-titlebar = false;
      theme = "Catppuccin Mocha";
      config-file = "?themes/noctalia";
      # added '@' as a selection word char for user@host only select host
      selection-word-chars = "\" \\t'\\\"│`|:;,()[]{}<>$@\"=";
    };
  };
}
