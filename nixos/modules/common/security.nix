{
  security.pam.services.swaylock = { };
  security.pam.services.leix.enableGnomeKeyring = true;
  security.polkit.enable = true;

  # needed for zotero build
  nixpkgs.config.permittedInsecurePackages = [
    "firefox-esr-140-bin-unwrapped-140.17.0esr"
  ];
}
