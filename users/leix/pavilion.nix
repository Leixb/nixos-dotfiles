{ config, lib, pkgs, inputs, ... }: {
  imports = [ ./common.nix ./sway.nix ];
  programs.foot.server.enable = true;
  home.sessionVariables.TERMINAL = lib.mkForce "footclient";

  home.packages = with pkgs; [ hyprland ];
}
