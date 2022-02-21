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
    ./hardware-configuration.nix
  ];

  
  boot.kernel.sysctl = {
    "abi.vsyscall32" = 0; # lol anti-cheat
  };

  boot.kernelParams = [
    "intel_iommu=on"
    "iommu=pt"
  ];

  boot.kernelPackages = pkgs.linuxPackages_xanmod;

  boot.blacklistedKernelModules = [ "i2c_nvidia_gpu" ];

  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
  hardware.nvidia.modesetting.enable = true;

  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  networking.hostName = "nixos";
  networking.interfaces.enp7s0.useDHCP = true;
  networking.interfaces.wlp0s20f3.useDHCP = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    exportConfiguration = true;

    xrandrHeads = [ "DP-2" { output = "HDMI-0"; primary = true; } ];
    screenSection = ''
      Option         "metamodes" "HDMI-0: nvidia-auto-select +1920+0, DP-2: nvidia-auto-select +0+0"
    '';

    displayManager.lightdm.enable = true;
    displayManager.autoLogin.enable = false;
    displayManager.autoLogin.user = "leix";

    displayManager.defaultSession = "xsession";
    displayManager.session = [{
      manage = "desktop";
      name = "xsession";
      start = "exec $HOME/.xsession";
    }];

    displayManager.lightdm.greeters.mini = {
        enable = true;
        user = "leix";
        extraConfig = ''
            [greeter]
            show-password-label = false
            password-alignment = center
            [greeter-theme]
            background-image = "${../../users/leix/wallpapers/forest.jpg}"
            font = "Fira Mono"
            text-color = "#DDDDFF"
            error-color = "#EA6F81"
            background-color = "#1A1A1A"
            window-color = "#313131"
            border-color = "#313131"
            password-color = "#82aaff"
            password-background-color = "#1d3b53"
            password-border-color = "#1d3b53"
            sys-info-color = "#82aaff"
        '';
    };

    # Configure keymap in X11
    layout = "us";
    xkbVariant = "altgr-intl";
    xkbOptions = "lv3:caps_switch,shift:both_capslock,ralt:compose";

    # Enable touchpad support (enabled default in most desktopManager).
    libinput = {
      enable = true;
      mouse.accelProfile = "flat";
    };

    videoDrivers = [ "intel" "nvidia" ];
  };

  programs.steam.enable = true;

  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
      };

      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
      };
    };
  };

  programs.droidcam.enable = true;

  environment.systemPackages = with pkgs; [
    virt-manager
    battery_conservation_mode
  ];

}
