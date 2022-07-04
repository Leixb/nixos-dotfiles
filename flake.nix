{
  description = "System Configuration using Flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs_stable.url = "github:nixos/nixpkgs/nixos-22.05";
    nixpkgs_trunk.url = "github:nixos/nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    awesome = {
      url = "github:awesomewm/awesome";
      flake = false;
    };

    lain = {
      url = "github:lcpz/lain";
      flake = false;
    };

    awesome-config = {
      url = "github:leixb/awesome-copycats";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.awesome.follows = "awesome";
      inputs.lain.follows = "lain";
    };

    neovim-flake.follows = "neovim-nightly-overlay/neovim-flake";

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
      # inputs.neovim-flake.inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = inputs @ {
    nixpkgs,
    home-manager,
    ...
  }: let
    system = "x86_64-linux";

    specialArgs = {
      inherit inputs;
    };

    pkg-sets = final: prev: {
      stable = import inputs.nixpkgs_stable {system = final.system;};
      trunk = import inputs.nixpkgs_trunk {system = final.system;};
    };

    extra-packages = final: prev: {
      eduroam = prev.callPackage ./packages/eduroam/default.nix {};

      firefox-addons = inputs.firefox-addons.packages.${system};
    };

    overlays = [
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

    common-modules = [
      ({...}: {
        imports = [
          {
            nix.nixPath = ["nixpkgs=${nixpkgs}"];
            environment.sessionVariables.NIXPKGS = "${nixpkgs}";
          }
        ];
      })
      {nixpkgs.overlays = overlays;}
      pin-flake-reg
    ];

    inherit (nixpkgs) lib;
  in {
    nixosConfigurations = {
      nixos = lib.nixosSystem {
        inherit system;

        modules =
          common-modules
          ++ [
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

        modules =
          common-modules
          ++ [
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
