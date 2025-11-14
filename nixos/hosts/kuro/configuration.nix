{ config, pkgs, lib, inputs, ... }:
let
  location = "192.168.1.3";
  # Set battery saving (limit charge to 60%)
  battery_conservation_mode = pkgs.writeShellScriptBin "battery-conservation" ''
    #!/usr/bin/env bash

    method='\_SB.PCI0.LPCB.EC0.VPC0.SBMC'

    on() {
        sudo modprobe acpi_call
        echo $method 3 | sudo tee /proc/acpi/call
        sudo rmmod acpi_call
    }

    off() {
        sudo modprobe acpi_call
        echo $method 5 | sudo tee /proc/acpi/call
        sudo rmmod acpi_call
    }

    $1
  '';
in
{
  _module.args.location = location;
  imports = [
    ./hardware-configuration.nix
    ../../modules/intel.nix
  ];

  services.xserver.displayManager.lightdm.enable = true;

  services.displayManager = {
    autoLogin.user = "leix";
    defaultSession = "xsession";
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-wlr ];
    config = {
      common.default = [ "gtk" "wlr" ];
    };
  };
  services.gnome.at-spi2-core.enable = true; # Fix warning on xdg-portal start

  networking.hostName = "kuro";

  boot.kernel.sysctl = { "dev.i915.perf_stream_paranoid" = 0; };

  boot.kernelParams = [
    "acpi_backlight=intel"
    "clearcpuid=304" # disable AVX512 (The finals game crashes with AVX512)
  ];

  programs.droidcam.enable = true;
  programs.noisetorch.enable = true;

  environment.systemPackages = [ battery_conservation_mode ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  programs.adb.enable = true; # enable android proper data tethering

  services.ddccontrol.enable = true;

  hardware.xpadneo.enable = true;

  services.xserver.displayManager.setupCommands = ''
    ${pkgs.xorg.xrandr}/bin/xrandr --auto
    ${pkgs.xorg.xrandr}/bin/xrandr \
      --output eDP-1-1 --right-of DP-2
      --output HDMI-0 --left-of DP-2
  '';

  nix.sshServe.enable = true;
  nix.sshServe.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKOO1MTb4NP9qgI8P/8feqFXReeLCiB79R6YLPlXQaRQ leix@nixos-pav"
  ];

  users.users.marc = {
    description = "Marc";
    uid = 1002;
    isNormalUser = true;
    hashedPassword = "$6$IGa4YC1e3tr7pDYb$dKN44XyP0CGNZRNNH8g414r2qZatuulHqP4ZcYbr2N040JHuFKg7uNypG7Njl0Cr.JK5bWlOTfoKx8Nn3y3v11";
    extraGroups = [
      "networkmanager"
      "audio"
      "video"
      "input"
    ];
  };

  services.xserver.dpi = 192;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
