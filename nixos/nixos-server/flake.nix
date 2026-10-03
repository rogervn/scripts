{
  description = "A not-so-simple NixOS flake";

  nixConfig = {
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

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
    nixvirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    authentik-nix = {
      url = "github:nix-community/authentik-nix/version/2026.8.3";
      # DO NOT add inputs.nixpkgs.follows — explicitly unsupported by authentik-nix
    };
  };

  outputs =
    {
      nixpkgs,
      agenix,
      disko,
      home-manager,
      nixvim,
      nixvirt,
      authentik-nix,
      ...
    }:
    {
      nixosConfigurations = {
        snorlax =
          let
            host = "snorlax";
          in
          nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {
              userName = "backupuser";
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

        mog =
          let
            host = "mog";
          in
          nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {
              userName = "serveruser";
              hostName = host;
              keyPath = "/root/.ssh/id_ed25519";
              inherit nixvim nixvirt;
              agenixPackage = agenix.packages.x86_64-linux.default;
            };
            modules = [
              ../hosts/${host}/configuration.nix
              ../hosts/${host}/hardware-configuration.nix
              ../hosts/${host}/home.nix
              nixvirt.nixosModules.default
              agenix.nixosModules.default
              home-manager.nixosModules.home-manager
            ];
          };

        kirby =
          let
            host = "kirby";
          in
          nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {
              userName = "datauser";
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
              authentik-nix.nixosModules.default
              agenix.nixosModules.default
              home-manager.nixosModules.home-manager
            ];
          };
      };
    };
}
