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
    nixvirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    authentik-nix = {
      url = "github:nix-community/authentik-nix/version/2026.2.3";
      # DO NOT add inputs.nixpkgs.follows — explicitly unsupported by authentik-nix
    };
  };

  outputs =
    {
      nixpkgs,
      agenix,
      home-manager,
      nixvim,
      nixvirt,
      authentik-nix,
      ...
    }:
    {
      nixosConfigurations = {
        backupbox =
          let
            host = "backupbox";
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

        mininixos =
          let
            host = "mininixos";
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

        datanixos =
          let
            host = "datanixos";
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
              ../hosts/${host}/home.nix
              authentik-nix.nixosModules.default
              agenix.nixosModules.default
              home-manager.nixosModules.home-manager
            ];
          };
      };
    };
}
