{
  lib,
  ...
}:
{
  zramSwap.enable = true;
  zramSwap.algorithm = "zstd";

  boot.kernel.sysctl = {
    "vm.swappiness" = lib.mkDefault 1;
    "vm.vfs_cache_pressure" = lib.mkDefault 50;
  };
}
