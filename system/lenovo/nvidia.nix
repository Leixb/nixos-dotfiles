{ config, pkgs, lib, inputs, ... }:

{
  boot.blacklistedKernelModules = [ "i2c_nvidia_gpu" ];

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];
}
