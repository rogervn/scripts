{
  description = "A not-so-simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, agenix, home-manager,  ... }@inputs:
  {
    nixosConfigurations.amdesktop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        userName = "rogervn";
        hostName = "amdesktop";
      };
      modules = [
        ./configuration.nix
        ./base.nix
        ./dotfiles.nix
        ./secrets.nix
        ./steam.nix
        ./window_manager.nix
        agenix.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
        {
          environment.systemPackages = [ agenix.packages.x86_64-linux.default ];
        }
      ];
    };
    nixosConfigurations.nixos-vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        userName = "rogervn";
        hostName = "nixos-vm";
      };
      modules = [
        ./configuration.nix
        ./base.nix
        ./dotfiles.nix
        ./secrets.nix
        ./vm_guest.nix
        ./window_manager.nix
        agenix.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
        {
          environment.systemPackages = [ agenix.packages.x86_64-linux.default ];
        }
      ];
    };
  };
}
