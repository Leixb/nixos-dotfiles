# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }: {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.loader.grub = {
    enable = true;
    zfsSupport = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    mirroredBoots = [
      { devices = [ "nodev" ]; path = "/boot"; }
    ];
  };

  networking.hostId = "dccd7371";

  # boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  # FIXME: update back to correct kernel once freezes are fixed on 6.7+
  boot.kernelPackages = pkgs.linuxPackages_6_6;

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "i915" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  services.zfs.autoScrub.enable = true;

  fileSystems."/" =
    {
      device = "zpool/root";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    {
      device = "zpool/nix";
      fsType = "zfs";
    };

  fileSystems."/var" =
    {
      device = "zpool/var";
      fsType = "zfs";
    };

  fileSystems."/home" =
    {
      device = "zpool/home";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-partuuid/8d5eff0a-a57b-4b36-bfdb-b507303be33e";
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
