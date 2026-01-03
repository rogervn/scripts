{
  userName,
  hostName,
  ...
}: {
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  time.timeZone = "Europe/London";

  boot.loader.raspberryPi.bootloader = "kernel";

  # allow nix-copy to live system
  nix.settings.trusted-users = [userName];

  networking.hostName = hostName;

  networking.useNetworkd = true;
  networking.firewall = {
    allowedTCPPorts = [22];
    allowedUDPPorts = [5353];
  };
  systemd.network.networks = {
    "99-ethernet-default-dhcp".networkConfig.MulticastDNS = "yes";
    "99-wireless-client-dhcp".networkConfig.MulticastDNS = "yes";
  };

  systemd.services = {
    systemd-networkd.stopIfChanged = false;
    systemd-resolved.stopIfChanged = false;
  };

  networking.wireless.enable = false;
  networking.wireless.iwd = {
    enable = true;
    settings = {
      Network = {
        EnableIPv6 = true;
        RoutePriorityOffset = 300;
      };
      Settings.AutoConnect = true;
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

  system.stateVersion = "26.05";
}
