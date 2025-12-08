{ inputs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      firefox-addons = inputs.firefox-addons.packages.${final.stdenv.hostPlatform.system};
    })
    inputs.neorg-overlay.overlays.default
    inputs.jungle.overlays.default
    inputs.wxparaver.overlays.default
    (import ../../../overlays/bsc.nix)
    (import ../../../overlays/overlay.nix)
    (import ../../../overlays/packages.nix)
  ];
}
