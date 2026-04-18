{
  config,
  pkgs,
  userName,
  hostName,
  ...
}: {
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.substituters = ["https://nix-community.cachix.org"];
  nix.settings.trusted-public-keys = ["nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];
  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "Europe/London";

  nix.settings.trusted-users = [userName];

  hardware.enableAllFirmware = true;

  networking.hostName = hostName;
  networking.hostId = "1933ff80";
  networking.useNetworkd = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22 139 445 2049]; # SSH, SMB, NFS
    allowedUDPPorts = [137 138]; # SMB discovery (NetBIOS)
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
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

  # Minimal system user for Samba access only — no login shell needed
  users.users.rogervn = {
    isNormalUser = true;
    extraGroups = [];
  };

  # NFS server
  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /data/share/nfs 10.0.0.0/24(rw,sync,no_subtree_check,no_root_squash)
  '';

  # Samba
  services.samba = {
    enable = true;
    settings = {
      global = {
        workgroup = "WORKGROUP";
        "server string" = "datanixos";
        "server role" = "standalone server";
        security = "user";
      };
      share = {
        path = "/data/share/smb";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "rogervn";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
    };
  };
  services.samba-wsdd.enable = true; # Windows/macOS network discovery

  system.stateVersion = "26.05";
}
