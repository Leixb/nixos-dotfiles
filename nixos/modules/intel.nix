{
  hardware.cpu.intel.updateMicrocode = true;

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  # hardware.opengl.extraPackages = with pkgs;
  #   [
  #     intel-media-driver
  #     vaapiIntel
  #     vaapiVdpau
  #     libvdpau-va-gl
  #   ];

  # TODO: put this in kuro and all other
  # hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ vaapiIntel ];
}
