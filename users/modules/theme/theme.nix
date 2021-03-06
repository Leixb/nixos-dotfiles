{ config, lib, pkgs, ... }:

with lib;

let cfg = config.theme;
in {
  options = {
    theme = {
      enable = mkEnableOption "enable";

      name = mkOption {
        type = types.str;
        default = "Catppuccin Macchiato";
        description = ''
          Name of the theme
        '';
      };

      font = {
        family = mkOption {
          type = types.str;
          default = "sans-serif";
          description = ''
            Font Family
          '';
        };

        size = mkOption {
          type = types.int;
          default = 11;
          description = ''
            Font Size
          '';
        };
      };

      wallpaper = mkOption {
        type = types.path;
        default = ./leix/wallpaper/keyboards.png;
        description = ''
          Wallpaper
        '';
      };

      palette = mkOption {
        type = with types; attrsOf (strMatching "#[0123456789ABCDEFabcdef]+");
        default = import ./palette.nix;
        description = ''
          Color palette
        '';
      };

      enableKittyTheme = mkEnableOption "enableKittyTheme";
      enableBatTheme = mkEnableOption "enableBatTheme";
    };
  };

  config = let
    base16 = with cfg.palette; {
      #black
      color0 = darkgray1;
      color8 = darkgray2;
      # red";
      color1 = red;
      color9 = red;
      # green";
      color2 = green;
      color10 = green;
      # yellow";
      color3 = yellow;
      color11 = yellow;
      # blue";
      color4 = blue;
      color12 = blue;
      # magenta";
      color5 = pink;
      color13 = pink;
      # cyan";
      color6 = teal;
      color14 = teal;
      # white";
      color7 = lightgray1;
      color15 = lightgray2;
    };
  in mkIf cfg.enable (mkMerge [
    {

      programs.fish.interactiveShellInit = with cfg.palette; ''
        set fish_color_normal         "${blue}"  # default color
        set fish_color_command        "${blue}" # commands like echo
        set fish_color_keyword        "${blue}" --bold # keywords like if - this falls back on the command color if unset
        set fish_color_quote          "${flamingo}"  # quoted text like "abc"
        set fish_color_redirection    "${teal}" --bold # IO redirections like >/dev/null
        set fish_color_end            "${green}"  # process separators like ';' and '&'
        set fish_color_error          "${red}"  # syntax errors
        set fish_color_param          "${teal}" # ordinary command parameters
        set fish_color_comment        "${darkgray2}"  # comments like '# important'
        set fish_color_selection      "${lightgray1}"  # selected text in vi visual mode
        set fish_color_operator       "${pink}"  # parameter expansion operators like '*' and '~'
        set fish_color_escape         "${pink}" # character escapes like 'n' and 'x70'
        set fish_color_autosuggestion "${lightgray2}"  # autosuggestions (the proposed rest of a command)
        set fish_color_cancel         "${red}"  # the '^C' indicator on a canceled command
        set fish_color_search_match   --background="${yellow}"  # history search matches and selected pager items (background only)
      '';

      programs.git.delta.options = with cfg.palette; {
        line-numbers-zero-style = white;
        line-numbers-minus-style = red;
        line-numbers-plus-style = green;
      };

      programs.discord.options.BACKGROUND_COLOR = cfg.palette.black;

      programs.rofi.font =
        "${cfg.font.family} ${builtins.toString cfg.font.size}";
      programs.rofi.theme = builtins.toFile "theme.rasi" (with cfg.palette;
        ''
          * {
            background: ${black};
            foreground: ${white};
            border-color: ${lightgray2};
            primary: ${blue};
            accent: ${teal};
            urgent: ${red};
            urgent-alt: ${red};
          }
        '' + builtins.readFile ../../leix/rofi_theme.rasi);

      xresources.extraConfig = with base16; ''
        ! ${cfg.name}

        *.font_family: ${cfg.font.family}
        *.font_size: ${builtins.toString cfg.font.size}

        *.background: ${cfg.palette.black}
        *.foreground: ${cfg.palette.white}

        !black
        *color0: ${color0}
        *color8: ${color8}

        !red
        *color1: ${color1}
        *color9: ${color9}

        !green
        *color2: ${color2}
        *color10: ${color10}

        !yellow
        *color3: ${color3}
        *color11: ${color11}

        !blue
        *color4: ${color4}
        *color12: ${color12}

        !magenta
        *color5: ${color5}
        *color13: ${color13}

        !cyan
        *color6: ${color6}
        *color14: ${color14}

        !white
        *color7: ${color7}
        *color15: ${color15}
      '';

    }

    (mkIf cfg.enableKittyTheme {
      programs.kitty.settings = with cfg.palette;
        {
          font_family = cfg.font.family;
          font_size = builtins.toString cfg.font.size;

          foreground = white;
          background = black;
          selection_foreground = black;
          selection_background = flamingo;
          # Cursor colors";
          cursor = flamingo;
          cursor_text_color = black;
          # URL underline color when hovering with mouse";
          url_color = flamingo;
          # Kitty window border colors";
          active_border_color = blue;
          inactive_border_color = gray;
          bell_border_color = yellow;

          # Tab bar colors";
          active_tab_foreground = darkblack;
          active_tab_background = mauve;
          inactive_tab_foreground = white;
          inactive_tab_background = darkblack;
          tab_bar_background = darkblack;
          # Colors for marks (marked text in the terminal)";
          mark1_foreground = black;
          mark1_background = blue;
          mark2_foreground = black;
          mark2_background = mauve;
          mark3_foreground = black;
          mark3_background = teal;

          wayland_titlebar_color = black;
        } // base16;
    })

    (mkIf config.programs.fzf.enable {
      home.sessionVariables.FZF_DEFAULT_OPTS = with cfg.palette;
        builtins.concatStringsSep " " [
          "--color=bg+:${gray},bg:${black},spinner:${flamingo},hl:${red}"
          "--color=fg:${white},header:${red},info:${pink},pointer:${yellow}"
          "--color=marker:${yellow},fg+:${flamingo},prompt:${pink},hl+:${red}"
        ];
    })

    (mkIf cfg.enableBatTheme {
      programs.bat = {
        config.theme = "catppuccin";
        themes = {
          catppuccin = builtins.readFile (pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "sublime-text"; # Bat uses sublime syntax for its themes
            rev = "95c5f44d8f75dc7e5cb7d20180e991aac3841440";
            sha256 = "sha256-RQCo35Gi8M0Xonkvd6EBPNeid1OLStIXIIHq4x5nM/U=";
          } + "/Catppuccin.tmTheme");
        };
      };
    })

  ]);
}
