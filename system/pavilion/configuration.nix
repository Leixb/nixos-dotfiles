# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:

{
  imports =
    [
      ../common.nix
      ./hardware-configuration.nix
    ];

  boot.extraModprobeConfig = "options rtl8723be fwlps=N ips=N swlps=N swenc=Y disable_watchdog=1 ant_sel=1";

  services.journald.extraConfig = ''
    Storage=volatile
  '';

  hardware.sensor.iio.enable = true;

  networking.hostName = "nixos-pav"; # Define your hostname.
  networking.interfaces.wlo1.useDHCP = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.displayManager.gdm.settings = {
    "greeting" = { "include" = "leix"; };
  };
  services.xserver.desktopManager.gnome.enable = true;

  # gnome app indicator
  services.udev.packages = with pkgs; [ gnome3.gnome-settings-daemon ];

  environment.gnome.excludePackages = with pkgs; [
    gnome.cheese
    gnome-photos
    gnome-connections
    gnome.gnome-software
    gnome.yelp
    gnome.gnome-music
    gnome.gnome-terminal
    gnome.gedit
    epiphany
    gnome.totem
    gnome.tali
    gnome.iagno
    gnome.hitori
    gnome.atomix
    gnome-tour
  ];
  programs.geary.enable = false;

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

}
