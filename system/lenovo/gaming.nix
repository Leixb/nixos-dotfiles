{pkgs, ...}:

{
  boot.kernel.sysctl = {
    "abi.vsyscall32" = 0; # lol anti-cheat
  };

  boot.kernelPackages = pkgs.linuxPackages_xanmod;

  programs.steam.enable = true;

  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
      };

      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
      };
    };
  };
}
