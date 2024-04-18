{ config, osConfig, lib, pkgs, system, inputs, ... }:

let
  username = osConfig.users.users.leix.name;
in
{
  # xdg.configFile = {
  #   "awesome" = {
  #     source = pkgs.awesome-config;
  #     onChange = "${pkgs.awesome}/bin/awesome-client 'awesome.restart()'";
  #   };
  # };

  sops.secrets.hass_env.sopsFile = ../../nixos/secrets/hass.yaml;
  sops.secrets.hass_env.path = "${config.xdg.stateHome}/.hass_env";

  programs.xmobar = {
    enable = true;
    package = pkgs.symlinkJoin {
      name = "xmobar-wrapped";
      paths = [ pkgs.xmobar ];
      nativeBuildInputs = [ pkgs.makeBinaryWrapper ];
      postBuild = let ghcEnv = pkgs.haskellPackages.ghcWithPackages (p: with p; [ xmonad xmonad-contrib xmobar ]); in ''
        wrapProgram $out/bin/xmobar \
          --prefix PATH : ${ghcEnv}/bin
      '';
    };
  };

  services.dunst.enable = true;
  services.batsignal.enable = true;

  services.trayer = {
    enable = true;
    settings = {
      edge = "top";
      align = "right";
      widthtype = "request";
      expand = true;
      SetDockType = true;
      SetPartialStrut = true;
      monitor = "primary";
      height = lib.mkDefault 40;
      transparent = true;
      alpha = 0;
      tint = "0x25273A";
      padding = 1;
      distance = 1;
      distancefrom = "right";
    };
  };

  home.packages = with pkgs; [
    (i3lock-fancy-rapid.override {
      i3lock = pkgs.writeShellScriptBin "i3lock" ''
        . ${config.sops.secrets.hass_env.path}

        ${pkgs.curl}/bin/curl -X POST \
            -H "Authorization: Bearer $HASS_TOKEN" \
            -H "Content-Type: application/json" \
            -d '{"hostname" : "${osConfig.networking.hostName}"}' \
            $HASS_SERVER/api/events/nixos.lock &

        ${pkgs.dunst}/bin/dunstctl set-paused true

        ${pkgs.i3lock-color}/bin/i3lock-color --nofork "$@"

        wait

        ${pkgs.curl}/bin/curl -X POST \
            -H "Authorization: Bearer $HASS_TOKEN" \
            -H "Content-Type: application/json" \
            -d '{"hostname" : "${osConfig.networking.hostName}"}' \
            $HASS_SERVER/api/events/nixos.unlock &

        ${pkgs.dunst}/bin/dunstctl set-paused false
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
      kb-row-up = "Up,Control+k,Control+p";
      kb-row-down = "Down,Control+j,Control+n";
      kb-accept-entry = "Return,KP_Enter"; # Control + j
      kb-remove-to-eol = "Control+m"; # Control + k
    };
  };

  # home.pointerCursor.x11.enable = true;

  xsession = {
    enable = true;

    numlock.enable = true;

    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = haskellPackages: [
        haskellPackages.xmobar
      ];
      config = ./xmonad.hs;
    };
  };

  systemd.user.services.lxqt-policykit-agent = {
    Unit = {
      Description = "LxQt Polkit authentication agent";
      Documentation = "https://gitlab.freedesktop.org/polkit/polkit/";
      WantedBy = [ "graphical-session.target" ];
      After = [ "graphical-session-pre.target" ];
      Wants = [ "dbus.service" ];
    };

    Service = {
      ExecStart = "${pkgs.lxqt.lxqt-policykit.out}/bin/lxqt-policykit-agent";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };

}
