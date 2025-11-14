{ pkgs, ... }:
{
  powerManagement.cpuFreqGovernor = "performance";

  services.irqbalance.enable = true;

  systemd.oomd = {
    enable = true;
    # Fedora enables the first and third option by default. See the 10-oomd-* files here:
    # https://src.fedoraproject.org/rpms/systemd/tree/806c95e1c70af18f81d499b24cd7acfa4c36ffd6
    enableRootSlice = true;
    enableSystemSlice = false;
    enableUserSlices = true;
  };

  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
  };
}
