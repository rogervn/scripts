{
  description = "My flake for raspberry pis";

  nixConfig = {
    extra-substituters = [ "https://nixos-raspberrypi.cachix.org" ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  inputs = {
    # Never override nixos-raspberrypi's nixpkgs: the cachix kernels are built against its lock.
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
    nixpkgs.follows = "nixos-raspberrypi/nixpkgs";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      agenix,
      disko,
      home-manager,
      nixos-raspberrypi,
      ...
    }:
    let
      mkPi =
        host: board: extraModules:
        nixos-raspberrypi.lib.nixosSystem {
          specialArgs = {
            userName = "serveruser";
            hostName = host;
            keyPath = "/root/.ssh/id_ed25519";
          };
          modules = [
            board.base
            ../hosts/${host}/configuration.nix
            ../hosts/${host}/home.nix
            ../modules/base.nix
            ../modules/secrets-rpi.nix
            agenix.nixosModules.default
            home-manager.nixosModules.home-manager
            ({ pkgs, ... }: {
              environment.systemPackages = [ agenix.packages.${pkgs.stdenv.hostPlatform.system}.default ];
            })
          ]
          ++ extraModules;
        };
      # SD-card hosts boot the image built by write-sdcard.sh
      sdImage = [ nixos-raspberrypi.nixosModules.sd-image ];
    in
    {
      nixosConfigurations = {
        pico = mkPi "pico" nixos-raspberrypi.nixosModules.raspberry-pi-3 sdImage;
        pichu = mkPi "pichu" nixos-raspberrypi.nixosModules.raspberry-pi-02 sdImage;
        # Installed onto its USB SSD with nixos-anywhere from the rpi5 installer
        pikachu = mkPi "pikachu" nixos-raspberrypi.nixosModules.raspberry-pi-5 [
          disko.nixosModules.disko
          ../hosts/pikachu/disko.nix
        ];
      };
      images = {
        pico = self.nixosConfigurations.pico.config.system.build.sdImage;
        pichu = self.nixosConfigurations.pichu.config.system.build.sdImage;
        # nvmd's installer, using the root password hash write-installer.sh puts on the card
        rpi5-installer =
          (nixos-raspberrypi.nixosConfigurations.rpi5-installer.extendModules {
            modules = [
              (
                { lib, pkgs, ... }:
                {
                  # Installer ships ZFS support but never boots from a ZFS root
                  boot.zfs.forceImportRoot = false;
                  system.activationScripts.root-password = lib.mkForce ''
                    mkdir -p /var/shared
                    if [ -f /var/lib/installer/root-password-hash ]; then
                      echo "root:$(cat /var/lib/installer/root-password-hash)" | ${pkgs.shadow}/bin/chpasswd -e
                      echo "(set by write-installer.sh)" > /var/shared/root-password
                    else
                      ${pkgs.xkcdpass}/bin/xkcdpass --numwords 3 --delimiter - --count 1 > /var/shared/root-password
                      echo "root:$(cat /var/shared/root-password)" | ${pkgs.shadow}/bin/chpasswd
                    fi
                  '';
                }
              )
            ];
          }).config.system.build.sdImage;
      };
    };
}
