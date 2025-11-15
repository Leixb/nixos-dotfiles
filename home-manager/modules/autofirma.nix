{ inputs, pkgs, ... }:
{
  imports = [
    inputs.autofirma-nix.homeManagerModules.default
  ];

  programs.autofirma = {
    enable = true;
    firefoxIntegration.profiles.leix.enable = true;
  };

  programs.firefox = {
    enable = true;
    policies = {
      SecurityDevices = {
        "OpenSC PKCS11" = "${pkgs.opensc}/lib/opensc-pkcs11.so";
      };
    };
  };
}
