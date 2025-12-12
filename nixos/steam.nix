{ config, lib, pkgs, ... }:

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
        "-r 120"
        "-e "
      ];
      steamArgs = [
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

  environment.systemPackages = with pkgs; [
    gamescope-wsi # HDR won't work without this
    mangohud
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-unwrapped"
  ];
}
