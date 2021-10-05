{
  description = "System Configuration using Flakes";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    inherit (nixpkgs) lib;
  in {

    homeManagerConfigurations = {
      leix = home-manager.lib.homeManagerConfiguration {
        inherit system pkgs;
        username = "leix";
        homeDirectory = "/home/leix";
        stateVersion = "21.11";
        configuration = {
          imports = [
            ./users/leix/home.nix
          ];
        };
      };
    };

    nixosConfigurations = {
      nixos = lib.nixosSystem {
        inherit system;
        modules = [
          ./system/configuration.nix
        ];
      };
    };
  };
}
