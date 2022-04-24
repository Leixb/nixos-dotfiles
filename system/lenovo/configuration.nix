{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
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
in {
  imports = [
    ../common.nix
    ./nvidia.nix
    ./virtualization.nix
    ./gaming.nix
    ./awesomewm.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "nixos";
  networking.interfaces = {
    enp7s0.useDHCP = true;
    wlan0.useDHCP = true;
  };

  boot.kernel.sysctl = {
    "dev.i915.perf_stream_paranoid" = 0;
  };

  programs.droidcam.enable = true;

  environment.systemPackages = [battery_conservation_mode];
  boot.extraModulePackages = with config.boot.kernelPackages; [acpi_call];

  services.xserver.displayManager.setupCommands = ''
    ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource NVIDIA-G0 modesetting
    ${pkgs.xorg.xrandr}/bin/xrandr --output HDMI-1-0 --primary --auto --right-of eDP-1
  '';
}
