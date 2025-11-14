{ pkgs, ... }:
{
  documentation.enable = true;
  documentation.dev.enable = true;
  documentation.doc.enable = true;
  documentation.man.enable = true;
  documentation.nixos.enable = true;

  environment.systemPackages = with pkgs; [
    man-pages
    man-pages-posix
  ];
}
