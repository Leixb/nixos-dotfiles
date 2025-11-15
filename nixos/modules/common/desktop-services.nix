{ pkgs, ... }:
{
  services.gnome.gnome-keyring.enable = true;
  programs.dconf.enable = true;

  services.systembus-notify.enable = true;

  services.udev.packages = with pkgs; [
    gnome-settings-daemon
  ];
  services.dbus.packages = with pkgs; [
    gcr
    at-spi2-core
  ];

  # Mout MTP and other network shares
  services.gvfs.enable = true;

  xdg.portal.enable = true;

  # Put xserver log files in /var
  services.xserver.logFile = "/var/log/Xorg.0.log";
}
