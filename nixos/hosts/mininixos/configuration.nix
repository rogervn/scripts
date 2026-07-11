{
  config,
  pkgs,
  userName,
  hostName,
  nixvim,
  agenixPackage,
  ...
}:
{
  imports = [
    ../../modules/base.nix
    ../../modules/secrets-serveruser.nix
    ../../modules/cloudflared.nix
    ../../modules/adguardhome.nix
    ../../modules/home_assistant.nix
    ../../modules/uptime_kuma.nix
    ../../modules/restic-backup.nix
    ../../modules/vaultwarden.nix
    ../../modules/beszel.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit nixvim; };
  };

  environment.systemPackages = [ agenixPackage ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelPackages = pkgs.linuxPackages_latest;
  };

  time.timeZone = "Europe/London";

  nix.settings.trusted-users = [ userName ];

  hardware.bluetooth.enable = true;
  hardware.enableAllFirmware = true;

  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

  services.kmscon = {
    enable = true;
    config.font-name = "JetbrainsMono NL Nerd Font Mono";
  };

  networking = {
    inherit hostName;
    useNetworkd = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  # Tailscale sets ~. on tailscale0, overriding all DNS including .localdomain — route it back to the local DNS server
  systemd.network.networks."40-enp2s0" = {
    matchConfig.Name = "enp2s0";
    networkConfig = {
      DHCP = "yes";
      IPv6PrivacyExtensions = "kernel";
      Domains = "~localdomain";
    };
  };

  users.users.${userName} = {
    isNormalUser = true;
    hashedPasswordFile = config.age.secrets."${userName}_pass_hash".path;
    extraGroups = [
      "wheel"
      "disk"
      "libvirtd"
    ];
  };
  age.secrets."${userName}_authorized_keys" = {
    path = "/home/${userName}/.ssh/authorized_keys";
    owner = userName;
    mode = "600";
  };

  myServices.resticBackup = {
    enable = true;
    repository = "sftp://backupuser@datanixos.localdomain/mininixos";
    passwordSecretPath = config.age.secrets.mininixos_backup_restic_pass.path;
    timerConfig = {
      OnCalendar = "daily";
      RandomizedDelaySec = "1h";
      Persistent = true;
    };
    extraOptions = [ ''sftp.args="-i /root/.ssh/id_ed25519 -o StrictHostKeyChecking=accept-new"'' ];
    # paths populated automatically by vaultwarden.nix
    # postgresqlBackup.enable defaults to false — mininixos has no postgres
  };

  myServices.beszelAgent = {
    enable = true;
    hubUrl = "http://datanixos.localdomain:8017";
    keySecretPath = config.age.secrets.beszel_hub_key_file.path;
    tokenSecretPath = config.age.secrets.mininixos_beszel_token_file.path;
  };

  system.stateVersion = "26.05";
}
