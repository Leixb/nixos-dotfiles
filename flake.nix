{
  description = "System Configuration using Flakes";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nur.url = github:nix-community/NUR;

    neovim-config = {
      url = github:leixb/neovim-config;
      flake = false;
    };

    rnix-lsp = {
      url = github:nix-community/rnix-lsp;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nur, neovim-config, rnix-lsp, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      inherit neovim-config;
      inherit rnix-lsp;

      specialArgs = {
        inherit neovim-config;
        inherit rnix-lsp;
      };

      inherit (nixpkgs) lib;
    in
    {
      nixosConfigurations = {
        nixos = lib.nixosSystem {
          inherit system;
          modules = [
            ./system/configuration.nix
            { nixpkgs.overlays = [ nur.overlay ]; }
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
