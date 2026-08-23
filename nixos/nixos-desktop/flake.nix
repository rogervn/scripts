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
    mango = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      agenix,
      home-manager,
      nixvim,
      nix-cachyos-kernel,
      noctalia,
      mango,
      ...
    }:
    let
      # TODO: Remove once https://github.com/noctalia-dev/noctalia/pull/4073 is merged and pushed.
      noctaliaOptionalSourceOverlay = final: _: {
        noctalia-mango-optional-source-assets =
          final.runCommand "noctalia-mango-optional-source-assets" { } ''
            source_assets=${noctalia.packages.${final.stdenv.hostPlatform.system}.default}/share/noctalia/assets
            mkdir -p "$out/templates/mango"
            for asset in "$source_assets"/*; do
              [ "$(basename "$asset")" = templates ] || ln -s "$asset" "$out/$(basename "$asset")"
            done
            for template in "$source_assets/templates"/*; do
              [ "$(basename "$template")" = mango ] || ln -s "$template" "$out/templates/$(basename "$template")"
            done
            for mango_asset in "$source_assets/templates/mango"/*; do
              [ "$(basename "$mango_asset")" = apply.sh ] || ln -s "$mango_asset" "$out/templates/mango/$(basename "$mango_asset")"
            done
            substitute ${noctalia.packages.${final.stdenv.hostPlatform.system}.default}/share/noctalia/assets/templates/mango/apply.sh \
              "$out/templates/mango/apply.sh" \
              --replace-fail \
                "grep -q '^[[:space:]]*source[[:space:]]*=[[:space:]]*.*noctalia\\.conf'" \
                "grep -Eq '^[[:space:]]*source(-optional)?[[:space:]]*=[[:space:]]*.*noctalia\\.conf'"
          '';
      };
    in
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
              { home-manager.sharedModules = [ mango.hmModules.mango ]; }
              { nixpkgs.overlays = [ nix-cachyos-kernel.overlays.pinned noctaliaOptionalSourceOverlay ]; }
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
              { home-manager.sharedModules = [ mango.hmModules.mango ]; }
              { nixpkgs.overlays = [ noctaliaOptionalSourceOverlay ]; }
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
