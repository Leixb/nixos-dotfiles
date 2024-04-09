{ pkgs, lib, ... }:
{
  imports = [ ../modules/sway.nix ../modules/xmonad.nix ];

  programs.foot.server.enable = true;
  home.sessionVariables.TERMINAL = lib.mkForce "footclient";

  home.packages = with pkgs; [ hyprland ];

  services.trayer.settings.height = 30;

  home.stateVersion = "21.11";
}
