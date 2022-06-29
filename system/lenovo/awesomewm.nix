{pkgs, ...}:

let
  theme = import ../../users/leix/theme.nix;
in {
  services.xserver = {
    enable = true;
    exportConfiguration = true;

    displayManager = {
      autoLogin.enable = false;
      autoLogin.user = "leix";

      defaultSession = "xsession";
      session = [
        {
          manage = "desktop";
          name = "xsession";
          start = "exec $HOME/.xsession";
        }
      ];

      sessionCommands = let
        xmodmap_config = pkgs.writeText "xkb-layout" ''
          clear lock
          keycode 66 = F13 F13 F13 F13
        '';
      in "${pkgs.xorg.xmodmap}/bin/xmodmap ${xmodmap_config}";

      lightdm.enable = true;
      lightdm.greeters.mini = {
        enable = true;
        user = "leix";
        extraConfig = with theme; ''
          [greeter]
          show-password-label = false
          password-alignment = center
          [greeter-theme]
          background-image = "${palette.wallpaper}"
          font = "${font_family}"
          text-color = "${foreground}"
          error-color = "${palette.red}"
          background-color = "${background}"
          window-color = "${color0}"
          border-color = "${color0}"
          password-color = "${color4}"
          password-background-color = "${palette.black}"
          password-border-color = "${palette.black}"
          sys-info-color = "${color4}"
        '';
      };
    };

    # Configure keymap in X11
    layout = "us";
    xkbVariant = "altgr-intl";
    xkbOptions = "lv3:caps_switch,shift:both_capslock,ralt:compose";

    # Enable touchpad support (enabled default in most desktopManager).
    libinput = {
      enable = true;
      mouse.accelProfile = "flat";
      touchpad = {
        naturalScrolling = true;
      };
    };
  };
}
