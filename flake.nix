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

    devenv = {
      url = "github:cachix/devenv/latest";
      # inputs.nixpkgs.follows = "nixpkgs";
      inputs.pre-commit-hooks.follows = "pre-commit-hooks";
      inputs.flake-compat.follows = "flake-compat";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, sops-nix, agenix, pre-commit-hooks, devenv, ... }:
    let
      system = "x86_64-linux";

      specialArgs = { inherit inputs; };

      extra-packages = final: prev: {
        eduroam = prev.callPackage ./packages/eduroam/default.nix { };

        jutge = prev.callPackage ./packages/jutge/default.nix { };

        zotero7 = prev.callPackage ./packages/zotero/default.nix { };

        devenv = devenv.packages.${system}.devenv;

        modrinth_server_modpack = prev.callPackage ./packages/modrinth_server_modpack/default.nix { };

        kitty-imgdiff = prev.callPackage ./packages/kitty-imgdiff/default.nix { };

        nix-index-database =
          inputs.nix-index-database.outputs.legacyPackages.${system}.database;
        firefox-addons = inputs.firefox-addons.packages.${system};

        mpris-notifier = prev.callPackage ./packages/mpris-notifier/default.nix { };

        nixVersions = prev.nixVersions // { unstable = prev.nixVersions.git; };
      };

      overlays = [
        extra-packages
        inputs.neovim-nightly-overlay.overlays.default
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
        { nixpkgs.overlays = overlays; }
        pin-flake-reg
        sops-nix.nixosModules.sops
        agenix.nixosModules.age
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
          inherit system;

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
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.sharedModules = [
                ./home-manager/modules/home.nix
                ./home-manager/hosts/kuro.nix
                sops-nix.homeManagerModules.sops
              ];
            }
          ];
        };

        nixos-pav = lib.nixosSystem {
          inherit system;

          modules = common-modules ++ [
            ./nixos/hosts/pavilion/configuration.nix
            ./nixos/modules/xorg.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.leix = import ./home-manager/users/leix.nix;
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.sharedModules = [
                ./home-manager/hosts/pavilion.nix
                ./home-manager/modules/home.nix
                sops-nix.homeManagerModules.sops
              ];
            }
          ];
        };

        asus = lib.nixosSystem {
          inherit system;

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
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.sharedModules = [
                ./home-manager/modules/home.nix
                ./home-manager/hosts/asus.nix
                sops-nix.homeManagerModules.sops
              ];
            }
          ];
        };
      };
    };
}
