{ lib, pkgs, ... }: {
  home.packages = with pkgs; [
    wayland
    hyprpaper
    xdg-utils # for opening default programs when clicking links
    glib # gsettings
    dracula-theme # gtk theme
    gnome3.adwaita-icon-theme # default gnome cursors
    swaylock
    vulkan-validation-layers
    vulkan-loader
    vulkan-tools
    swayidle
    grim # screenshot functionality
    slurp # screenshot functionality
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    bemenu # wayland clone of dmenu
    mako # notification system developed by swaywm maintainer
    sway-contrib.grimshot
    wofi
    imv
  ];

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    xwayland = true;
    config = rec {
      modifier = "Mod4";
      terminal = "kitty --single-instance";
      menu = "wofi --show drun";
      startup = [{
        command = "systemctl --user restart waybar";
        always = true;
      }];
      input = {
        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
        };
      };
      window = { titlebar = false; };
      bars = [ ];
      keybindings = lib.mkOptionDefault { "${modifier}+w" = "kill"; };
    };
    extraConfig = ''
      output "*" background ${pkgs.nixos-artwork.wallpapers.simple-dark-gray}/share/backgrounds/nixos/nix-wallpaper-simple-dark-gray.png fill
    '';
  };

  programs.waybar = {
    systemd = {
      enable = true;
      target = "sway-session.target";
    };
    enable = true;
    settings = [{
      layer = "top";
      modules-left = [ "wlr/workspaces" "sway/mode" "wlr/taskbar" ];
      modules-center = [ "sway/window" ];
      modules-right = [
        "tray"
        "idle_inhibitor"
        "backlight"
        "pulseaudio"
        "bluetooth"
        "network"
        "memory"
        "cpu"
        "temperature"
        "disk"
        "sway/language"
        "battery"
        "clock"
      ];
    }];
  };
}
