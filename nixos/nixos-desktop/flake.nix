{
  description = "A not-so-simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    agenix,
    home-manager,
    nixvim,
    ...
  }: {
    nixosConfigurations = {
      amdesktop = let
        host = "amdesktop";
      in
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            userName = "rogervn";
            hostName = host;
            keyPath = "/root/.ssh/id_ed25519";
            inherit nixvim;
          };
          modules = [
            ../hosts/${host}/configuration.nix
            ../hosts/${host}/hardware-configuration.nix
            ../hosts/${host}/home.nix
            ../modules/base.nix
            ../modules/secrets-rogervn.nix
            ../modules/steam.nix
            ../modules/window_manager.nix
            agenix.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {inherit nixvim;};
            }
            {
              environment.systemPackages = [agenix.packages.x86_64-linux.default];
            }
          ];
        };

      thinknixos = let
        host = "thinknixos";
      in
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            userName = "rogervn";
            hostName = host;
            keyPath = "/root/.ssh/id_ed25519";
            inherit nixvim;
          };
          modules = [
            ../hosts/${host}/configuration.nix
            ../hosts/${host}/hardware-configuration.nix
            ../hosts/${host}/home.nix
            ../modules/base.nix
            ../modules/secrets-rogervn.nix
            ../modules/window_manager.nix
            agenix.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {inherit nixvim;};
            }
            {
              environment.systemPackages = [agenix.packages.x86_64-linux.default];
            }
          ];
        };

      nixos-vm = let
        host = "nixos-vm";
      in
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            userName = "rogervn";
            hostName = host;
            keyPath = "/root/.ssh/id_ed25519";
            inherit nixvim;
          };
          modules = [
            ../hosts/${host}/configuration.nix
            ../hosts/${host}/hardware-configuration.nix
            ../hosts/${host}/home.nix
            ../modules/base.nix
            ../modules/secrets-rogervn.nix
            ../modules/vm_guest.nix
            ../modules/window_manager.nix
            ../modules/zfs.nix
            agenix.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {inherit nixvim;};
            }
            {
              environment.systemPackages = [agenix.packages.x86_64-linux.default];
            }
          ];
        };
    };
  };
}
