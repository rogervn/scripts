{
  pkgs,
  lib,
  config,
  pam_shim,
  ...
}:
{
  imports = [
    pam_shim.homeModules.default
  ];
  pamShim.enable = true;

  programs.noctalia = {
    enable = true;
    package = config.lib.pamShim.replacePam pkgs.noctalia;
  };

  home = {
    # Updating niri must not restart the running compositor and tear down the session.
    file.".config/systemd/user/niri.service.d/home-manager.conf".text = ''
      [Unit]
      X-SwitchMethod=keep-old
    '';

    activation.suggestNiriRestart = lib.hm.dag.entryAfter [ "reloadSystemd" ] ''
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

    packages = with pkgs; [
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
  };
}
