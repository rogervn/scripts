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
    ...
  } @ inputs: {
    nixosConfigurations.amdesktop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        userName = "rogervn";
        hostName = "amdesktop";
        inherit inputs;
      };
      modules = [
        ./configuration.nix
        ./home.nix
        ../hosts/amdesktop/hardware-configuration.nix
        ../modules/base.nix
        ../modules/secrets.nix
        ../modules/steam.nix
        ../modules/window_manager.nix
        agenix.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {inherit inputs;};
        }
        {
          environment.systemPackages = [agenix.packages.x86_64-linux.default];
        }
      ];
    };

    nixosConfigurations.thinknixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        userName = "rogervn";
        hostName = "thinknixos";
        inherit inputs;
      };
      modules = [
        ./configuration.nix
        ./home.nix
        ../hosts/amdesktop/hardware-configuration.nix
        ../modules/base.nix
        ../modules/secrets.nix
        ../modules/window_manager.nix
        agenix.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {inherit inputs;};
        }
        {
          environment.systemPackages = [agenix.packages.x86_64-linux.default];
        }
      ];
    };

    nixosConfigurations.nixos-vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        userName = "rogervn";
        hostName = "nixos-vm";
        inherit inputs;
      };
      modules = [
        ./configuration.nix
        ./home.nix
        ../hosts/nixos-vm/hardware-configuration.nix
        ../modules/base.nix
        ../modules/secrets.nix
        ../modules/vm_guest.nix
        ../modules/window_manager.nix
        agenix.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {inherit inputs;};
        }
        {
          environment.systemPackages = [agenix.packages.x86_64-linux.default];
        }
      ];
    };
  };
}
