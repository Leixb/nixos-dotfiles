{ pkgs, ... }:
let
  browser = [ "firefox.desktop" ];
  associations = {
    "application/pdf" = [ "org.pwmt.zathura.desktop" ];
    "text/html" = browser;
    "x-scheme-handler/http" = browser;
    "x-scheme-handler/https" = browser;
    "x-scheme-handler/ftp" = browser;
    "x-scheme-handler/chrome" = browser;
    "x-scheme-handler/about" = browser;
    "x-scheme-handler/unknown" = browser;
    "application/x-extension-htm" = browser;
    "application/x-extension-html" = browser;
    "application/x-extension-shtml" = browser;
    "application/xhtml+xml" = browser;
    "application/x-extension-xhtml" = browser;
    "application/x-extension-xht" = browser;

    "audio/*" = "mpv.desktop";
    "video/*" = "mpv.desktop";
    "image/*" = "imv.desktop";
    "text/*" = "nvim.desktop";
    "inode/directory" = "pcmanfm.desktop";

    "message/rfc822" = "thunderbird.desktop";
    "x-scheme-handler/mailto" = "thunderbird.desktop";
    "text/calendar" = "thunderbird.desktop";
    "text/x-vcard" = "thunderbird.desktop";

    "x-scheme-handler/tg" = "userapp-Telegram Desktop-S07QK1.desktop";
  };
in
{
  xdg.mime.enable = true;
  xdg.mimeApps.enable = true;
  xdg.mimeApps.associations.added = associations;
  xdg.mimeApps.defaultApplications = associations;

  xdg.configFile."mimeapps.list".force = true;
}
