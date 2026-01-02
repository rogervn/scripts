{
  description = "My flake for raspberry pis";

  nixConfig = {
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/develop";
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
                usb-gadget-ethernet
                sd-image
              ];
            }
            ./configuration.nix
            ../modules/rpibase.nix
            ../modules/rpisdcard.nix
            ../modules/secrets.nix
            ../modules/adguardhome.nix
            agenix.nixosModules.default
            {
              environment.systemPackages = [agenix.packages.aarch64-linux.default];
            }
          ];
        };

      piuk = let
        host = "piuk";
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
            ./configuration.nix
            ../modules/rpibase.nix
            ../modules/rpisdcard.nix
            ../modules/secrets.nix
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
      piuk = self.nixosConfigurations.piuk.config.system.build.sdImage;
    };
  };
}
