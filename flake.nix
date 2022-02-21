{
  description = "System Configuration using Flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

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
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.awesome = {
        type = "github";
        owner = "awesomewm";
        repo = "awesome";
      };
      inputs.lain = {
        type = "github";
        owner = "lcpz";
        repo = "lain";
      };
    };

  };

  outputs = inputs@{ nixpkgs, home-manager, nur, awesome-config, ... }:
    let
      system = "x86_64-linux";

      specialArgs = {
        inherit inputs;
      };

      extra-packages = (final: prev: {
        gof5 = prev.callPackage ./packages/gof5/default.nix {}; 
      });

      inherit (nixpkgs) lib;
    in
    {
      nixosConfigurations = {
        nixos = lib.nixosSystem {
          inherit system;
          inherit specialArgs;

          modules = [
            { nixpkgs.overlays = [ 
              nur.overlay
              extra-packages
              awesome-config.overlay
            ]; }
            ./system/lenovo/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.leix = import ./users/leix/lenovo.nix;
              home-manager.extraSpecialArgs = specialArgs;
            }
          ];
        };

        nixos-pav = lib.nixosSystem {
          inherit system;
          inherit specialArgs;

          modules = [
            { nixpkgs.overlays = [ 
              nur.overlay
              extra-packages
              awesome-config.overlay
            ]; }
            ./system/pavilion/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.leix = import ./users/leix/pavilion.nix;
              home-manager.extraSpecialArgs = specialArgs;
            }
          ];
        };
      };
    };
}
