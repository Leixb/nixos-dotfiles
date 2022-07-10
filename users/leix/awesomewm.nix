{
  config,
  lib,
  pkgs,
  system,
  inputs,
  ...
}:

{
  xdg.configFile = {
    "awesome".source = pkgs.awesome-config;
  };

  home.packages = with pkgs; [
    (i3lock-fancy-rapid.override {
      i3lock = pkgs.writeShellScriptBin "i3lock" ''
        ${pkgs.i3lock-color}/bin/i3lock-color "$@"
      '';
    })
    xsel
  ];

  services = {
    picom = {
      enable = true;
      backend = "glx";
      experimentalBackends = true;
      vSync = true;
      blur = true;
      blurExclude = [
        "window_type = 'dock'"
      ];
      extraOptions = ''
        unredir-if-possible = true;
        use-damage = true;
        detect-transient = true;
        detect-client-leader = true;
        xrender-sync-fence = true;

        blur:
        {
          method = "dual_kawase";
        };
      '';
    };

    udiskie.enable = true;

    unclutter.enable = true;
  };

  programs.rofi = {
    enable = true;
    extraConfig = {
      modi = "combi,drun,window";
      show-icons = true;
      cycle = false;
      combi-modi = "window,drun";
      combi-hide-mode-prefix = true;
      display-combi = "";
    };
  };

  home.pointerCursor.x11.enable = true;

  xsession = {
    enable = true;

    numlock.enable = true;

    windowManager.awesome = {
      enable = true;
      luaModules = with pkgs; [lain];
      package = pkgs.awesome;
    };
  };

}
