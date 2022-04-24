{pkgs, ...}: {
  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>Return";
      command = "${pkgs.kitty}/bin/kitty";
      name = "kitty";
    };
    "org/gnome/shell" = {
      favorite-apps = ["firefox.desktop" "kitty.desktop" "org.gnome.Nautilus.desktop"];
    };
    "org/gnome/GWeather" = {
      temperature-unit = "centigrade";
    };
    "org/gnome/shell/weather" = {
      automatic-location = true;
    };
  };
}
