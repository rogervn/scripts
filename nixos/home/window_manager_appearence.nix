{ pkgs, ... }:
{
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };

  gtk = {
    enable = true;
    theme = {
      name = "Orchis-Dark";
      package = pkgs.orchis-theme;
    };

    iconTheme = {
      name = "Tela-blue-dark";
      package = pkgs.tela-icon-theme;
    };

    gtk4.theme = null;
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
  };

  # Dconf Settings for Global Dark Mode (Libadwaita/Modern GTK4)
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
}
