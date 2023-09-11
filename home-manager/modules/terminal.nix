{ config, lib, pkgs, ... }:

let cfg = config.terminal;
in {
  options.terminal = {
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.kitty;
      description = "The terminal to use";
    };
    flags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Flags to pass to the terminal";
    };
  };

  config = let name = lib.getName cfg.package; in {
    home.sessionVariables = {
      TERMINAL = name;
    };
    programs.${name}.enable = true;
  };
}
