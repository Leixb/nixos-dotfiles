{ pkgs, ... }:

let palette = import ../../users/modules/theme/palette.nix;
in {
  services.xserver = {
    enable = true;
    exportConfiguration = true;

    extraConfig = ''
      Section "Extensions"
          Option "MIT-SHM" "Disable"
      EndSection
    '';

    # videoDrivers = ["nvidia"];

    displayManager = {
      autoLogin.enable = false;
      autoLogin.user = "leix";

      defaultSession = "xsession";
      session = [{
        manage = "desktop";
        name = "xsession";
        start = "exec $HOME/.xsession";
      }];

      sessionCommands =
        let
          xmodmap_config = pkgs.writeText "xkb-layout" ''
            clear lock
            keycode 66 = F13 F13 F13 F13
          '';
        in
        "${pkgs.xorg.xmodmap}/bin/xmodmap ${xmodmap_config}";

      # gdm = {
      #   enable = true;
      #   wayland = true;
      # };

      lightdm.enable = true;
      lightdm.greeters.mini = {
        enable = true;
        user = "leix";
        extraConfig = with palette; ''
          [greeter]
          show-password-label = false
          password-alignment = center
          [greeter-theme]
          background-image = "${./../../users/leix/wallpapers/keyboards.png}"
          font = "DejaVu Sans Mono"
          text-color = "${white}"
          error-color = "${red}"
          background-color = "${black}"
          window-color = "${black}"
          border-color = "${black}"
          password-color = "${blue}"
          password-background-color = "${darkgray1}"
          password-border-color = "${black}"
          sys-info-color = "${blue}"
        '';
      };
    };

    # Configure keymap in X11
    layout = "eu";
    # xkbVariant = "altgr-intl";
    xkbOptions = "lv3:caps_switch,shift:both_capslock";

    # Enable touchpad support (enabled default in most desktopManager).
    libinput = {
      enable = true;
      mouse.accelProfile = "flat";
      mouse.accelSpeed = "0.7";
      touchpad = { naturalScrolling = true; };
    };
  };
}
