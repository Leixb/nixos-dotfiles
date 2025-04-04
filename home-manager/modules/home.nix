# vim: sw=2 ts=2:
{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    home-assistant-cli
    jutge # jutge.org client
    legcord # discord client
    calibre # ebook manager
    gamescope # game window capture
    josm # OpenStreetMap Java editor
    plexamp # Plex music player
    tdesktop # Telegram desktop client
    element-desktop # Matrix client
    headsetcontrol # Logitech headset control
    picard # MusicBrainz tagger
    nicotine-plus # Soulseek client
    (mcaselector.overrideAttrs (oldAttrs: {
      nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs.wrapGAppsHook ];
    })) # Minecraft map editor
  ];

  programs.firefox.profiles.${config.home.username}.bookmarks.settings = [
    {
      toolbar = true;
      bookmarks = [
        {
          name = "GitHub";
          url = "https://github.com";
        }
        {
          name = "Gmail";
          url = "https://mail.google.com/mail/u/0/";
        }
        {
          name = "BSC";
          bookmarks = import ./bsc/bookmarks.nix;
        }
      ];
    }
    {
      name = "Entretainment";
      bookmarks = [
        {
          name = "YouTube";
          url = "https://www.youtube.com";
        }
        {
          name = "Netflix";
          url = "https://www.netflix.com";
        }
        {
          name = "Spotify";
          url = "https://open.spotify.com";
        }
        {
          name = "Twitch";
          keyword = "twtv";
          url = "https://www.twitch.tv/%s";
        }
        {
          name = "Disney+";
          url = "https://www.disneyplus.com";
        }
        {
          name = "PleX";
          url = "https://app.plex.tv";
        }
      ];
    }

    {
      name = "Social";
      bookmarks = [
        {
          name = "Telegram";
          url = "https://web.telegram.org";
        }
        {
          name = "Discord";
          url = "https://discord.com/app";
        }
        {
          name = "Twitter";
          url = "https://twitter.com";
        }
        {
          name = "Instagram";
          url = "https://www.instagram.com";
        }
        {
          name = "WhatsApp";
          url = "https://web.whatsapp.com";
        }
      ];
    }


  ];
}
