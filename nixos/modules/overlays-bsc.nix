{ inputs, ... }:
{
  nixpkgs.overlays = [
    inputs.jungle.overlays.default
    inputs.wxparaver.overlays.default
    (import ../../../overlays/bsc.nix)
  ];
}
