{
  description = "System Configuration using Flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs_stable.url = "github:nixos/nixpkgs/nixos-21.11";
    nixpkgs_trunk.url = "github:nixos/nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    rnix-lsp = {
      url = "github:nix-community/rnix-lsp";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    neovim-config = {
      url = "github:leixb/neovim-config";
      flake = false;
    };

    comma = {
      url = "github:nix-community/comma";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    awesome-config = {
      url = "github:leixb/awesome-copycats";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
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

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = inputs@{ nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";

      specialArgs = {
        inherit inputs;
      };

      pkg-sets = final: prev: {
        stable = import inputs.nixpkgs_stable { system = final.system; };
        trunk = import inputs.nixpkgs_trunk { system = final.system; };
      };

      extra-packages = (final: prev: {
        gof5 = prev.callPackage ./packages/gof5/default.nix {}; 
        comma = inputs.comma.packages.${system}.comma;

        firefox-addons = inputs.firefox-addons.packages.${system};
      });

      overlays =  [
        pkg-sets
        extra-packages
        inputs.awesome-config.overlay
        inputs.neovim-nightly-overlay.overlay
      ];

      pin-flake-reg = with inputs; {
        nix.registry.nixpkgs.flake = nixpkgs;
        nix.registry.flake-utils.flake = flake-utils;
        nix.registry.leixb.flake = self;
      };

      common-modules = {
        nixpkgs.overlays = overlays;
        nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
      } // pin-flake-reg;

      inherit (nixpkgs) lib;
    in
    {
      nixosConfigurations = {
        nixos = lib.nixosSystem {
          inherit system;

          modules = [
            common-modules
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

          modules = [
            common-modules
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
