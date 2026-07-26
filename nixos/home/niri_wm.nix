{
  pkgs,
  config,
  pam_shim,
  noctalia,
  ...
}:
{
  imports = [
    pam_shim.homeModules.default
  ];
  pamShim.enable = true;

  programs.noctalia = {
    enable = true;
    # config.lib.pamShim.replacePam compares against *our* pkgs.linux-pam, but
    # noctalia pins its own nixpkgs (required for its binary cache to hit), so
    # its actual linux-pam dependency is a different derivation that the
    # helper never matches. Replace against noctalia's own linux-pam instead.
    package = pkgs.replaceDependencies {
      drv = noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
      replacements = [
        {
          oldDependency = noctalia.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.linux-pam;
          newDependency = config.pamShim.package;
        }
      ];
    };
  };

  home.packages = with pkgs; [
    blueman
    bluetui
    cliphist
    font-awesome
    gedit
    ghostty
    grim
    evince
    qt6.qtwayland
    imagemagick
    jetbrains-mono
    libnotify
    networkmanagerapplet
    nerd-fonts.symbols-only
    noto-fonts
    pavucontrol
    shotwell
    slurp
    wl-clipboard
    xdg-user-dirs
    bibata-cursors
    niri
    xwayland-satellite
    polkit_gnome
    xdg-desktop-portal-gnome
    xdg-desktop-portal-gtk
  ];
}
