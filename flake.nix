{
  description = "System Configuration using Flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neorg-overlay = {
      url = "github:nvim-neorg/nixpkgs-neorg-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    bscpkgs.url = "sourcehut:~rodarima/bscpkgs";
    bscpkgs.inputs.nixpkgs.follows = "nixpkgs";


    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, sops-nix, pre-commit-hooks, ... }:
    let
      system = "x86_64-linux";

      specialArgs = { inherit self inputs; };

      extra-packages = final: prev: {
        firefox-addons = inputs.firefox-addons.packages.${system};
      };

      overlays = [
        extra-packages
        inputs.neovim-nightly-overlay.overlays.default
        inputs.neorg-overlay.overlays.default
        inputs.bscpkgs.overlays.default
        (import ./overlays/bsc.nix)
        (import ./overlays/overlay.nix)
        (import ./overlays/packages.nix)
      ];

      pin-flake-reg = with inputs; {
        nix.registry.nixpkgs.flake = nixpkgs;
        nix.registry.flake-utils.flake = flake-utils;
        nix.registry.leixb.flake = self;
      };

      common-modules = [
        ({ ... }: {
          imports = [{
            nix.nixPath = [ "nixpkgs=${nixpkgs}" "home-manager=${home-manager}" ];
            environment.sessionVariables.NIXPKGS = "${nixpkgs}";
          }];
        })
        ./cachix.nix
        ./nixos/modules/common.nix
        ./nixos/modules/hut-substituter.nix
        { nixpkgs.overlays = overlays; }
        pin-flake-reg
        sops-nix.nixosModules.sops
      ];

      inherit (nixpkgs) lib;
      pkgs = import nixpkgs { inherit system; };
    in
    {

      checks.${system}.pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          nixpkgs-fmt.enable = true;
          shfmt.enable = true;
          shellcheck = {
            enable = true;
            types_or = pkgs.lib.mkForce [ ];
          };
          stylua.enable = true;
        };
      };

      devShells.${system}.default = pkgs.mkShellNoCC {
        name = "nixos";

        buildInputs = with pkgs; [
          nixpkgs-fmt
          sops
          haskell-language-server
          (haskellPackages.ghcWithPackages (hpkgs: with hpkgs; [
            xmobar
            xmonad
            xmonad-contrib
          ]))
        ];

        inherit (self.checks.${system}.pre-commit-check) shellHook;
      };

      nixosConfigurations = {
        kuro = lib.nixosSystem {
          inherit specialArgs system;

          modules = common-modules ++ [
            ./nixos/hosts/kuro/configuration.nix
            ./nixos/modules/xorg.nix
            ./nixos/modules/gaming.nix
            ./nixos/modules/hass.nix

            ./nixos/modules/nvidia.nix

            ./nixos/modules/restic.nix
            ./nixos/modules/ssd.nix
            ./nixos/modules/synology-mounts.nix

            ./nixos/modules/virtualization.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.leix = import ./home-manager/users/leix.nix;
              home-manager.sharedModules = [
                ./home-manager/modules/home.nix
                ./home-manager/modules/common.nix
                ./home-manager/hosts/kuro.nix
                sops-nix.homeManagerModules.sops
                inputs.nix-index-database.homeModules.nix-index
                { programs.nix-index-database.comma.enable = true; }
              ];
            }
          ];
        };

        nixos-pav = lib.nixosSystem {
          inherit specialArgs system;

          modules = common-modules ++ [
            ./nixos/hosts/pavilion/configuration.nix
            ./nixos/modules/xorg.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.leix = import ./home-manager/users/leix.nix;
              home-manager.sharedModules = [
                ./home-manager/hosts/pavilion.nix
                ./home-manager/modules/home.nix
                ./home-manager/modules/common.nix
                sops-nix.homeManagerModules.sops
                inputs.nix-index-database.homeModules.nix-index
                { programs.nix-index-database.comma.enable = true; }
              ];
            }
          ];
        };

        asus = lib.nixosSystem {
          inherit specialArgs system;

          modules = common-modules ++ [
            ./nixos/hosts/asus/configuration.nix
            ./nixos/modules/nvidia.nix
            ./nixos/modules/xorg.nix
            ./nixos/modules/gnome.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.leix = import ./home-manager/users/leix.nix;
              home-manager.users.marc = import ./home-manager/users/marc.nix;
              home-manager.sharedModules = [
                ./home-manager/modules/home.nix
                ./home-manager/modules/common.nix
                ./home-manager/hosts/asus.nix
                sops-nix.homeManagerModules.sops
                inputs.nix-index-database.homeModules.nix-index
                { programs.nix-index-database.comma.enable = true; }
              ];
            }
          ];
        };

        dell = lib.nixosSystem {
          inherit specialArgs system;

          modules = common-modules ++ [
            ./nixos/hosts/dell/configuration.nix
            ./nixos/modules/virtualization.nix
            ./nixos/modules/xorg.nix
            ./nixos/modules/ssd.nix
            ./nixos/modules/sops.nix
            inputs.nixos-hardware.nixosModules.dell-latitude-7490
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.leix = import ./home-manager/users/leix.nix;
              home-manager.sharedModules = [
                ./home-manager/modules/common.nix
                ./home-manager/hosts/dell.nix
                sops-nix.homeManagerModules.sops
                inputs.nix-index-database.homeModules.nix-index
                { programs.nix-index-database.comma.enable = true; }
              ];
            }
          ];
        };
      };
    };
}
