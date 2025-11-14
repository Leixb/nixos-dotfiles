{ pkgs, lib, ... }:
{
  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.brlaser ];
  services.printing.browsed.enable = lib.mkForce false;
}
