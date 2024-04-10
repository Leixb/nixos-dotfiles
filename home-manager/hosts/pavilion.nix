{ pkgs, lib, ... }:
{
  imports = [ ../modules/sway.nix ../modules/xmonad.nix ];

  programs.foot.server.enable = true;
  home.sessionVariables.TERMINAL = lib.mkForce "footclient";

  home.packages = with pkgs; [ hyprland ];

  services.trayer.settings.height = 30;

  services.dunst.settings.global = {
    offset = "10x40";
    width = "(0, 512)";
    max_icon_size = "128";
  };

  theme.font.size = 9;

  home.pointerCursor.size = 24;

  home.stateVersion = "21.11";
}
