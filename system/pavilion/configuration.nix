# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:

{
  imports =
    [
      ../common.nix
      ./hardware-configuration.nix
      # ./gnome.nix
    ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.extraModprobeConfig = ''
    options rtl8723be fwlps=0 ips=0 swlps=0 swenc=1 disable_watchdog=1 ant_sel=1
  '';

  services.journald.extraConfig = ''
    Storage=volatile
  '';

  hardware.sensor.iio.enable = true;

  networking.hostName = "nixos-pav"; # Define your hostname.
  networking.interfaces.wlo1.useDHCP = true;

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.light.enable = true;

}
