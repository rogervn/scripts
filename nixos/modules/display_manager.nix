{
  config,
  lib,
  pkgs,
  userName,
  ...
}:
let
  cfg = config.myServices.noctaliaGreeter;
in
{
  options.myServices.noctaliaGreeter.sessionDefault = lib.mkOption {
    type = lib.types.str;
    default = "";
    example = "niri";
    description = "Session to preselect in the noctalia-greeter picker.";
  };

  options.myServices.noctaliaGreeter.output = lib.mkOption {
    type = lib.types.nullOr (
      lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            example = "HDMI-A-2";
            description = "DRM connector on which to show the greeter.";
          };

          width = lib.mkOption {
            type = lib.types.ints.positive;
            example = 1920;
            description = "Greeter output width in pixels.";
          };

          height = lib.mkOption {
            type = lib.types.ints.positive;
            example = 1080;
            description = "Greeter output height in pixels.";
          };

          scale = lib.mkOption {
            type = lib.types.float;
            example = 1.0;
            description = "Greeter UI scale for the selected output.";
          };
        };
      }
    );
    default = null;
    example = {
      name = "HDMI-A-2";
      width = 1920;
      height = 1080;
      scale = 1.0;
    };
    description = "Optional fixed connector, mode, and UI scale for noctalia-greeter.";
  };

  config = {
    services.displayManager.noctalia-greeter = {
      enable = true;

      cursorTheme = {
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;
      };

      settings =
        lib.optionalAttrs (cfg.sessionDefault != "") {
          session.default = cfg.sessionDefault;
        }
        // lib.optionalAttrs (cfg.output != null) {
          output = cfg.output;
        }
        // {
          user.default = userName;

          appearance = {
            scheme = "Synced";
            password_style = "random";
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
    };

    security.pam.services.greetd = {
      enableGnomeKeyring = true;

      # Read the LUKS passphrase retained by systemd-cryptsetup and make it
      # available to compatible PAM modules in greetd's login stack.
      rules.auth.systemd_loadkey =
        lib.mkIf (config.boot.initrd.systemd.enable && config.boot.initrd.luks.devices != { })
          {
            order = 10000;
            control = "optional";
            modulePath = "${config.systemd.package}/lib/security/pam_systemd_loadkey.so";
          };
    };
  };
}
