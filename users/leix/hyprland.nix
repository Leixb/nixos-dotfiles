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

  programs.eww = {
    enable = true;
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
