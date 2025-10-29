# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./vpn.nix
      # ./../../modules/hydra.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;


  services.grafana.settings.log.level = "warn";

  networking.hostName = "dell"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;
  # networking.networkmanager.wifi.backend = "iwd";

  # Set your time zone.
  time.timeZone = "Europe/Madrid";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = lib.mkForce true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    config = {
      common.default = [ "gtk" ];
    };
  };
  services.gnome.at-spi2-core.enable = true; # Fix warning on xdg-portal start

  services.thermald.enable = true;
  powerManagement.enable = true;

  hardware.sensor.iio.enable = true;

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

  services.displayManager.autoLogin = {
    enable = true;
    user = "leix";
  };

  programs.nix-ld.enable = true;

  nix.settings.system-features = [ "sys-devices" ];
  programs.nix-required-mounts.enable = true;
  programs.nix-required-mounts.allowedPatterns.sys-devices.paths = [
    "/sys/devices/system/cpu"
    "/sys/devices/system/node"
  ];

  nix.settings.sandbox = "relaxed";

  nix.registry.jungle.to = {
    type = "git";
    url = "https://jungle.bsc.es/git/rarias/jungle";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
