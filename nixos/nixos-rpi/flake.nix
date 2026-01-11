{
  description = "My flake for raspberry pis";

  nixConfig = {
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    agenix.url = "github:ryantm/agenix";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
  };

  outputs = {
    self,
    nixpkgs,
    agenix,
    nixos-raspberrypi,
    ...
  } @ inputs: {
    nixosConfigurations = {
      pi3nixos = let
        host = "pi3nixos";
      in
        nixos-raspberrypi.lib.nixosSystemFull {
          system = "aarch64-linux";
          specialArgs = {
            userName = "piuk";
            hostName = host;
            keyPath = "/root/.ssh/id_ed25519";
            swapSizeGB = 1;
            inherit inputs nixos-raspberrypi;
          };
          modules = [
            {
              imports = with nixos-raspberrypi.nixosModules; [
                raspberry-pi-3.base
                sd-image
              ];
            }
            ../hosts/${host}/configuration.nix
            ../modules/base.nix
            ../modules/rpisdcard.nix
            ../modules/secrets-piuk.nix
            ../modules/adguardhome.nix
            agenix.nixosModules.default
            {
              environment.systemPackages = [agenix.packages.aarch64-linux.default];
            }
          ];
        };

      pi02nixos = let
        host = "pi02nixos";
      in
        nixos-raspberrypi.lib.nixosSystemFull {
          system = "aarch64-linux";
          specialArgs = {
            userName = "piuk";
            hostName = host;
            keyPath = "/root/.ssh/id_ed25519";
            swapSizeGB = 1;
            inherit inputs nixos-raspberrypi;
          };
          modules = [
            {
              imports = with nixos-raspberrypi.nixosModules; [
                raspberry-pi-02.base
                usb-gadget-ethernet
                sd-image
              ];
            }
            ../hosts/${host}/configuration.nix
            ../modules/base.nix
            ../modules/rpisdcard.nix
            ../modules/secrets-piuk.nix
            ../modules/adguardhome.nix
            agenix.nixosModules.default
            {
              environment.systemPackages = [agenix.packages.aarch64-linux.default];
            }
          ];
        };
    };
    images = {
      pi3nixos = self.nixosConfigurations.pi3nixos.config.system.build.sdImage;
      pi02nixos = self.nixosConfigurations.pi02nixos.config.system.build.sdImage;
    };
  };
}
