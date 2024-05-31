{ pkgs, ... }: {
  boot.kernelParams = [ "intel_iommu=on" "iommu=pt" ];

  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  hardware.nvidia-container-toolkit.enable = true;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };

  users.extraUsers.leix.extraGroups = [ "podman" ];

  environment.systemPackages = with pkgs; [ virt-manager ];
}
