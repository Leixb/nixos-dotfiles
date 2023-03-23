# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, lib, inputs, ... }: {
  imports = [
    ../common.nix
    ./hardware-configuration.nix
    # ../lenovo/awesomewm.nix
    ./gnome.nix
  ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 10; # slow disk io
  };
  zramSwap.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  hardware.sensor.iio.enable = true;

  networking.hostName = "nixos-pav"; # Define your hostname.

  environment.sessionVariables = { MOZ_ENABLE_WAYLAND = "1"; };
}
