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
            agenixPackage = agenix.packages.x86_64-linux.default;
          };
          modules = [
            ../hosts/${host}/configuration.nix
            ../hosts/${host}/hardware-configuration.nix
            ../hosts/${host}/home.nix
            agenix.nixosModules.default
            home-manager.nixosModules.home-manager
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
            agenixPackage = agenix.packages.x86_64-linux.default;
          };
          modules = [
            ../hosts/${host}/configuration.nix
            ../hosts/${host}/hardware-configuration.nix
            ../hosts/${host}/home.nix
            agenix.nixosModules.default
            home-manager.nixosModules.home-manager
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
            agenixPackage = agenix.packages.x86_64-linux.default;
          };
          modules = [
            ../hosts/${host}/configuration.nix
            ../hosts/${host}/hardware-configuration.nix
            ../hosts/${host}/home.nix
            agenix.nixosModules.default
            home-manager.nixosModules.home-manager
          ];
        };
    };
  };
}
