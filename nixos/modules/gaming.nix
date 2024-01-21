{ pkgs, ... }: {

  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.java.enable = true;
  programs.steam.package = pkgs.steam.override {
    # withJava = true;
    extraLibraries = (pkgs: [ pkgs.openssl ]);
  };

  programs.gamemode = {
    enable = true;
    settings = {
      general = { renice = 10; };

      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
      };
    };
  };
}
