{
  config,
  lib,
  userName,
  hostName,
  pkgs,
  ...
}:
{
  imports = [
    ../../modules/adguardhome.nix
    ../../modules/tailscale.nix
    ../../modules/uptime_kuma.nix
    ../../modules/beszel.nix
    ../../modules/homepage-dashboard.nix
  ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    # allow nix-copy to live system
    trusted-users = [ userName ];
  };

  time.timeZone = "Europe/London";

  boot.loader.raspberry-pi.bootloader = "kernel";

  # Wired only; skip linux-firmware, the Pi 5 needs none of it.
  hardware = {
    enableRedistributableFirmware = lib.mkForce false;
    raspberry-pi.config.all.dt-overlays = {
      disable-wifi = {
        enable = true;
        params = { };
      };
      disable-bt = {
        enable = true;
        params = { };
      };
    };
  };

  # Compressed swap in RAM only; no swap file to wear the SSD.
  zramSwap.enable = true;

  networking = {
    inherit hostName;
    useNetworkd = true;
    firewall.allowedTCPPorts = [ 22 ];
  };

  age.secrets = {
    tailscale_auth_key = {
      file = ../../modules/secrets/tailscale_auth_key.age;
      mode = "400";
    };
    cloudflare_ddns_token = {
      file = ../../modules/secrets/cloudflare_ddns_token.age;
      mode = "400";
    };
    # CLOUDFLARE_DOMAINS=<fqdn>, kept out of the repo
    cloudflare_ddns_env_file = {
      file = ../../modules/secrets/cloudflare_ddns_env_file.age;
      mode = "400";
    };
    # mode 444: beszel-agent runs as a DynamicUser
    beszel_hub_key_file = {
      file = ../../modules/secrets/beszel_hub_key_file.age;
      mode = "444";
    };
    pikachu_beszel_token_file = {
      file = ../../modules/secrets/pikachu_beszel_token_file.age;
      mode = "444";
    };
    homepage_env_file = {
      file = ../../modules/secrets/homepage_env_file.age;
      mode = "400";
    };
  };

  services.cloudflare-dyndns = {
    enable = true;
    apiTokenFile = config.age.secrets.cloudflare_ddns_token.path;
    ipv4 = false;
    ipv6 = true;
  };

  myServices = {
    homepage.enable = true;
    beszelAgent = {
      enable = true;
      keySecretPath = config.age.secrets.beszel_hub_key_file.path;
      tokenSecretPath = config.age.secrets.pikachu_beszel_token_file.path;
    };
  };

  systemd.services = {
    # Overrides the module's empty CLOUDFLARE_DOMAINS
    cloudflare-dyndns.serviceConfig.EnvironmentFile = config.age.secrets.cloudflare_ddns_env_file.path;
    # No RTC battery: wait for NTP so AdGuard's TLS filter downloads see the real date.
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
    # Runs `tailscale up` once at boot; needs the network and a valid clock for TLS.
    tailscaled-autoconnect = {
      after = [
        "network-online.target"
        "time-sync.target"
      ];
      wants = [
        "network-online.target"
        "time-sync.target"
      ];
    };
    systemd-networkd.stopIfChanged = false;
    systemd-resolved.stopIfChanged = false;
  };

  # Don't require sudo/root to `reboot` or `poweroff`.
  security.polkit.enable = true;

  system.stateVersion = "26.05";
}
