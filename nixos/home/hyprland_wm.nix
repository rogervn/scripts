{
  pkgs,
  lib,
  config,
  pam_shim ? null,
  ...
}:
{
  home.activation.suggestHyprlandRestart = lib.hm.dag.entryAfter [ "reloadSystemd" ] ''
    unit='wayland-wm@start\x2dhyprland.service'
    if [[ -v oldGenPath ]] && ${config.systemd.user.systemctlPath} --user --quiet is-active "$unit"; then
      old_exe="$(${pkgs.coreutils}/bin/readlink -f "$oldGenPath/home-path/bin/start-hyprland" || true)"

      if [[ "$old_exe" != "${config.wayland.windowManager.hyprland.finalPackage}/bin/start-hyprland" ]]; then
        echo
        echo "Hyprland was updated; restart it when ready:"
        echo "  systemctl --user restart '$unit'"
      fi
    fi
  '';

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
    uwsm
  ];
}
// lib.optionalAttrs (pam_shim != null) {
  imports = [ pam_shim.homeModules.default ];
  pamShim.enable = true;
  programs.noctalia = {
    enable = true;
    package = config.lib.pamShim.replacePam pkgs.noctalia;
  };
}
