{ pkgs, lib, ... }:
{
  imports = [ ../modules/sway.nix ../modules/xmonad.nix ];

  programs.foot.server.enable = true;
  home.sessionVariables.TERMINAL = lib.mkForce "footclient";

  home.packages = with pkgs; [ hyprland ];

  home.stateVersion = "21.11";
}
