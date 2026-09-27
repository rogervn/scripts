{
  description = "A not-so-simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    mango = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      agenix,
      disko,
      home-manager,
      nixvim,
      nix-cachyos-kernel,
      mango,
      ...
    }:
    {
      nixosConfigurations = {
        kratos =
          let
            host = "kratos";
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
              { home-manager.sharedModules = [ mango.hmModules.mango ]; }
              { nixpkgs.overlays = [ nix-cachyos-kernel.overlays.pinned ]; }
            ];
          };

        deckard =
          let
            host = "deckard";
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
              { home-manager.sharedModules = [ mango.hmModules.mango ]; }
            ];
          };

        megaman =
          let
            host = "megaman";
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

        glados =
          let
            host = "glados";
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
              ../hosts/${host}/disko.nix
              ../hosts/${host}/home.nix
              disko.nixosModules.disko
              agenix.nixosModules.default
              home-manager.nixosModules.home-manager
            ];
          };
      };
    };
}
