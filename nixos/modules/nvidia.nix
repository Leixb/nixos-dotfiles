{ config, pkgs, lib, inputs, ... }:
let
  intelBusId = "PCI:0:2:0";
  nvidiaBusId = "PCI:1:0:0";
in
{
  boot = {
    blacklistedKernelModules = [ "i2c_nvidia_gpu" "nouveau" ];
    kernelModules = [
      "i915"
      "nvidia"
      "nvidia_modeset"
      "nvidia_uvm"
      "nvidia_drm"
    ];
    kernelParams = [
      "nouveau.modeset=0"
      "clearcpuid=514" # Fixes certain wine games crash on launch
      "clearcpuid=304" # Fixes certain wine games crash on launch
    ];
    extraModprobeConfig = ''
      options nvidia NVreg_UsePageAttributeTable=1
      options nvidia NVreg_RegistryDwords="OverrideMaxPerf=0x1"
      options nvidia NVreg_PreserveVideoMemoryAllocations=1
      options nvidia NVreg_TemporaryFilePath=/var/tmp
    '';
  };
  nixpkgs.config.nvidia.acceptLicense = true;
  hardware = {
    nvidia = {
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
      prime = {
        inherit intelBusId; inherit nvidiaBusId;
        sync.enable = true;
        allowExternalGpu = true;
      };
      modesetting.enable = true;
    };
  };
  services.xserver = { videoDrivers = [ "nvidia" ]; };

  hardware.nvidia-container-toolkit.enable = true;
}
