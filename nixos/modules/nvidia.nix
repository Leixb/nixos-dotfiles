{ config, pkgs, lib, inputs, ... }:
let
  prime-run = pkgs.writeShellScriptBin "prime-run" ''
    __NV_PRIME_RENDER_OFFLOAD=1 __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0 __VK_LAYER_NV_optimus=NVIDIA_only __GLX_VENDOR_LIBRARY_NAME=nvidia "$@"
  '';
  intelBusId = "PCI:0:2:0";
  nvidiaBusId = "PCI:1:0:0";
in
{
  boot = {
    loader.grub.configurationName = lib.mkForce "nvidia-vulkan";
    blacklistedKernelModules = [ "i2c_nvidia_gpu" "nouveau" "rivafb" "nvidiafb" "rivatv" "nv" "uvcvideo" ];
    kernelModules = [
      "clearcpuid=514" # Fixes certain wine games crash on launch
      "nvidia"
      "nvidia_modeset"
      "nvidia_uvm"
      "nvidia_drm"
    ];
    kernelParams = [ "nouveau.modeset=0" ];
    extraModprobeConfig = ''
      options nvidia NVreg_UsePageAttributeTable=1
      options nvidia NVreg_RegistryDwords="OverrideMaxPerf=0x1"
      options nvidia NVreg_PreserveVideoMemoryAllocations=1
      NVreg_TemporaryFilePath=/var/tmp
    '';
  };
  hardware = {
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
      prime = { inherit intelBusId; inherit nvidiaBusId; sync.enable = true; };
      modesetting.enable = true;
      nvidiaPersistenced = true;
      forceFullCompositionPipeline = true;
    };
  };
  environment = {
    variables = {
      "VK_ICD_FILENAMES" = "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/intel_icd.i686.json:/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
      GBM_BACKEND = "nvidia-drm";
      LIBVA_DRIVER_NAME = "nvidia";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      NVD_BACKEND = "direct";
    };
    systemPackages = with pkgs; [ prime-run vulkan-loader vulkan-validation-layers vulkan-tools glxinfo inxi ];
  };
  services.xserver = { videoDrivers = [ "nvidia" ]; };
}
