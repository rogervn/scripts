{
  description = "A not-so-simple NixOS flake";

  nixConfig = {
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

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
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    # cachix branch (not main) + no nixpkgs.follows: both are required for the
    # noctalia.cachix.org binary cache to actually hit instead of compiling locally.
    noctalia.url = "github:noctalia-dev/noctalia/cachix";
  };

  outputs =
    {
      nixpkgs,
      agenix,
      home-manager,
      nixvim,
      nix-cachyos-kernel,
      noctalia,
      ...
    }:
    {
      nixosConfigurations = {
        amdesktop =
          let
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
              noctalia.nixosModules.default
              { home-manager.sharedModules = [ noctalia.homeModules.default ]; }
              { nixpkgs.overlays = [ nix-cachyos-kernel.overlays.pinned ]; }
            ];
          };

        thinknixos =
          let
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
              noctalia.nixosModules.default
              { home-manager.sharedModules = [ noctalia.homeModules.default ]; }
            ];
          };

        nixos-vm =
          let
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
              noctalia.nixosModules.default
              { home-manager.sharedModules = [ noctalia.homeModules.default ]; }
            ];
          };
      };
    };
}
