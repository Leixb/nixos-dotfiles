{ pkgs, ... }:
{
  services.udev.packages = with pkgs; [
    logitech-udev-rules
    headsetcontrol
  ];
}
