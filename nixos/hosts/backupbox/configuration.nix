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
    ../../modules/secrets-backupuser.nix
    ../../modules/restic-backup.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit nixvim; };
  };

  environment.systemPackages = [ agenixPackage ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [ "backupuser" ];
  };
  nixpkgs.config.allowUnfree = true;

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  time.timeZone = "Europe/London";

  hardware = {
    bluetooth.enable = true;
    enableAllFirmware = true;
  };

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

  networking = {
    inherit hostName;
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  users.users.${userName} = {
    isNormalUser = true;
    hashedPasswordFile = config.age.secrets."${userName}_pass_hash".path;
    extraGroups = [
      "wheel"
      "disk"
    ];
  };
  age.secrets."${userName}_private_key" = {
    path = "/home/${userName}/.ssh/id_ed25519";
    owner = userName;
    mode = "600";
  };
  age.secrets."${userName}_authorized_keys" = {
    path = "/home/${userName}/.ssh/authorized_keys";
    owner = userName;
    mode = "600";
  };

  myServices.repoSync = {
    enable = true;
    source = "backupuser@datanixos.localdomain:/data/backup/restic/";
    destination = "/mnt/external/backup/datanixos";
    sshKeyPath = "/home/backupuser/.ssh/id_ed25519";
    timerConfig = {
      OnCalendar = "Sat *-*-* 04:00:00";
      Persistent = true;
    };
  };

  system.stateVersion = "26.05";
}
