{ ... }:
{
  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "JetBrainsMono Nerd Font Mono";
      background-opacity = 0.8;
      title = "Ghostty";
      gtk-titlebar = false;
      theme = "noctalia";
    };
  };
}
