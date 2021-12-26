{
  description = "System Configuration using Flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = "github:nix-community/NUR";

    rnix-lsp = {
      url = "github:nix-community/rnix-lsp";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-config = {
      url = "github:leixb/neovim-config";
      flake = false;
    };

    awesome-config = {
      url = "github:leixb/awesome-copycats";
      flake = false;
    };

  };

  outputs = inputs@{ nixpkgs, home-manager, nur, ... }:
    let
      system = "x86_64-linux";

      specialArgs = {
        inherit inputs;
      };

      extra-packages = (final: prev: {
        gof5 = prev.callPackage ./packages/gof5/default.nix {}; 

        headsetcontrol = prev.callPackage ./packages/headsetcontrol/default.nix {}; 
      });

      inherit (nixpkgs) lib;
    in
    {
      nixosConfigurations = {
        nixos = lib.nixosSystem {
          inherit system;
          inherit specialArgs;

          modules = [
            { nixpkgs.overlays = [ nur.overlay extra-packages ]; }
            ./system/lenovo/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.leix = import ./users/leix/home.nix;
              home-manager.extraSpecialArgs = specialArgs;
            }
          ];
        };
      };
    };
}
