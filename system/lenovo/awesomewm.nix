{
  services.xserver = {
    enable = true;
    exportConfiguration = true;

    displayManager.lightdm.enable = true;
    displayManager.autoLogin.enable = false;
    displayManager.autoLogin.user = "leix";

    displayManager.defaultSession = "xsession";
    displayManager.session = [{
      manage = "desktop";
      name = "xsession";
      start = "exec $HOME/.xsession";
    }];

    displayManager.lightdm.greeters.mini = {
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

    # Configure keymap in X11
    layout = "us";
    xkbVariant = "altgr-intl";
    xkbOptions = "lv3:caps_switch,shift:both_capslock,ralt:compose";

    # Enable touchpad support (enabled default in most desktopManager).
    libinput = {
      enable = true;
      mouse.accelProfile = "flat";
    };

    videoDrivers = [ "intel" ];
  };
}
