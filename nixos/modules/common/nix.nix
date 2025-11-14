{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nixVersions.latest;
    extraOptions = ''
      experimental-features = nix-command flakes ca-derivations
      keep-outputs = true
      keep-derivations = true
    '';

    settings = {
      trusted-users = [
        "root"
        "@wheel"
      ];
      auto-optimise-store = true;

      connect-timeout = 5;

      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
        "https://devenv.cachix.org"
        "https://hyprland.cachix.org"
      ];

      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
    gc.automatic = true;
  };

  programs.nh = {
    enable = true;
    # clean.enable = true;
    # clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/leix/.dotfiles";
  };
}
