{ pkgs, ... }: {

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.java.enable = true;
  programs.steam.package = pkgs.steam.override {
    extraLibraries = (pkgs: [ pkgs.openssl ]);
  };

  environment.systemPackages = [ pkgs.mangohud ];

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
