{ pkgs, ... }:

{
  services.grobi = {
    enable = true;
    rules = [
      {
        name = "Home";
        outputs_connected = [ "DP-2" "eDP-1-1" ];
        primary = "DP-2";
        atomic = true;
        configure_row = [ "DP-2" "eDP-1-1" ];
        execute_after = [
          "${pkgs.xrandr}/bin/xrandr --dpi 192 --output DP-2 --scale 1.25x1.25"
          "${pkgs.xmonad-with-packages}/bin/xmonad --restart"
        ];
      }
      {
        name = "Mobile";
        outputs_disconnected = [ "DP-2" ];
        configure_single = "eDP-1-1";
        primary = true;
        atomic = true;
        execute_after = [
          "${pkgs.xrandr}/bin/xrandr --dpi 120"
          "${pkgs.xmonad-with-packages}/bin/xmonad --restart"
        ];
      }
    ];
  };
}
