{ pkgs, ... }:
{
  services.acpid.enable = true;

  services.thermald.enable = true;
  powerManagement.enable = true;

  hardware.sensor.iio.enable = true;

  environment.systemPackages = [ pkgs.brightnessctl ];
}
