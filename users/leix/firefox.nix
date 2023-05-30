{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    # package = pkgs.stable.firefox;

    profiles.leix = {
      settings = {
        "media.ffmpeg.vaapi.enabled" = true;
        "media.rdd-ffmpeg.enabled" = true;

        "media.ffvpx.enabled" = false;
        "gfx.x11-egl.force-enabled" = true;
        "gfx.webrender.all" = true;

        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;

        "browser.uidensity" = 1;

        "network.proxy.allow_hijacking_localhost" = true;

        # "privacy.webrtc.legacyGlobalIndicator" = false;
      };

      extensions = with pkgs.firefox-addons; [
        bitwarden
        darkreader
        (languagetool.overrideAttrs (oldAttrs: {
          meta.unfree = false;
        })) # Dirty workaround since nixpkgs.config.allowUnfree does not work with firefox-addons flake
        no-pdf-download
        privacy-badger
        refined-github
        ublock-origin
        sponsorblock
        # tree-style-tab
      ];

      bookmarks =
        [
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
                name = "Gmail (UPC)";
                url = "https://mail.google.com/mail/u/1/";
              }
              {
                name = "Raco";
                url = "https://raco.fib.upc.edu";
              }
              {
                name = "Atenea";
                url = "https://atenea.upc.edu";
              }
            ];
          }
          {
            name = "Wikipedia";
            keyword = "wiki";
            url = "https://en.wikipedia.org/wiki/Special:Search?search=%s&go=Go";
          }
          {
            name = "Gmail";
            url = "https://mail.google.com";
          }

          {
            name = "Nix";
            bookmarks = [
              {
                name = "NixOS";
                url = "https://nixos.org";
              }
              {
                name = "nixos-packages";
                keyword = "pkgs";
                url = "https://search.nixos.org/packages?query=%s";
              }

              {
                name = "nixos-options";
                keyword = "opts";
                url = "https://search.nixos.org/options?query=%s";
              }

              {
                name = "home-manager";
                url = "https://rycee.gitlab.io/home-manager/options.html";
              }

              {
                name = "home-manager-options";
                keyword = "hmopts";
                url = "https://mipmip.github.io/home-manager-option-search/?%s";
              }
              {
                name = "nix-pr-tracker";
                keyword = "nixpr";
                url = "https://nixpk.gs/pr-tracker.html?pr=%s";
              }
            ];
          }

          {
            name = "League";
            bookmarks = [
              {
                name = "MurderBridge";
                keyword = "aram";
                url = "https://www.murderbridge.com/champion/%s/";
              }

              {
                name = "MMR";
                keyword = "mmr";
                url = "https://euw.whatismymmr.com/%s";
              }

              {
                name = "OP.GG";
                keyword = "opgg";
                url = "https://euw.op.gg/summoners/euw/%s";
              }

              {
                name = "U.GG";
                keyword = "ugg";
                url = "https://u.gg/lol/champions/%s/build";
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
                name = "Reddit";
                url = "https://www.reddit.com";
              }
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

          {
            name = "Programming";
            bookmarks = [
              {
                name = "GitHub";
                url = "https://github.com";
              }
              {
                name = "GitLab";
                url = "https://gitlab.com";
              }
              {
                name = "StackOverflow";
                url = "https://stackoverflow.com";
              }
              {
                name = "HackerNews";
                url = "https://news.ycombinator.com";
              }
              {
                name = "kernel.org";
                url = "https://www.kernel.org";
              }
            ];
          }

          {
            name = "UPC";
            bookmarks = [
              {
                name = "Raco";
                url = "https://raco.fib.upc.edu";
              }
              {
                name = "Atenea";
                url = "https://atenea.upc.edu";
              }
              {
                name = "Discos";
                url = "https://discos.fib.upc.edu";
              }
              {
                name = "LearnSQL";
                url = "https://learnsql2.fib.upc.edu";
              }
              {
                name = "CCBDA";
                url = "https://ccbda-upc.github.io";
              }
            ];
          }

        ];
    };
  };
}
