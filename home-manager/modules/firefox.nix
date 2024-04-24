{ pkgs, config, ... }:
let username = config.home.username;
in {
  programs.firefox = {
    enable = true;
    # package = pkgs.stable.firefox;

    profiles.${username} = {
      isDefault = true;
      settings = {
        "media.ffmpeg.vaapi.enabled" = true;
        "media.rdd-ffmpeg.enabled" = true;

        "media.ffvpx.enabled" = false;
        "gfx.x11-egl.force-enabled" = true;
        "gfx.webrender.all" = true;

        "browser.uidensity" = 1;

        "network.proxy.allow_hijacking_localhost" = true;

        # "privacy.webrtc.legacyGlobalIndicator" = false;
        "browser.startup.homepage" = "https://start.duckduckgo.com";

        "app.shield.optoutstudies.enabled" = false;
        "app.update.auto" = false;
        "browser.bookmarks.restore_default_bookmarks" = false;
        "browser.contentblocking.category" = "strict";
        "browser.ctrlTab.recentlyUsedOrder" = false;
        "browser.discovery.enabled" = false;
        "browser.laterrun.enabled" = false;
        "browser.newtabpage.activity-stream.enabled" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" =
          false;
        "browser.newtabpage.activity-stream.feeds.snippets" = false;
        "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.havePinned" = "";
        "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.searchEngines" = "";
        "browser.newtabpage.activity-stream.section.highlights.includePocket" =
          false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.pinned" = false;
        "browser.protections_panel.infoMessage.seen" = true;
        "browser.quitShortcut.disabled" = true;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.ssb.enabled" = true;
        "browser.urlbar.placeholderName" = "DuckDuckGo";
        "browser.urlbar.suggest.openpage" = false;
        "datareporting.policy.dataSubmissionEnable" = false;
        "datareporting.policy.dataSubmissionPolicyAcceptedVersion" = 2;
        "dom.security.https_only_mode" = true;
        "dom.security.https_only_mode_ever_enabled" = true;
        "extensions.getAddons.showPane" = false;
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        "extensions.pocket.enabled" = false;
        "identity.fxaccounts.enabled" = false;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
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
        vimium
        stylus
        firefox-color
        duckduckgo-privacy-essentials
        # tree-style-tab
      ];

      search = {
        force = true;
        default = "DuckDuckGo";
        order = [
          "DuckDuckGo"
          "Wikipedia (en)"
          "Google"
          "WayBack Machine"
          "archive.today"
          "WayBack Machine (all)"
          "archive.today (all)"
          "Wordnik"
          "Open Library"
          "Marginalia"
          "Discu.eu"
          "Hacker News"
          "YouTube"
          "Genius"
          "ManKier"
          "Nix Packages"
          "NixOS Options"
          "Nix Home Manager Options"
          "NixOS Wiki"
          "Nixpkgs PR Tracker"
          "Noogle"
        ];

        engines = {
          "Bing".metaData.hidden = true;
          "Amazon.com".metaData.hidden = true;
          "eBay".metaData.hidden = true;
          "Wikipedia (en)".metaData.alias = "@wk";
          "Google".metaData.alias = "@g";

          "WayBack Machine" = {
            urls = [{ template = "https://web.archive.org/web/{searchTerms}"; }];
            iconUpdateURL =
              "https://web.archive.org/_static/images/archive.ico";
            updateInterval = 24 * 60 * 60 * 1000; # daily
            definedAliases = [ "@wb" ];
          };
          "archive.today" = {
            urls = [{
              template = "https://archive.today/newest/{searchTerms}";
            }];
            iconUpdateURL = "https://archive.today/apple-touch-icon.png";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = [ "@at" ];
          };
          "WayBack Machine (all)" = {
            urls = [{
              template = "https://web.archive.org/web/*/{searchTerms}";
            }];
            iconUpdateURL =
              "https://web.archive.org/_static/images/archive.ico";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = [ "@wba" ];
          };
          "archive.today (all)" = {
            urls = [{ template = "https://archive.today/{searchTerms}*"; }];
            iconUpdateURL = "https://archive.today/apple-touch-icon.png";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = [ "@ata" ];
          };
          "Wordnik" = {
            urls = [{
              template = "https://wordnik.com/words/?myWord={searchTerms}";
            }];
            iconUpdateURL = "https://wordnik.com/img/favicon.png";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = [ "@wd" ];
          };
          "Open Library" = {
            urls = [{
              template = "https://openlibrary.org/search?q={searchTerms}";
            }];
            iconUpdateURL =
              "https://openlibrary.org/static/images/openlibrary-192x192.png";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = [ "@ol" ];
          };
          "Marginalia" = {
            urls = [{
              template =
                "https://search.marginalia.nu/search?query={searchTerms}";
            }];
            iconUpdateURL = "https://search.marginalia.nu/favicon.ico";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = [ "@mg" ];
          };
          "Discu.eu" = {
            urls = [{ template = "https://discu.eu/?q={searchTerms}"; }];
            iconUpdateURL = "https://discu.eu/static/favicon-32x32.png";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = [ "@du" ];
          };
          "Hacker News" = {
            urls =
              [{ template = "https://hn.algolia.com/?q={searchTerms}"; }];
            iconUpdateURL = "https://news.ycombinator.com/favicon.ico";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = [ "@hn" ];
          };
          "YouTube" = {
            urls = [{
              template =
                "https://www.youtube.com/results?search_query={searchTerms}";
            }];
            iconUpdateURL =
              "https://www.youtube.com/s/desktop/271dfaff/img/favicon_144x144.png";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = [ "@yt" ];
          };
          "Genius" = {
            urls =
              [{ template = "https://genius.com/search?q={searchTerms}"; }];
            iconUpdateURL = "https://genius.com/favicon.ico";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = [ "@gen" ];
          };
          "ManKier" = {
            urls =
              [{ template = "https://www.mankier.com/?q={searchTerms}"; }];
            iconUpdateURL = "https://www.mankier.com/favicon.ico";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = [ "@man" ];
          };
          "Nix Packages" = {
            urls = [{
              template =
                "https://search.nixos.org/packages?channel=unstable&query={searchTerms}";
            }];
            icon =
              "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@nxp" ];
          };
          "Nixpkgs PR Tracker" = {
            urls = [{
              template =
                "https://nixpk.gs/pr-tracker.html?pr={searchTerms}";
            }];
            icon =
              "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@nxpr" ];
          };
          "NixOS Options" = {
            urls = [{
              template =
                "https://search.nixos.org/options?channel=unstable&query={searchTerms}";
            }];
            icon =
              "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@nxo" ];
          };
          "Nix Home Manager Options" = {
            urls = [{
              template =
                "https://mipmip.github.io/home-manager-option-search/?query={searchTerms}";
            }];
            icon =
              "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@nxh" ];
          };
          "NixOS Wiki" = {
            urls = [{
              template =
                "https://nixos.wiki/index.php?search={searchTerms}";
            }];
            icon =
              "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@nxw" ];
          };
          "Noogle" = {
            urls = [{
              template =
                "https://noogle.dev/?term={searchTerms}";
            }];
            iconUpdateURL = "https://noogle.dev/_next/static/media/white.dc624142.svg";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = [ "@nxf" ];
          };
        };
      };

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

        ];
    };
  };
}
