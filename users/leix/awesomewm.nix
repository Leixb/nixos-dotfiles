{ config, osConfig, lib, pkgs, system, inputs, ... }:

let
  username = osConfig.users.users.leix.name;
in
{
  xdg.configFile = {
    "awesome" = {
      source = pkgs.awesome-config;
      onChange = "awesome-client 'awesome.restart()'";
    };
  };

  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  sops.secrets.hass_env.sopsFile = ../../system/secrets/hass.yaml;
  sops.secrets.hass_env.path = "${config.xdg.stateHome}/.hass_env";

  home.packages = with pkgs; [
    (i3lock-fancy-rapid.override {
      i3lock = pkgs.writeShellScriptBin "i3lock" ''
        . ${config.sops.secrets.hass_env.path}

        ${pkgs.curl}/bin/curl -X POST \
            -H "Authorization: Bearer $HASS_TOKEN" \
            -H "Content-Type: application/json" \
            -d '{"hostname" : "${osConfig.networking.hostName}"}' \
            $HASS_SERVER/api/events/nixos.lock &

        ${pkgs.i3lock-color}/bin/i3lock-color --nofork "$@"

        wait

        ${pkgs.curl}/bin/curl -X POST \
            -H "Authorization: Bearer $HASS_TOKEN" \
            -H "Content-Type: application/json" \
            -d '{"hostname" : "${osConfig.networking.hostName}"}' \
            $HASS_SERVER/api/events/nixos.unlock
      '';
    })
    xsel
  ];

  services = {
    picom = {
      enable = true;
      backend = "glx";
      vSync = true;
      settings = {
        unredir-if-possible = true;
        use-damage = true;
        detect-transient = true;
        detect-client-leader = true;
        xrender-sync-fence = true;
        glx-no-rebind-pixmap = true;

        blur.method = "dual_kawase";
        blur-background = true;
        blur-background-frame = false;
        blur-background-exclude = [
          "window_type = 'dock'"
          "window_type = 'desktop'"
          "_GTK_FRAME_EXTENTS@:c"
        ];

        wintypes = {
          tooltip = {
            fade = true;
            shadow = true;
            opacity = 0.75;
            focus = true;
            full-shadow = false;
          };
          dock = {
            shadow = false;
            clip-shadow-above = true;
          };
          dnd = { shadow = false; };
          popup_menu = { opacity = 0.8; };
          dropdown_menu = { opacity = 0.8; };
        };

      };
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

  # home.pointerCursor.x11.enable = true;

  xsession = {
    enable = true;

    numlock.enable = true;

    windowManager.awesome = {
      enable = true;
      luaModules = with pkgs; [ lain ];
      package = pkgs.awesome;
    };
  };

}
