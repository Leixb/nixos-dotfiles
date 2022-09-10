# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, lib, inputs, ... }: {
  imports = [
    ../common.nix
    ./hardware-configuration.nix
    # ./gnome.nix
  ];

  # Configuration for low ram and zswap
  boot.kernel.sysctl = {
    "vm.swappiness" = 100;
    "vm.vfs_cache_pressure" = 500;
    "vm.dirty_background_ratio" = 1;
    "vm.dirty_ratio" = 50;
  };
  zramSwap.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.extraModprobeConfig = ''
    options rtl8723be fwlps=0 ips=0 swlps=0 swenc=1 disable_watchdog=1 ant_sel=1
  '';

  services.journald.extraConfig = ''
    Storage=volatile
  '';

  hardware.sensor.iio.enable = true;

  networking.hostName = "nixos-pav"; # Define your hostname.

  environment.sessionVariables = { MOZ_ENABLE_WAYLAND = "1"; };

  programs.light.enable = true;
}
