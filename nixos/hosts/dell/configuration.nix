# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./vpn.nix
      ../../modules/laptop.nix
      ../../modules/sops.nix
      ../../modules/ssd.nix
      ../../modules/virtualization.nix
      ../../modules/xorg.nix
      ../../modules/intel.nix
      inputs.nixos-hardware.nixosModules.dell-latitude-7420
      # ./../../modules/hydra.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "dell"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;
  # networking.networkmanager.wifi.backend = "iwd";

  # Install firefox.
  programs.firefox.enable = true;

  networking.firewall.enable = lib.mkForce true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    config = {
      common.default = [ "gtk" ];
    };
  };
  services.gnome.at-spi2-core.enable = true; # Fix warning on xdg-portal start

  boot.kernel.sysctl."kernel.perf_event_paranoid" = 1;

  services.xserver.displayManager.setupCommands = ''
    ${pkgs.xorg.xrandr}/bin/xrandr --auto
    ${pkgs.xorg.xrandr}/bin/xrandr --output DP-2-1 --primary --left-of eDP-1
  '';

  services.nixseparatedebuginfod2 = {
    enable = true;
    substituters = [
      "local:"
      "https://cache.nixos.org"
      "https://jungle.bsc.es/cache"
    ];
  };

  services.fprintd = {
    enable = true;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-broadcom;
    };
  };

  # otherwise static plays when connected to analog output
  services.pulseaudio.extraConfig = "unload-module module-suspend-on-idle";

  programs.nix-ld.enable = true;

  nix.settings.system-features = [ "sys-devices" ];
  programs.nix-required-mounts.enable = true;
  programs.nix-required-mounts.allowedPatterns.sys-devices.paths = [
    "/sys/devices/system/cpu"
    "/sys/devices/system/node"
  ];

  nix.settings.sandbox = "relaxed";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
