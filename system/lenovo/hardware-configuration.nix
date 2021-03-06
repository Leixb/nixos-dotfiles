# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }: {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "i915" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/22f535b7-47ae-4615-8d52-5555523fd878";
    fsType = "btrfs";
    options = [ "subvol=@" "noatime" "compress-force=zstd:3" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/22f535b7-47ae-4615-8d52-5555523fd878";
    fsType = "btrfs";
    options = [ "subvol=nix" "noatime" "compress-force=zstd:3" ];
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-uuid/22f535b7-47ae-4615-8d52-5555523fd878";
    fsType = "btrfs";
    options = [ "subvol=log" "noatime" "compress-force=zstd:3" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/22f535b7-47ae-4615-8d52-5555523fd878";
    fsType = "btrfs";
    options = [ "subvol=home" "noatime" "compress-force=zstd:3" ];
  };

  fileSystems."/mnt/home-old" = {
    device = "/dev/disk/by-uuid/29a8e3e8-d792-49e6-89b5-5bd78c8ab2e9";
    fsType = "btrfs";
    options = [
      "subvol=@home"
      "noatime"
      "compress-force=zstd:5"
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=600"
    ];
  };

  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/29a8e3e8-d792-49e6-89b5-5bd78c8ab2e9";
    fsType = "btrfs";
    options = [
      "subvol=@data"
      "noatime"
      "compress-force=zstd:5"
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=600"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/B944-74D8";
    fsType = "vfat";
  };

  # swapDevices = [{
  #   device = "/swap/swapfile";
  #   size = (1024 * 16) + (1024 * 2); # RAM size + 2 GB
  # }];

  swapDevices = [ ];

  powerManagement.cpuFreqGovernor = "performance";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
