{
  services.acpid.enable = true;
  programs.light.enable = true;

  services.thermald.enable = true;
  powerManagement.enable = true;

  hardware.sensor.iio.enable = true;
}
