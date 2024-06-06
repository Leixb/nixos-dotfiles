{ pkgs, ... }:
{
  imports = [
    ../modules/xmonad.nix
    ../modules/bsc/bsc.nix
  ];

  services.dunst.settings.global = {
    offset = "10x40";
    width = "(0, 512)";
    max_icon_size = "128";
  };

  theme.font.size = 9;

  home.pointerCursor.size = 24;

  home.stateVersion = "24.05";
}
