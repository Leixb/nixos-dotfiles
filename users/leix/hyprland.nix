{ lib, pkgs, ... }:
let swaylock-blur = pkgs.writeScriptBin "swaylock-blur" ''
  ${pkgs.swaylock-effects}/bin/swaylock -S --effect-scale 0.6 --effect-blur 7x2 -F --clock
'';
in
{

  home.packages = with pkgs; [
    wayland
    hyprpaper
    xdg-utils # for opening default programs when clicking links
    glib # gsettings
    dracula-theme # gtk theme
    gnome3.adwaita-icon-theme # default gnome cursors
    swaylock-effects
    swaylock-blur
    swaybg
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

  systemd.user.targets.hyprland-session = {
    Unit = {
      Description = "Hyprland Session";
      Documentation = "man:hyprland(1)";
      PartOf = [ "graphical-session.target" ];
    };
  };

  systemd.user.services.swaybg = {
    Unit = {
      Description = "Wayland Background";
      Documentation = "man:swaybg(1)";
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.swaybg}/bin/swaybg -i /home/leix/Pictures/owl.png";
    };
    Install = {
      WantedBy = [ "hyprland-session.target" ];
    };
  };

  services.swayidle = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    timeouts = [
      { timeout = 300; command = "/run/current-system/sw/bin/hyprctl dispatcher dpms off"; }
      { timeout = 315; command = "${swaylock-blur}/bin/swaylock-blur"; }
    ];
  };

  programs.waybar = {
    enable = true;
    package = pkgs.waybar-hyprland;
    systemd = {
      enable = false;
      target = "hyprland-session.target";
    };

    settings = [{
      layer = "top";
      modules-left = [ "wlr/workspaces" "wlr/taskbar" ];
      modules-center = [ ];
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
        "battery"
        "clock"
      ];
    }];
  };

  programs.eww = {
    enable = false;
    configDir = ./eww;
    package = with pkgs; symlinkJoin {
      name = "eww-env";
      paths = [
        eww-wayland
        socat
        jq
      ];
    };
  };
}
