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
        default = ../wallpapers/keyboards.png;
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
      enableAlacrittyTheme = mkEnableOption "enableAlacrittyTheme";
      enableFootTheme = mkEnableOption "enableFootTheme";
      enableBatTheme = mkEnableOption "enableBatTheme";
      enableZathuraTheme = mkEnableOption "enableZathuraTheme";
      enableLuakitTheme = mkEnableOption "enableLuakitTheme";
      enableDunstTheme = mkEnableOption "enableDunstTheme";
    };
  };

  config =
    let
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

        # special
        background = black;
        foreground = white;
      };
      base16nohash = mapAttrs (name: color: builtins.replaceStrings [ "#" ] [ "" ] color) base16;
    in
    mkIf cfg.enable (mkMerge [
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
          '' + builtins.readFile ../../../home-manager/modules/rofi_theme.rasi);

        xresources.extraConfig = with base16; ''
          ! ${cfg.name}

          *.font_family: ${cfg.font.family}
          *.font_size: ${builtins.toString cfg.font.size}

          *.background: ${cfg.palette.background}
          *.foreground: ${cfg.palette.text}

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

      (mkIf cfg.enableAlacrittyTheme {
        programs.alacritty.settings = with cfg.palette;
          {
            font.normal.family = cfg.font.family;
            font.size = cfg.font.size;

            colors = {
              primary = {
                foreground = white;
                background = black;
                dim_foreground = white;
                bright_foreground = black;
              };
              cursor = {
                text = black;
                cursor = flamingo;
              };

              normal = { inherit red green yellow blue magenta cyan white; black = gray; };
              bright = { inherit red green yellow blue magenta cyan white; black = gray; };
            };
          };
      })
      (mkIf cfg.enableFootTheme {
        programs.foot.settings = {
          main.font = "${cfg.font.family}:size=${builtins.toString cfg.font.size}";
          colors = with base16nohash; {
            background = background;
            foreground = foreground;

            # Normal/regular colors (color palette 0-7)
            regular0 = color0;
            regular1 = color1;
            regular2 = color2;
            regular3 = color3;
            regular4 = color4;
            regular5 = color5;
            regular6 = color6;
            regular7 = color7;

            # Bright colors (color palette 8-15)
            bright0 = color8;
            bright1 = color9;
            bright2 = color10;
            bright3 = color11;
            bright4 = color12;
            bright5 = color13;
            bright6 = color14;
            bright7 = color15;
          };
        };
      })

      (mkIf cfg.enableKittyTheme {
        programs.kitty.settings = with cfg.palette;
          {
            font_family = cfg.font.family;
            font_size = builtins.toString cfg.font.size;

            selection_foreground = black;
            selection_background = flamingo;
            # Cursor colors";
            cursor = "none";
            # cursor_text_color = black;
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
            catppuccin = {
              src = pkgs.fetchFromGitHub {
                owner = "catppuccin";
                repo = "sublime-text"; # Bat uses sublime syntax for its themes
                rev = "5529a1c0dea6d137b64314dba44db0bf268fe12b";
                sha256 = "sha256-5p0yagS3d32e7RxD+u3DbPs9HiY2eEMqPomi9hNPxj4=";
              };
              file = "Macchiato.tmTheme";
            };
          };
        };
      })

      (mkIf cfg.enableZathuraTheme {
        programs.zathura.options = with cfg.palette; {

          default-fg = white;
          default-bg = black;

          completion-bg = darkgray1;
          completion-fg = white;
          completion-highlight-bg = darkgray2;
          completion-highlight-fg = white;
          completion-group-bg = darkgray1;
          completion-group-fg = blue;

          statusbar-fg = white;
          statusbar-bg = black;

          notification-bg = black;
          notification-fg = white;
          notification-error-bg = black;
          notification-error-fg = red;
          notification-warning-bg = black;
          notification-warning-fg = yellow;

          inputbar-fg = white;
          inputbar-bg = black;

          recolor-lightcolor = black;
          recolor-darkcolor = white;

          index-fg = white;
          index-bg = black;
          index-active-fg = white;
          index-active-bg = darkgray1;

          render-loading-bg = black;
          render-loading-fg = white;

          highlight-color = darkgray2;
          highlight-fg = pink;
          highlight-active-color = flamingo;

        };
      })

      (mkIf cfg.enableLuakitTheme {
        xdg.configFile."luakit/theme.lua".text = with cfg.palette; ''
          local theme = {}

          -- Default settings
          theme.font = "${builtins.toString cfg.font.size}px ${cfg.font.family}"
          theme.fg   = "${white}"
          theme.bg   = "${black}"

          -- General colours
          theme.success_fg = "${green}"
          theme.loaded_fg  = "${blue}"
          theme.error_fg = "${black}"
          theme.error_bg = "${red}"

          -- Warning colours
          theme.warning_fg = "${yellow}"
          theme.warning_bg = "${white}"

          -- Notification colours
          theme.notif_fg = "${darkgray1}"
          theme.notif_bg = "${white}"

          -- Menu colours
          theme.menu_fg                   = "${black}"
          theme.menu_bg                   = "${white}"
          theme.menu_selected_fg          = "${black}"
          theme.menu_selected_bg          = "${yellow}"
          theme.menu_title_bg             = "${white}"
          theme.menu_primary_title_fg     = "${red}"
          theme.menu_secondary_title_fg   = "${gray}"

          theme.menu_disabled_fg = "${lightgray2}"
          theme.menu_disabled_bg = theme.menu_bg
          theme.menu_enabled_fg = theme.menu_fg
          theme.menu_enabled_bg = theme.menu_bg
          theme.menu_active_fg = "${green}"
          theme.menu_active_bg = theme.menu_bg

          -- Proxy manager
          theme.proxy_active_menu_fg      = '${black}'
          theme.proxy_active_menu_bg      = '${white}'
          theme.proxy_inactive_menu_fg    = '${gray}'
          theme.proxy_inactive_menu_bg    = '${white}'

          -- Statusbar specific
          theme.sbar_fg         = "${white}"
          theme.sbar_bg         = "${black}"

          -- Downloadbar specific
          theme.dbar_fg         = "${white}"
          theme.dbar_bg         = "${black}"
          theme.dbar_error_fg   = "${red}"

          -- Input bar specific
          theme.ibar_fg           = "${black}"
          theme.ibar_bg           = "rgba(0,0,0,0)"

          -- Tab label
          theme.tab_fg            = "${gray}"
          theme.tab_bg            = "${darkblack}"
          theme.tab_hover_bg      = "${black}"
          theme.tab_ntheme        = "${gray}"
          theme.selected_fg       = "${white}"
          theme.selected_bg       = "${black}"
          theme.selected_ntheme   = "${gray}"
          theme.loading_fg        = "${blue}"
          theme.loading_bg        = "${black}"

          theme.selected_private_tab_bg = "${mauve}"
          theme.private_tab_bg    = "${pink}"

          -- Trusted/untrusted ssl colours
          theme.trust_fg          = "${green}"
          theme.notrust_fg        = "${red}"

          -- Follow mode hints
          -- theme.hint_font = "13px monospace, courier, sans-serif"
          theme.hint_font = "bold ${builtins.toString cfg.font.size}px monospace, courier, sans-serif"
          theme.hint_fg = "${white}"
          theme.hint_bg = "${darkblack}"
          theme.hint_border = "1px dashed ${black}"
          theme.hint_opacity = "0.3"
          theme.hint_overlay_bg = "rgba(255,255,153,0.3)"
          theme.hint_overlay_border = "1px dotted ${black}"
          theme.hint_overlay_selected_bg = "rgba(0,255,0,0.3)"
          theme.hint_overlay_selected_border = theme.hint_overlay_border

          -- General colour pairings
          theme.ok = { fg = "${black}", bg = "${white}" }
          theme.warn = { fg = "${yellow}", bg = "${white}" }
          theme.error = { fg = "${black}", bg = "${red}" }

          -- Gopher page style (override defaults)
          theme.gopher_light = { bg = "${white}", fg = "${black}", link = "${blue}" }
          theme.gopher_dark  = { bg = "${black}", fg = "${white}", link = "${peach}" }

          return theme
        '';
      })

      (mkIf cfg.enableDunstTheme {
        services.dunst.settings = with cfg.palette; let foreground = text; in {
          global = {
            frame_color = blue;
            separator_color = "frame";
            font = "${cfg.font.family} ${builtins.toString cfg.font.size}";
            transparency = 10;
            offset = "5x25";
          };
          urgency_low = {
            inherit background foreground;
            frame_color = foreground;
          };
          urgency_normal = {
            inherit background foreground;
          };
          urgency_critical = {
            inherit background foreground;
            frame_color = red;
          };
        };
      })

    ]);
}
