{ config, pkgs, lib, inputs, ... }:

let

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
  networking.interfaces.enp7s0.useDHCP = true;
  networking.interfaces.wlp0s20f3.useDHCP = true;

  programs.droidcam.enable = true;

  environment.systemPackages = with pkgs; [
    battery_conservation_mode
  ];

  services.xserver = {
    xrandrHeads = [ "DP-2" { output = "HDMI-0"; primary = true; } ];
    screenSection = ''
      Option         "metamodes" "HDMI-0: nvidia-auto-select +1920+0, DP-2: nvidia-auto-select +0+0"
    '';
  };

}
