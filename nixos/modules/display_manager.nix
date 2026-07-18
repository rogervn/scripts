{ pkgs, ... }:
{
  programs.regreet = {
    enable = true;

    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
    };

    settings = {
      skip_selection = true;

      background = {
        path = "${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.src}";
        fit = "Cover";
      };
      GTK = {
        application_prefer_dark_theme = true;
      };
    };
  };

  security.pam.services.greetd.enableGnomeKeyring = true;
}
