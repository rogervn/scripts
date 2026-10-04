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

  # Compressed swap in RAM only; no swap file to wear the SD card.
  zramSwap.enable = true;

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
    # No RTC: wait for NTP so AdGuard's TLS filter downloads see the real date.
    chrony-wait = {
      description = "Wait for chrony to synchronise the clock";
      after = [ "chronyd.service" ];
      requires = [ "chronyd.service" ];
      before = [ "time-sync.target" ];
      wants = [ "time-sync.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.chrony}/bin/chronyc waitsync 18 0.1";
        TimeoutStartSec = 200;
      };
    };
    adguardhome = {
      after = [ "time-sync.target" ];
      wants = [ "time-sync.target" ];
    };
    systemd-networkd.stopIfChanged = false;
    systemd-resolved.stopIfChanged = false;
  };

  # Don't require sudo/root to `reboot` or `poweroff`.
  security.polkit.enable = true;

  system.stateVersion = "26.05";
}
