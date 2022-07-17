{ config, ... }:
let HOME = config.home.homeDirectory;
in {
  services = {
    mpd = {
      enable = true;
      musicDirectory = "nfs://192.168.1.3/volume1/music";
      extraConfig = ''
        audio_output {
          type            "pipewire"
          name            "PipeWire Sound Server"
        }
      '';
    };
  };

  programs.ncmpcpp = {
    enable = true;
    mpdMusicDir = "${HOME}/Music";
  };
}
