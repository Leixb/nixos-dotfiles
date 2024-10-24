{ lib, pkgs, ... }:

let palette = import ../../home-manager/modules/theme/palette.nix;
in {

  services.displayManager = {
    defaultSession = "xsession";
    autoLogin.enable = lib.mkDefault false;
  };

  services.xserver = {
    enable = true;
    exportConfiguration = true;

    extraConfig = ''
      Section "Extensions"
          Option "MIT-SHM" "Disable"
      EndSection
    '';

    displayManager = {
      session = [{
        manage = "desktop";
        name = "xsession";
        start = "exec $HOME/.xsession";
      }];

      sessionCommands = ''
        ${lib.getBin pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all
      '';

      lightdm.greeters.mini = {
        enable = true;
        user = "leix";
        extraConfig = with palette; ''
          [greeter]
          show-password-label = false
          password-alignment = center
          [greeter-theme]
          background-image = "${../../home-manager/modules/wallpapers/nix-wallpaper-nineish-macchiato.svg}"
          background-image-size = cover
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
    xkb.layout = "eu";
    # xkb.variant = "altgr-intl";
    # xkb.options = "lv3:caps_switch,shift:both_capslock";
    xkb.options = "shift:both_capslock,caps:escape,grp:win_space_toggle";

  };
  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput = {
    enable = true;
    mouse.accelProfile = "flat";
    mouse.accelSpeed = "0.7";
    touchpad = {
      naturalScrolling = true;
      disableWhileTyping = true;
    };
  };
}
