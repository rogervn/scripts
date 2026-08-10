{
  pkgs,
  lib,
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

  # Updating niri must not restart the running compositor and tear down the session.
  home.file.".config/systemd/user/niri.service.d/home-manager.conf".text = ''
    [Unit]
    X-SwitchMethod=keep-old
  '';

  home.activation.suggestNiriRestart = lib.hm.dag.entryAfter [ "reloadSystemd" ] ''
    if ${config.systemd.user.systemctlPath} --user --quiet is-active niri.service; then
      main_pid="$(${config.systemd.user.systemctlPath} --user show --property MainPID --value niri.service)"
      running_exe="$(${pkgs.coreutils}/bin/readlink -f "/proc/$main_pid/exe" || true)"

      if [[ "$running_exe" != "${pkgs.niri}/bin/niri" ]]; then
        echo
        echo "niri was updated; restart it when ready:"
        echo "  systemctl --user restart niri.service"
      fi
    fi
  '';

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
