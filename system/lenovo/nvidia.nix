{ config, pkgs, lib, inputs, ... }:
let
  prime-run = pkgs.writeShellScriptBin "prime-run" ''
    __NV_PRIME_RENDER_OFFLOAD=1 __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0 __VK_LAYER_NV_optimus=NVIDIA_only __GLX_VENDOR_LIBRARY_NAME=nvidia "$@"
  '';
in
{
  boot.blacklistedKernelModules = [ "i2c_nvidia_gpu" ];

  hardware.nvidia = {
    # Use latest driver version
    package =
      let nPkgs = config.boot.kernelPackages.nvidiaPackages;
      in lib.mkForce
        (if (lib.versionOlder nPkgs.beta.version nPkgs.stable.version) then
          nPkgs.stable
        else
          nPkgs.beta);

    modesetting.enable = true;

    # prime = {
    #   offload.enable = true;
    #   intelBusId = "PCI:0:2:0";
    #   nvidiaBusId = "PCI:1:0:0";
    # };
  };

  hardware.opengl.extraPackages = with pkgs; [
      nvidia-vaapi-driver
      linuxPackages.nvidia_x11
  ];

  services.xserver.videoDrivers = [ "nvidia" ];

  # hardware.nvidia.powerManagement.finegrained = true;

  # environment.systemPackages = [ prime-run ];
  # environment.sessionVariables = {
  # __EGL_VENDOR_LIBRARY_FILENAMES = "${pkgs.linuxPackages.nvidia_x11}/share/glvnd/egl_vendor.d/10_nvidia.json";
  # };
}
