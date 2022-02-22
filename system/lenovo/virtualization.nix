{ pkgs, ... }:

{
  boot.kernelParams = [
    "intel_iommu=on"
    "iommu=pt"
  ];

  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  environment.systemPackages = with pkgs; [
    virt-manager
  ];
}
