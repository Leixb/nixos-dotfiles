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
in {
  _module.args.location = location;
  imports = [
    ../common.nix
    ./minecraft.nix
    ./synology-mounts.nix
    ./nvidia.nix
    ./virtualization.nix
    ./gaming.nix
    ./awesomewm.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "kuro";

  boot.kernel.sysctl = { "dev.i915.perf_stream_paranoid" = 0; };

  boot.kernelParams = [ "acpi_backlight=intel" ];

  programs.droidcam.enable = true;
  programs.noisetorch.enable = true;

  environment.systemPackages = [ battery_conservation_mode ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  services.ddccontrol.enable = true;

  services.xserver.displayManager.setupCommands = ''
    ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource NVIDIA-G0 modesetting
    ${pkgs.xorg.xrandr}/bin/xrandr --output HDMI-1-0 --primary --auto --right-of eDP-1
  '';

  nix.sshServe.enable = true;
  nix.sshServe.keys = [ 
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKOO1MTb4NP9qgI8P/8feqFXReeLCiB79R6YLPlXQaRQ leix@nixos-pav"
  ];

  services.elasticsearch = {
    enable = true;
    package = pkgs.elasticsearch7;
  };
  systemd.services.elasticsearch.wantedBy = lib.mkForce [];
}
