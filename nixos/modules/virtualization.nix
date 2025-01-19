{ ... }: {
  boot.kernelParams = [ "intel_iommu=on" "iommu=pt" ];

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  virtualisation.spiceUSBRedirection.enable = true;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };

  users.extraUsers.leix.extraGroups = [ "podman" ];
}
