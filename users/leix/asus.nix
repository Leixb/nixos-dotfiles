{ config, lib, pkgs, system, inputs, ... }:
{
  imports = [ ./common.nix ./sway.nix ./gaming.nix ./awesomewm.nix ];
}
