{ inputs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      firefox-addons = inputs.firefox-addons.packages.${final.stdenv.hostPlatform.system};
    })
    (import ../../../overlays/overlay.nix)
    (import ../../../overlays/packages.nix)
  ];
}
