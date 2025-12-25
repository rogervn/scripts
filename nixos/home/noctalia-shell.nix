{ inputs, ... }:
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia-shell = {
    enable = true;
    settings = {
      calendar = {
        enabled = false;
      };

      wallpaper = {
        directory = "~/.config/hypr/wallpaper";
        randomEnabled = true;
        randomIntervalSec = 7200;
      };

      dock = {
        enabled = false;
      };

      notifications ={
        lowUrgencyDuration = 2;
        normalUrgencyDuration = -1;
        criticalUrgencyDuration = -1;
      };

      colorSchemes = {
        useWallpaperColors = true;
        matugenSchemeType = "scheme-tonal-spot";
      };

      templates = {
        gtk = true;
        qt = true;
        ghostty = true;
        hyprland = true;
      };
      
      appLauncher = {
        enableClipPreview = true;
        enableClipboardHistory = true;
        showCategories = false;
        terminalCommand = "ghostty -e";
      };
      
      location = {
        name = "London";
      };

      sessionMenu = {
        enableCountdown = false;
      };

      ui = {
        fontDefault = "Noto Sans";
        fontFixed = "Noto Sans Mono";
        fontDefaultScale = 1.1;
        fontFixedScale = 1.2;
      };

      bar = {
        density = "comfortable";
        transparent = true;
        widgets = {
          left = [
            {
              id = "ControlCenter";
              useDistroLogo = true;
            }
            {
              id = "Workspace";
              hideUnnocupied = false;
            }
          ];
          center = [
            {
              id = "ActiveWindow";
            }
          ];
          right = [
            {
              id = "KeepAwake";
            }
            {
              id = "Volume";
              displayMode = "alwaysShow";
            }
            {
              id = "Brightness";
              displayMode = "alwaysShow";
            }
            {
              id = "PowerProfile";
            }
            {
              id = "SystemMonitor";
              diskPath = "/";
              showDiskUsage = true;
            }
            {
              id = "Battery";
              displayMode = "alwaysShow";
            }
            {
              id = "WiFi";
              displayMode = "alwaysShow";
            }
            {
              id = "Bluetooth";
            }
            {
              id = "Tray";
              drawerEnabled = false;
            }
            {
              id = "Clock";
              formatHorizontal =  "HH:mm ddd dd MMM";
            }
            {
              id = "NotificationHistory";
            }
            {
              id = "SessionMenu";
            }
          ];
        };
      };
    };
  };
}
