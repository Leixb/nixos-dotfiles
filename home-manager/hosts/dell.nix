{ pkgs, ... }:
{
  imports = [
    ../modules/xmonad.nix
    ../modules/bsc/bsc.nix
  ];

  home.packages = with pkgs; [ ];

  home.stateVersion = "24.05";
}
