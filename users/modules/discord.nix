{ config, lib, pkgs, ... }:

with lib;

let cfg = config.programs.discord;
in {
  options = {
    programs.discord = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable discord configuration
        '';
      };

      package = mkPackageOption pkgs "discord" { };
      openASAR = mkEnableOption "openASAR";

      options = mkOption {
        type = with types; nullOr (attrsOf anything);
        default = null;
        description = ''
          Options to pass to discord
        '';
      };
    };
  };

  config = mkIf cfg.enable {

    home.packages = [
      (if cfg.openASAR then
        cfg.package.override { withOpenASAR = cfg.openASAR; }
      else
        cfg.package)
    ];

    # xdg.configFile."discord/settings.json".text =
    #   mkIf (cfg.options != null) (builtins.toJSON cfg.options);

  };
}
