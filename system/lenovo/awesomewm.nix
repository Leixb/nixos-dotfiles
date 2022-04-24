{pkgs, ...}: {
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
        extraConfig = ''
          [greeter]
          show-password-label = false
          password-alignment = center
          [greeter-theme]
          background-image = "${../../users/leix/wallpapers/forest.jpg}"
          font = "Fira Mono"
          text-color = "#DDDDFF"
          error-color = "#EA6F81"
          background-color = "#1A1A1A"
          window-color = "#313131"
          border-color = "#313131"
          password-color = "#82aaff"
          password-background-color = "#1d3b53"
          password-border-color = "#1d3b53"
          sys-info-color = "#82aaff"
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
    };
  };
}
