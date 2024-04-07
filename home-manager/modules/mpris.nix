{ lib, pkgs, ... }:

{
  systemd.user.services.mpris-notifier = {
    Unit = {
      Description = "Show desktop notifications for media/music track changes.";
      After = [ "hm-graphical-session.target" ];
    };
    Install.WantedBy = [ "default.target" ];
    Service.ExecStart = lib.getExe pkgs.mpris-notifier;
  };
}
