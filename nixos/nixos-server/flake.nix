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
  };

  outputs = {
    nixpkgs,
    agenix,
    home-manager,
    nixvim,
    nixvirt,
    ...
  }: {
    nixosConfigurations = {
      backupbox = let
        host = "backupbox";
      in
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            userName = "backupuser";
            hostName = host;
            keyPath = "/root/.ssh/id_ed25519";
            inherit nixvim;
          };
          modules = [
            ../hosts/${host}/configuration.nix
            ../hosts/${host}/hardware-configuration.nix
            ../hosts/${host}/home.nix
            ../modules/base.nix
            ../modules/secrets-backupuser.nix
            ../modules/borgrepo_sync.nix
            agenix.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {inherit nixvim;};
            }
            {
              environment.systemPackages = [agenix.packages.x86_64-linux.default];
            }
          ];
        };

      mininixos = let
        host = "mininixos";
      in
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            userName = "serveruser";
            hostName = host;
            keyPath = "/root/.ssh/id_ed25519";
            inherit nixvim nixvirt;
          };
          modules = [
            nixvirt.nixosModules.default
            ../hosts/${host}/configuration.nix
            ../hosts/${host}/hardware-configuration.nix
            ../hosts/${host}/home.nix
            ../modules/base.nix
            ../modules/secrets-serveruser.nix
            ../modules/adguardhome.nix
            ../modules/home_assistant.nix
            ../modules/uptime_kuma.nix
            ../modules/restic-backup.nix
            ../modules/vaultwarden.nix
            agenix.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {inherit nixvim;};
            }
            {
              environment.systemPackages = [agenix.packages.x86_64-linux.default];
            }
          ];
        };
    };
  };
}
