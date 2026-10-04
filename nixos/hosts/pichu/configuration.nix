{
  lib,
  pkgs,
  userName,
  hostName,
  ...
}:
{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    # allow nix-copy to live system
    trusted-users = [ userName ];
  };

  time.timeZone = "Europe/London";

  boot = {
    loader.raspberry-pi.bootloader = "kernel";
    # Compressed RAM cache in front of the swap file; the shrinker moves cold pages to disk.
    kernelParams = [
      "zswap.enabled=1"
      "zswap.shrinker_enabled=1"
    ];
    # Out-of-tree zfs module pulled in by the sd-image profile; not needed and breaks on kernel bumps.
    supportedFilesystems.zfs = lib.mkForce false;
    # No firmware roaming; disable FWSUP, SAE and SAE_EXT, whose WPA3 paths hang under iwd.
    extraModprobeConfig = ''
      options cfg80211 ieee80211_regdom=GB
      options brcmfmac roamoff=1 feature_disable=0x2082000
    '';
  };

  # linux-firmware ships generic brcmfmac blobs that would shadow the RPi-tuned ones.
  hardware = {
    enableRedistributableFirmware = lib.mkForce false;
    firmware = [ pkgs.raspberrypiWirelessFirmware ];
    wirelessRegulatoryDatabase = true;
    raspberry-pi.config.all.options = {
      gpu_mem = {
        enable = true;
        value = 16;
      };
      start_x = {
        enable = true;
        value = 0;
      };
    };
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 1024;
    }
  ];

  networking = {
    inherit hostName;
    useNetworkd = true;
    firewall = {
      allowedTCPPorts = [ 22 ];
    };
    wireless.iwd = {
      enable = true;
      settings = {
        Network = {
          EnableIPv6 = true;
          RoutePriorityOffset = 300;
        };
        Settings.AutoConnect = true;
      };
    };
  };

  systemd.services = {
    systemd-networkd.stopIfChanged = false;
    systemd-resolved.stopIfChanged = false;
  };

  # Don't require sudo/root to `reboot` or `poweroff`.
  security.polkit.enable = true;

  system.stateVersion = "26.05";
}
