{ config, lib, pkgs, system, inputs, ... }:
{
  imports = [ ./leix.nix ./home.nix ./sway.nix ./gaming.nix ./awesomewm.nix ];
}
