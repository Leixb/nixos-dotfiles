{
  config,
  lib,
  pkgs,
  system,
  inputs,
  ...
}: let
  theme = import ./theme.nix;

  discord-settings = {
    SKIP_HOST_UPDATE = true;
    BACKGROUND_COLOR = theme.background;

    IS_MAXIMIZED = false;
    IS_MINIMIZED = false;

    MIN_WIDTH = 0;
    MIN_HEIGHT = 0;

    openasar = {
      setup = true;
      quickstart = true;
    };
  };
in {
  home.packages = [(pkgs.discord.override { withOpenASAR = true; })];
  xdg.configFile."discord/settings.json".text = builtins.toJSON discord-settings;
}
