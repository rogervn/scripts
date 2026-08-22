{ config, pkgs, ... }:
{
  services.displayManager.noctalia-greeter = {
    enable = true;

    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
    };

    settings.appearance = {
      scheme = "Synced";
      theme_mode = "dark";
      hide_logo = true;

      palette = {
        primary = "#adc6ff";
        on_primary = "#002e69";
        secondary = "#b1c6f7";
        on_secondary = "#193057";
        tertiary = "#f4aeff";
        on_tertiary = "#55006a";
        error = "#ffb4ab";
        on_error = "#690005";
        surface = "#11131a";
        on_surface = "#e1e2eb";
        surface_variant = "#424753";
        on_surface_variant = "#c2c6d5";
        outline = "#8c909f";
        shadow = "#000000";
        hover = "#f4aeff";
        on_hover = "#55006a";
      };

      wallpaper = {
        path = "${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.src}";
        fill_mode = "crop";
      };
    };
  };

  security.pam.services.greetd = {
    enableGnomeKeyring = true;

    # Autologin bypasses password authentication. Read the LUKS passphrase
    # retained by systemd-cryptsetup and make it available to the keyring PAM
    # module in the normal greetd login stack.
    rules.auth.systemd_loadkey = {
      order = 10000;
      control = "optional";
      modulePath = "${config.systemd.package}/lib/security/pam_systemd_loadkey.so";
    };
  };
}
