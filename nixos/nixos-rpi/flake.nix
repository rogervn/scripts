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
            userName = "rogervn";
            hostName = host;
            keyPath = "/root/.ssh/id_ed25519";
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
            ../modules/secrets.nix
            agenix.nixosModules.default
            {
              environment.systemPackages = [agenix.packages.aarch64-linux.default];
            }
          ];
        };
    };
    images = {
      pi3nixos = self.nixosConfigurations.pi3nixos.config.system.build.sdImage;
    };
  };
}
