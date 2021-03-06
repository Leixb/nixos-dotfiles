{ lib, pkgs, ... }: {
  home.packages = with pkgs; [
    swaylock
    swayidle
    swaybg
    wl-clipboard
    mako # notification daemon
    wofi # Dmenu is the default in the config but i recommend wofi since its wayland native
    sway-contrib.grimshot
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
      modules-left = [ "sway/workspaces" "sway/mode" "wlr/taskbar" ];
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
