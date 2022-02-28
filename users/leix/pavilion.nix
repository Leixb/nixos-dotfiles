{ config, lib, pkgs, inputs, ... }:

let
  eww-unstable = pkgs.eww-wayland.overrideAttrs (oldAttrs: rec {

    version = "unstable-2022-02-15";

    # cargoSha256 = "0000000000000000000000000000000000000000000000000000";
    
    src = pkgs.fetchFromGitHub {
      owner = "elkowar";
      repo = "eww";
      rev = "fb0e57a0149904e76fb33807a2804d4af82350de";
      sha256 = "sha256-oAbB9aW/nqg02peqGEfETOGgeXarI6ZcAZ6DzDXbOSE=";
    };

    cargoDeps = oldAttrs.cargoDeps.overrideAttrs (lib.const {
      name = "eww-${version}-vendor.tar.gz";
      inherit src;
      outputHash = "sha256-x/NKvuuk9KrUIan1sNsdoiu7mBuCjDPYEeD1clxqTxQ=";
    });

  });

in

{

  imports = [
    ./gnome.nix
    ./common.nix
  ];

  home.packages = with pkgs; [
    swaylock
    swayidle
    swaybg
    wl-clipboard
    mako # notification daemon
    wofi # Dmenu is the default in the config but i recommend wofi since its wayland native
    eww-unstable
    sway-contrib.grimshot
    imv
  ];

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    xwayland = true;
    config = {
      modifier = "Mod4";
      terminal = "kitty --single-instance";
      menu = "wofi --show drun";
      startup = [
        { command = "systemctl --user restart waybar"; always = true; }
      ];
      input = {
        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
        };
      };
      window = {
        titlebar = false;
      };
      bars = [ ];
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
