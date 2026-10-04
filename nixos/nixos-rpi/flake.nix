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
      home-manager,
      nixos-raspberrypi,
      ...
    }:
    let
      mkPi =
        host: board:
        nixos-raspberrypi.lib.nixosSystem {
          specialArgs = {
            userName = "serveruser";
            hostName = host;
            keyPath = "/root/.ssh/id_ed25519";
          };
          modules = [
            {
              imports = with nixos-raspberrypi.nixosModules; [
                board.base
                sd-image
              ];
            }
            ../hosts/${host}/configuration.nix
            ../hosts/${host}/home.nix
            ../modules/base.nix
            ../modules/secrets-rpi.nix
            ../modules/adguardhome.nix
            agenix.nixosModules.default
            home-manager.nixosModules.home-manager
            ({ pkgs, ... }: {
              environment.systemPackages = [ agenix.packages.${pkgs.stdenv.hostPlatform.system}.default ];
            })
          ];
        };
    in
    {
      nixosConfigurations = {
        pico = mkPi "pico" nixos-raspberrypi.nixosModules.raspberry-pi-3;
        pichu = mkPi "pichu" nixos-raspberrypi.nixosModules.raspberry-pi-02;
      };
      images = {
        pico = self.nixosConfigurations.pico.config.system.build.sdImage;
        pichu = self.nixosConfigurations.pichu.config.system.build.sdImage;
      };
    };
}
