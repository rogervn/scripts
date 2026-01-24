{
  lib,
  pkgs,
  userName,
  ...
}: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession = {
      enable = true;
      args = [
        "--mangoapp"
        "--hdr-enabled"
        "--rt"
        "-r"
        "120"
        "-f"
        "-e"
        "--xwayland-count"
        "2"
      ];
      steamArgs = [
        "-pipewire-dmabuf"
        "-gamepadui"
        "-steamdeck"
        "-steamos3"
      ];
      env = {
        PATH = "/usr/bin:$PATH";
      };
    };
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  programs.gamemode.enable = true;
  programs.xwayland.enable = true;

  environment.systemPackages = with pkgs; [
    gamescope-wsi
    heroic
    mangohud
  ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-unwrapped"
    ];

  users.users.${userName}.extraGroups = ["gamemode"];

  home-manager.users.${userName} = {
    # Allows heroic to be ran inside steam
    xdg.desktopEntries.heroic = {
      name = "Heroic Games Launcher (Steam embedded)";
      exec = "env -u LD_PRELOAD heroic %u";
      icon = "heroic";
      terminal = false;
      categories = ["Game"];
      mimeType = ["x-scheme-handler/heroic"];
    };

    home.packages = with pkgs; [
      # Switch to desktop will shutdown steam
      (writeShellScriptBin "steamos-session-select" ''
        steam -shutdown
      '')
    ];
  };
}
