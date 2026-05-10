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
    loader.raspberryPi.bootloader = "uboot";
    kernelParams = [ "console=ttyS1,115200n8" ];
    extraModprobeConfig = ''
      options brcmfmac roamoff=1 feature_disable=0x82000
    '';
  };
  hardware = {
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
    enableRedistributableFirmware = lib.mkForce false;
    firmware = [ pkgs.raspberrypiWirelessFirmware ];
  };

  zramSwap.enable = true;

  networking = {
    inherit hostName;
    useNetworkd = true;
    firewall = {
      allowedTCPPorts = [ 22 ];
      allowedUDPPorts = [ 5353 ];
    };
    interfaces."wlan0".useDHCP = true;
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
  systemd = {
    network.networks = {
      "99-ethernet-default-dhcp".networkConfig.MulticastDNS = "yes";
      "99-wireless-client-dhcp".networkConfig.MulticastDNS = "yes";
    };
    services = {
      systemd-networkd.stopIfChanged = false;
      systemd-resolved.stopIfChanged = false;
    };
  };

  services.udev.extraRules = ''
    # Ignore partitions with "Required Partition" GPT partition attribute
    # On our RPis this is firmware (/boot/firmware) partition
    ENV{ID_PART_ENTRY_SCHEME}=="gpt", \
      ENV{ID_PART_ENTRY_FLAGS}=="0x1", \
      ENV{UDISKS_IGNORE}="1"
  '';

  users.users.${userName} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
    ];
  };
  age.secrets."${userName}_authorized_keys" = {
    path = "/home/${userName}/.ssh/authorized_keys";
    owner = userName;
    mode = "600";
  };

  # Don't require sudo/root to `reboot` or `poweroff`.
  security.polkit.enable = true;

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  system.stateVersion = "25.11";
}
