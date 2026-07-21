{ pkgs, lib, ... }:
{
  home.pointerCursor = {
    enable = true;
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

  qt = {
    enable = true;
    platformTheme.name = "qtct"; # installs qt6ct and wires QT_PLUGIN_PATH
  };

  # HM's "qtct" sets QT_QPA_PLATFORMTHEME=qt5ct, but the Qt6 plugin key is qt6ct.
  home.sessionVariables.QT_QPA_PLATFORMTHEME = lib.mkForce "qt6ct";
  systemd.user.sessionVariables.QT_QPA_PLATFORMTHEME = lib.mkForce "qt6ct";

  xdg.configFile."qt6ct/qt6ct.conf".text = ''
    [Appearance]
    icon_theme=Tela-blue-dark
    style=Fusion
  '';

  # Dconf Settings for Global Dark Mode (Libadwaita/Modern GTK4)
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
}
