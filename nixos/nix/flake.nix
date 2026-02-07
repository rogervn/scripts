{
  description = "Flake to use home-manager in other distros";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
    home-manager,
    nixvim,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    userName = "rogervn";
  in {
    packages.${system}.fedora = pkgs.buildEnv {
      name = "fedora";
      paths = [
        pkgs.hyprland
        pkgs.hyprpolkitagent
        pkgs.noctalia-shell
        pkgs.xdg-desktop-portal-hyprland
      ];
    };
    homeConfigurations = {
      ${userName} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {inherit userName nixvim;};
        modules = [
          ./home.nix
        ];
      };
    };
  };
}
