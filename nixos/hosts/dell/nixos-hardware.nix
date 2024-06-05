{ lib, config, ... }:

{

  boot.kernelParams = [
    # needed for Intel Iris Xe
    "i915.force_probe=46a8"
    "i915.enable_guc=3"
    "i915.fastboot=1"
    # needed for keyboard
    "i8042.dumbkbd=1"
    "i8042.nopnp=1"
  ];

  services.xserver.videoDrivers = lib.mkDefault [ "intel" ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

}
