{
  config,
  pkgs,
  userName,
  hostName,
  nixvim,
  agenixPackage,
  ...
}: {
  imports = [
    ../../modules/base.nix
    ../../modules/secrets-serveruser.nix
    ../../modules/cloudflared.nix
    ../../modules/adguardhome.nix
    ../../modules/home_assistant.nix
    ../../modules/uptime_kuma.nix
    ../../modules/restic-backup.nix
    ../../modules/tailscale.nix
    ../../modules/vaultwarden.nix
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = {inherit nixvim;};

  environment.systemPackages = [agenixPackage];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  time.timeZone = "Europe/London";

  nix.settings.trusted-users = [userName];

  hardware.bluetooth.enable = true;
  hardware.enableAllFirmware = true;

  services.kmscon = {
    enable = true;
    hwRender = true;
    fonts = [
      {
        name = "JetbrainsMono NL Nerd Font Mono";
        package = pkgs.nerd-fonts.jetbrains-mono;
      }
    ];
  };

  networking.hostName = hostName;
  networking.useNetworkd = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22];
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

  system.stateVersion = "26.05";
}
