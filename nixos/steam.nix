{ config, lib, pkgs, ... }:

let
  # Script to fix bug with "Switch to desktop"
  steamos-session-select = pkgs.writeShellScriptBin "steamos-session-select" ''
  steam -shutdown
  '';
in
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession = {
      enable = true;
      args = [
        "--mangoapp"
        "--adaptive-sync"
        "--hdr-enabled"
        "-r" "120"
        "-W" "3840" "-H" "2160"
        "-f"
        "-e"
        "--xwayland-count" "2"
      ];
      steamArgs = [
        "-pipewire-dmabuf"
        "-gamepadui"
        "-steamdeck"
        "-steamos3"
      ];
    };
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  programs.gamemode.enable = true;

  programs.xwayland.enable = true;

  environment.systemPackages = with pkgs; [
    gamescope-wsi # HDR won't work without this
    heroic
    mangohud
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-unwrapped"
  ];

  # Switch to desktop will shutdown steam
  systemd.tmpfiles.rules = [
    "L+ /usr/bin/steamos-session-select - - - - ${steamos-session-select}/bin/steamos-session-select"
  ];

}
