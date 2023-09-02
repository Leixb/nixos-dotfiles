# vim: sw=2 ts=2:
{ config, lib, pkgs, osConfig, system, inputs, ... }:
{
  # Autorandr flickers a lot when changing with multiple monitors on startup.
  # A single xrandr call from the display manager setup phase is enough to set
  # things properly, we save the configuration but do not use the autorandr
  # service since it is not needed.
  services.autorandr.enable = false;
  programs.autorandr =
    let
      fingerprints = {
        DP-2 = "00ffffffffffff000daee81500000000211a0104a5221378022675a6565099270c505400000001010101010101010101010101010101b43b804a713834405036680058c110000018000000fe004e3135364843452d454e310a20000000fe00434d4e0a202020202020202020000000fe004e3135364843452d454e310a2000a2";
        DP-3 = "00ffffffffffff0030aefa6500000000291f0104b53e22783bb4a5ad4f449e250f5054a10800d100d1c0b30081c081809500a9c081004dd000a0f0703e80302035006d552100001a000000fd00283c858538010a202020202020000000fc004c454e204c3238752d33300a20000000ff0055314235363044460a20202020010402031bf14e61605f101f05140413121103020123097f0783010000a36600a0f0701f80302035006d552100001a565e00a0a0a02950302035006d552100001ae26800a0a0402e60302036006d552100001a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002f";
        HDMI-0 = "00ffffffffffff0022f0203301000000271a010380351e782ac020a656529c270f5054a10800d1c0b300a9c095008180810081c00101023a801871382d40582c45000f282100001e000000fd00323c1e5011000a202020202020000000fc00485020323465730a2020202020000000ff0033434d36333930394758202020014c020319b149901f0413031201021167030c0010000022e2002b023a801871382d40582c45000f282100001e023a80d072382d40102c45800f282100001e011d007251d01e206e2855000f282100001e011d00bc52d01e20b82855400f282100001e8c0ad08a20e02d10103e96000f28210000180000000000000000000000000b";
      };
      defaults = {
        DP-2 = {
          enable = true;
          scale = {
            x = 1.25;
            y = 1.25;
          };
          position = "0x810";
          mode = "1920x1080";
        };
        DP-3 = {
          enable = true;
          primary = true;
          position = "2400x0";
          mode = "3840x2160";
        };
        HDMI-0 = {
          enable = true;
          scale = {
            x = 1.5;
            y = 1.5;
          };
          position = "6240x540";
          mode = "1920x1080";
        };
      };
    in
    {
      enable = true;
      profiles = {
        laptop = {
          fingerprint = {
            inherit (fingerprints) DP-2;
          };
          config = {
            DP-2 = {
              enable = true;
              primary = true;
            };
          };
        };
        home_dual = {
          fingerprint = {
            inherit (fingerprints) DP-2 DP-3;
          };
          config = {
            inherit (defaults) DP-2 DP-3;
          };
        };
        home_triple = {
          fingerprint = {
            inherit (fingerprints) DP-2 DP-3 HDMI-0;
          };
          config = {
            inherit (defaults) DP-2 DP-3 HDMI-0;
          };
        };
      };
    };
}
