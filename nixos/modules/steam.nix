{
  pkgs,
  userName,
  ...
}: {
  jovian = {
    steam = {
      enable = true;
      desktopSession = "Hyprland";
    };
    hardware.has.amd.gpu = true;
  };

  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    heroic
    mangohud
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
