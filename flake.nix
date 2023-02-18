{
  description = "System Configuration using Flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs_stable.url = "github:nixos/nixpkgs/nixos-22.05";
    nixpkgs_trunk.url = "github:nixos/nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };

    devenv = {
      url = "github:cachix/devenv/v0.5.1";
      # inputs.nixpkgs.follows = "nixpkgs";
      # inputs.pre-commit-hooks.follows = "pre-commit-hooks";
      # inputs.flake-compat.follows = "flake-compat";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
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

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # neorg = {
    #   url = "github:nvim-neorg/neorg";
    #   flake = false;
    # };

    # neovim-flake.follows = "neovim-nightly-overlay/neovim-flake";
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      # inputs.nixpkgs.follows = "nixpkgs";
      # Pin to a nixpkgs revision that doesn't have NixOS/nixpkgs#208103 yet
      inputs.nixpkgs.url = "github:nixos/nixpkgs?rev=fad51abd42ca17a60fc1d4cb9382e2d79ae31836";
      inputs.flake-compat.follows = "flake-compat";
      # inputs.neovim-flake.inputs.flake-utils.follows = "flake-utils";
    };

    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.flake-utils.follows = "flake-utils";
    };

    nvim-R = {
      url = "github:jalvesaq/Nvim-R/v0.9.17";
      flake = false;
    };

    nix-matlab = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "gitlab:doronbehar/nix-matlab";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, sops-nix, agenix, pre-commit-hooks, devenv, hyprland, ... }:
    let
      system = "x86_64-linux";

      specialArgs = { inherit inputs; };

      pkg-sets = final: prev: {
        stable = import inputs.nixpkgs_stable { inherit (final) system; };
        trunk = import inputs.nixpkgs_trunk { inherit (final) system; };
      };

      extra-packages = final: prev: {
        eduroam = prev.callPackage ./packages/eduroam/default.nix { };

        vimPlugins = prev.vimPlugins // {
          gitsigns-nvim-fixed = prev.callPackage ./packages/gitsigns-nvim-fixed { };
        };

        nix-index-database =
          inputs.nix-index-database.outputs.legacyPackages.${system}.database;
        firefox-addons = inputs.firefox-addons.packages.${system};
      };

      overlays = [
        pkg-sets
        extra-packages
        inputs.awesome-config.overlay
        inputs.neovim-nightly-overlay.overlay
        inputs.nix-minecraft.overlay
        inputs.nix-matlab.overlay
        (self: super: {
          waybar = super.waybar.overrideAttrs (oldAttrs: {
            mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
          });
        })
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
          }
            inputs.nix-minecraft.nixosModules.minecraft-servers];
        })
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
        ];

        inherit (self.checks.${system}.pre-commit-check) shellHook;
      };

      nixosConfigurations = {
        kuro = lib.nixosSystem {
          inherit system;

          modules = common-modules ++ [
            ./system/lenovo/configuration.nix
            home-manager.nixosModules.home-manager
            hyprland.nixosModules.default
            { programs.hyprland.enable = true; }
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

          modules = common-modules ++ [
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

      colmena = {
        meta = {
          description = "My personal machines";
          nixpkgs = import nixpkgs { inherit system; };
        };

      } // builtins.mapAttrs
        (name: value: {
          nixpkgs.system = value.config.nixpkgs.system;
          imports = value._module.args.modules;
          deployment.allowLocalDeployment = true;
        })
        self.nixosConfigurations;

      # deploy.nodes.kuro = {
      #   hostname = "localhost";
      #   fastConnection = true;
      #   sshOpts = [ "-t" ];
      #   profiles.system = {
      #     user = "root";
      #     path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.kuro;
      #   };
      # };

    };
}
