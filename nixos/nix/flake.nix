{
  description = "Flake to use home-manager in other distros";

  nixConfig = {
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

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
    pam_shim = {
      url = "github:Cu3PO42/pam_shim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # cachix branch (not main) + no nixpkgs.follows: both are required for the
    # noctalia.cachix.org binary cache to actually hit instead of compiling locally.
    noctalia.url = "github:noctalia-dev/noctalia/cachix";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nixvim,
      pam_shim,
      noctalia,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      userName = "rogervn";
    in
    {
      homeConfigurations = {
        rogervn-desktop = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit
              userName
              nixvim
              pam_shim
              noctalia
              ;
          };
          modules = [
            ./home-desktop.nix
            noctalia.homeModules.default
          ];
        };
        rogervn-headless = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit userName nixvim; };
          modules = [ ./home-headless.nix ];
        };
      };
    };
}
