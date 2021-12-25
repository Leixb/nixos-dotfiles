# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/053c6498-4d72-40b1-bc18-4b8bb9a7fe1d";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/053c6498-4d72-40b1-bc18-4b8bb9a7fe1d";
      fsType = "btrfs";
      options = [ "subvol=@nix" "noatime"];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/29a8e3e8-d792-49e6-89b5-5bd78c8ab2e9";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

  fileSystems."/var/lib/libvirt/images" =
    { device = "/dev/disk/by-uuid/29a8e3e8-d792-49e6-89b5-5bd78c8ab2e9";
      fsType = "btrfs";
      options = [ "subvol=@libvirt-images" ];
    };

  fileSystems."/data" =
    { device = "/dev/disk/by-uuid/29a8e3e8-d792-49e6-89b5-5bd78c8ab2e9";
      fsType = "btrfs";
      options = [ "subvol=@data" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/F806-BDD1";
      fsType = "vfat";
    };

  fileSystems."/mnt/synology/video" =
    { device = "192.168.1.3:/volume1/video";
      fsType = "nfs";
      options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" ];
    };

  fileSystems."/mnt/synology/books" =
    { device = "192.168.1.3:/volume1/books";
      fsType = "nfs";
      options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" ];
    };

  fileSystems."/mnt/synology/music" =
    { device = "192.168.1.3:/volume1/music";
      fsType = "nfs";
      options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" ];
    };

  fileSystems."/mnt/synology/photo" =
    { device = "192.168.1.3:/volume1/photo";
      fsType = "nfs";
      options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" ];
    };

  fileSystems."/mnt/synology/downloads" =
    { device = "192.168.1.3:/volume1/Downloads";
      fsType = "nfs";
      options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" ];
    };

  fileSystems."/mnt/synology/shared" =
    { device = "192.168.1.3:/volume1/Shared folder";
      fsType = "nfs";
      options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" ];
    };

  fileSystems."/mnt/synology/docker" =
    { device = "192.168.1.3:/volume1/docker";
      fsType = "nfs";
      options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" ];
    };

  swapDevices = [ ];

  powerManagement.cpuFreqGovernor = "performance";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
