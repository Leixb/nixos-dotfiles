{ lib, ... }:
{
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;

    alsa.enable = true;
    alsa.support32Bit = lib.mkDefault false;

    pulse.enable = true;
    wireplumber.enable = true;
  };

}
