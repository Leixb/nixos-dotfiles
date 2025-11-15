# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, lib, inputs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/laptop.nix
    ../../modules/intel.nix
    ../../modules/xorg.nix
  ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 10; # slow disk io
  };
  zramSwap.enable = true;

  boot.loader.systemd-boot.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  hardware.sensor.iio.enable = true;

  services.preload.enable = true;

  services.xserver.displayManager = {
    lightdm.enable = true;
    autoLogin.user = "leix";
    defaultSession = "xsession";
  };

  networking.hostName = "pavilion"; # Define your hostname.

  environment.sessionVariables = { MOZ_ENABLE_WAYLAND = "1"; };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
