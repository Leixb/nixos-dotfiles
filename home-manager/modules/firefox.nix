{ lib, pkgs, config, ... }:
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
        "browser.tabs.groups.enabled" = true;
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

      extensions.packages = with pkgs.firefox-addons; [
        bitwarden
        darkreader
        (languagetool.overrideAttrs (oldAttrs: {
          meta.unfree = false;
        })) # Dirty workaround since nixpkgs.config.allowUnfree does not work with firefox-addons flake
        privacy-badger
        refined-github
        ublock-origin
        sponsorblock
        vimium
        stylus
        firefox-color
        duckduckgo-privacy-essentials
        multi-account-containers
        # tree-style-tab
      ];

      search = {
        force = true;
        default = "ddg";
        order = [
          "ddg"
          "wikipedia"
          "google"
          "WayBack Machine"
          "archive.today"
          "WayBack Machine (all)"
          "archive.today (all)"
          "Wordnik"
          "Open Library"
          "Marginalia"
          "Discu.eu"
          "Hacker News"
          "youtube"
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
          "bing".metaData.hidden = true;
          "amazondotcom-us".metaData.hidden = true;
          "ebay".metaData.hidden = true;
          "wikipedia".metaData.alias = "@wk";
          "google".metaData.alias = "@g";

          "WayBack Machine" = {
            urls = [{ template = "https://web.archive.org/web/{searchTerms}"; }];
            icon =
              "https://web.archive.org/_static/images/archive.ico";
            updateInterval = 24 * 60 * 60 * 1000; # daily
            definedAliases = [ "@wb" ];
          };
          "archive.today" = {
            urls = [{
              template = "https://archive.today/newest/{searchTerms}";
            }];
            icon = "https://archive.today/apple-touch-icon.png";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = [ "@at" ];
          };
          "WayBack Machine (all)" = {
            urls = [{
              template = "https://web.archive.org/web/*/{searchTerms}";
            }];
            icon =
              "https://web.archive.org/_static/images/archive.ico";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = [ "@wba" ];
          };
          "archive.today (all)" = {
            urls = [{ template = "https://archive.today/{searchTerms}*"; }];
            icon = "https://archive.today/apple-touch-icon.png";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = [ "@ata" ];
          };
          "Wordnik" = {
            urls = [{
              template = "https://wordnik.com/words/?myWord={searchTerms}";
            }];
            icon = "https://wordnik.com/img/favicon.png";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = [ "@wd" ];
          };
          "Open Library" = {
            urls = [{
              template = "https://openlibrary.org/search?q={searchTerms}";
            }];
            icon =
              "https://openlibrary.org/static/images/openlibrary-192x192.png";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = [ "@ol" ];
          };
          "Marginalia" = {
            urls = [{
              template =
                "https://search.marginalia.nu/search?query={searchTerms}";
            }];
            icon = "https://search.marginalia.nu/favicon.ico";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = [ "@mg" ];
          };
          "Discu.eu" = {
            urls = [{ template = "https://discu.eu/?q={searchTerms}"; }];
            icon = "https://discu.eu/static/favicon-32x32.png";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = [ "@du" ];
          };
          "Hacker News" = {
            urls =
              [{ template = "https://hn.algolia.com/?q={searchTerms}"; }];
            icon = "https://news.ycombinator.com/favicon.ico";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = [ "@hn" ];
          };
          "youtube" = {
            urls = [{
              template =
                "https://www.youtube.com/results?search_query={searchTerms}";
            }];
            icon =
              "https://www.youtube.com/s/desktop/271dfaff/img/favicon_144x144.png";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = [ "@yt" ];
          };
          "Genius" = {
            urls =
              [{ template = "https://genius.com/search?q={searchTerms}"; }];
            icon = "https://genius.com/favicon.ico";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = [ "@gen" ];
          };
          "ManKier" = {
            urls =
              [{ template = "https://www.mankier.com/?q={searchTerms}"; }];
            icon = "https://www.mankier.com/favicon.ico";
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
            icon = "https://noogle.dev/_next/static/media/white.dc624142.svg";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = [ "@nxf" ];
          };
        };
      };

      bookmarks.force = true;
      bookmarks.settings =
        [
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
              {
                name = "hoogle";
                url = "https://hoogle.haskell.org";
              }
              {
                name = "noogle";
                url = "https://noogle.dev";
              }
            ];
          }

        ];
    };
  };
}
