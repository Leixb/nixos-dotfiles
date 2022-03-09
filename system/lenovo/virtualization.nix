{ pkgs, ... }:

{
  boot.kernelParams = [
    "intel_iommu=on"
    "iommu=pt"
  ];

  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  virtualisation.docker.enable = false;
  virtualisation.podman = {
    enable = true;
    enableNvidia = true;
    dockerCompat = false;
    dockerSocket.enable = true;
    defaultNetwork.dnsname.enable = true;
  };

  users.extraUsers.leix.extraGroups = ["podman"];

  environment.systemPackages = with pkgs; [
    virt-manager
    arion
    docker-client
  ];
}
