{
  boot.kernelParams = [
    "quiet"
    "rw"
    "nowatchdog"
    "hid_apple.fnmode=2" # make F-keys work as standard function keys
    "mitigations=off"
  ];

  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
  '';

  boot.loader = {
    systemd-boot = {
      # enable = true;
      editor = false;
      configurationLimit = 50;
    };
    # efi.canTouchEfiVariables = true;
    timeout = 0;
  };

  boot.supportedFilesystems = [ "ntfs" ];
}
