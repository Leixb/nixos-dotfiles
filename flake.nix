{
  description = "System Configuration using Flakes";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nur.url = github:nix-community/NUR;
  };

  outputs = { nixpkgs, home-manager, nur, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };

    inherit (nixpkgs) lib;
  in {
    nixosConfigurations = {
      nixos = lib.nixosSystem {
        inherit system;
        modules = [
          ./system/configuration.nix
	  { nixpkgs.overlays = [ nur.overlay ]; }
	  home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.leix = import ./users/leix/home.nix;
          }
        ];
      };
    };
  };
}
