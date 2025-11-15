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

    neorg-overlay = {
      url = "github:nvim-neorg/nixpkgs-neorg-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    jungle.url = "https://jungle.bsc.es/git/rarias/jungle/archive/master.tar.gz";
    jungle.inputs.nixpkgs.follows = "nixpkgs";

    paraver-kernel.url = "git+ssh://git@bscpm04.bsc.es/rarias/paraver-kernel.git";
    paraver-kernel.inputs.bscpkgs.follows = "jungle";

    wxparaver.url = "git+ssh://git@bscpm04.bsc.es/rarias/wxparaver.git";
    wxparaver.inputs.paraver-kernel.follows = "paraver-kernel";
    wxparaver.inputs.bscpkgs.follows = "jungle";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    autofirma-nix = {
      url = "github:nix-community/autofirma-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      sops-nix,
      pre-commit-hooks,
      ...
    }:
    let
      system = "x86_64-linux";

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
          (haskellPackages.ghcWithPackages (
            hpkgs: with hpkgs; [
              xmobar
              xmonad
              xmonad-contrib
            ]
          ))
        ];

        inherit (self.checks.${system}.pre-commit-check) shellHook;
      };

      nixosConfigurations =
        let
          mkSystem =
            name:
            lib.nixosSystem {
              specialArgs = { inherit self inputs; };

              modules = [
                ./nixos/modules/common.nix
                ./nixos/hosts/${name}/configuration.nix
                { home-manager.sharedModules = [ ./home-manager/hosts/${name}.nix ]; }
              ];
            };
        in
        lib.genAttrs [
          "kuro"
          "pavilion"
          "asus"
          "dell"
        ] mkSystem;
    };
}
