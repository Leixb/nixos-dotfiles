{ config
, pkgs
, lib
, inputs
, ...
}: {
  programs.waybar = {
    # enable = true;
    # package = pkgs.waybar-hyprland;
    systemd = {
      enable = false;
      target = "hyprland-session.target";
    };
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        modules-left = [ "wlr/workspaces" ];
        modules-center = [ ];
        modules-right = [ "cpu" "memory" "pulseaudio" "network" "backlight" "battery" "clock" "tray" ];

        "wlr/workspaces" = {
          disable-scroll = true;
          sort-by-name = true;
          format = "{icon}";
          format-icons = { default = ""; };
        };

        pulseaudio = {
          format = " {icon} ";
          format-muted = "󰝟";
          format-icons = [ "󰕿" "󰖀" "󰕾" ];
          tooltip = true;
          tooltip-format = "{volume}%";
          on-click-right = "switch-audio";
          on-click = "amixer -q set Master toggle";
          on-click-middle = "pavucontrol";
          on-scroll-up = "amixer -q set Master 5%+";
          on-scroll-down = "amixer -q set Master 5%-";
        };

        network = {
          format-wifi = " ";
          format-disconnected = "󱚵";
          format-ethernet = "󰈀";
          tooltip = true;
          tooltip-format = "{signalStrength}%";
        };

        backlight = {
          device = "nvidia_0";
          format = "{icon}";
          format-icons = [ "" "" "" "" "" "" "" "" "" ];
          tooltip = true;
          tooltip-format = "{percent}%";
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon}";
          format-charging = "󰂄";
          format-plugged = "󰚥";
          format-icons = [ "󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          tooltip = true;
          tooltip-format = "{capacity}%";
        };

        clock = {
          tooltip-format = ''
            <big>{:%Y %B}</big>
            <tt><small>{calendar}</small></tt>'';
          format-alt = ''{:%d %m %Y}'';
          format = ''{:%H:%M}'';
        };

        tray = {
          icon-size = 21;
          spacing = 10;
        };
      };
    };

    style = builtins.readFile ./waybar-style.css;
  };

  xdg.configFile."waybar/theme.css".text = with (import ../modules/theme/palette.nix); ''
    @define-color base   ${base};
    @define-color mantle ${mantle};
    @define-color crust  ${crust};

    @define-color text     ${text};
    @define-color subtext0 ${lightgray1};
    @define-color subtext1 ${lightgray2};

    @define-color surface0 ${surface0};
    @define-color surface1 ${surface1};
    @define-color surface2 ${surface2};

    @define-color overlay0 ${gray};
    @define-color overlay1 #8087a2;
    @define-color overlay2 #939ab7;

    @define-color blue      ${blue};
    @define-color lavender  ${lavender};
    @define-color sapphire  ${sapphire};
    @define-color sky       ${sky};
    @define-color teal      ${teal};
    @define-color green     ${green};
    @define-color yellow    ${yellow};
    @define-color peach     ${peach};
    @define-color maroon    ${maroon};
    @define-color red       ${red};
    @define-color mauve     ${mauve};
    @define-color pink      ${pink};
    @define-color flamingo  ${flamingo};
    @define-color rosewater ${rosewater};
  '';
}
