{
  config,
  lib,
  pkgs,
  system,
  inputs,
  ...
}: let
  theme = import ./theme.nix;
in {
  xdg.configFile = {
    "awesome".source = pkgs.awesome-config;
  };

  home.packages = with pkgs; [
    i3lock-fancy-rapid
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
    font = "${theme.font_family} ${theme.font_size}";
    extraConfig = {
      modi = "combi,drun,window";
      show-icons = true;
      cycle = false;
      combi-modi = "window,drun";
      combi-hide-mode-prefix = true;
      display-combi = "";
    };
    theme = builtins.toFile "theme.rasi" (with theme; ''
      * {
          background: ${background};
          foreground: ${foreground};
          border-color: ${color15};
          primary: ${color4};
          accent: ${color6};
          urgent: ${color9};
          urgent-alt: ${color1};
      }
    '' + builtins.readFile ./rofi_theme.rasi);
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

  xresources.extraConfig = ''
    ! ${theme.name}

    *.background: ${theme.background}
    *.foreground: ${theme.foreground}

    !black
    *color0: ${theme.color0}
    *color8: ${theme.color8}

    !red
    *color1: ${theme.color1}
    *color9: ${theme.color9}

    !green
    *color2: ${theme.color2}
    *color10: ${theme.color10}

    !yellow
    *color3: ${theme.color3}
    *color11: ${theme.color11}

    !blue
    *color4: ${theme.color4}
    *color12: ${theme.color12}

    !magenta
    *color5: ${theme.color5}
    *color13: ${theme.color13}

    !cyan
    *color6: ${theme.color6}
    *color14: ${theme.color14}

    !white
    *color7: ${theme.color7}
    *color15: ${theme.color15}
  '';
}
