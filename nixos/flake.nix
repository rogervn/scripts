{
  description = "A not-so-simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.amdesktop = nixpkgs.lib.nixosSystem {
      specialArgs = {
        userName = "rogervn";
        hostName = "amdesktop";
      };
      modules = [
        ./configuration.nix
        ./base.nix
        ./dotfiles.nix
        ./steam.nix
        ./window_manager.nix
        home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
      ];
    };
  };
}
