# vim: sw=2 ts=2:
{ config, lib, pkgs, system, inputs, ... }:
let
  username = "leix";

  dbeaver-adawaita = pkgs.symlinkJoin {
    name = "dbeaver";
    paths = [ pkgs.dbeaver ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/dbeaver" --set GTK_THEME "Adwaita:light"
    '';
  };

  vpn-connect = pkgs.writeShellScriptBin "vpn-connect" ''
    sudo ${pkgs.gof5}/bin/gof5 -server https://upclink.upc.edu -username aleix.bone "$@"
  '';
in {
  imports = [ ./mime-apps.nix ./neovim.nix ../modules/all.nix ];

  # Let Home Manager install and manage itself.
  #programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = username;
  home.homeDirectory = "/home/${username}";

  home.file.".gof5/config.yaml".text = ''
    dns:
    - .upc.edu.
    - .upc.

    routes:
    - 10.0.0.0/8
    - 147.83.0.0/16
  '';

  theme = {
    enable = true;
    font = {
      family = "JetBrainsMono Nerd Font Mono";
      size = 13;
    };
    enableKittyTheme = true;
    enableBatTheme = true;
    enableZathuraTheme = true;
  };

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.capitaine-cursors;
    name = "capitaine-cursors";
    size = 32;
  };

  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Teal-Dark";
      package = pkgs.catppuccin-gtk;
    };
    iconTheme = {
      name = "Arc";
      package = pkgs.arc-icon-theme;
    };
    gtk3.bookmarks = [ "file:///home/leix/Documents/UPC" ];
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    TERMINAL = "kitty";
    WINEDLLOVERRIDES =
      "winemenubuilder.exe=d"; # Prevent wine from making file associations
    WEBKIT_DISABLE_COMPOSITING_MODE =
      1; # https://github.com/NixOS/nixpkgs/issues/32580

    DOCKER_CONFIG = "${config.xdg.configHome}/docker";
    ANDROID_HOME = "${config.xdg.dataHome}/android";
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
    GRIPHOME = "${config.xdg.configHome}/grip";
    PARALLEL_HOME = "${config.xdg.configHome}/parallel";
    JUPYTER_CONFIG_DIR = "${config.xdg.configHome}/jupyter";
    KERAS_HOME = "${config.xdg.stateHome}/keras";
  };

  home.packages = with pkgs; [
    cachix
    todoist-electron
    plexamp
    ripcord
    bitwarden
    bitwarden-cli
    tdesktop # telegram desktop
    element-desktop
    fd
    bottom
    beekeeper-studio
    ripgrep
    zotero
    zip
    unzip
    file
    flameshot
    gimp
    inkscape
    krita
    libreoffice
    mpv
    vlc
    feh
    git-extras
    solaar
    headsetcontrol
    pavucontrol
    vpn-connect
    eduroam
    alsa-utils
    libnotify
    gh
    gnome.simple-scan
    libqalculate
    qalculate-gtk
    comma
    acpi
    miniserve
    sshfs
    home-assistant-cli
    luakit
    neofetch
    pcmanfm
    powertop
    gcr
  ];

  programs.sagemath = {
    enable = true;
    package = pkgs.sageWithDoc;
    initScript = ''
      %colors Linux
    '';
  };

  systemd.user.services.gammastep.Install.WantedBy = lib.mkForce [ ];

  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";
  };
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = 3600;
    defaultCacheTtlSsh = 3600;
    pinentryFlavor = "gtk2";
  };

  services = {
    caffeine.enable = true;

    gammastep = {
      enable = true;
      longitude = 41.4;
      latitude = 2.0;
    };

    network-manager-applet.enable = true;
    blueman-applet.enable = true;
  };

  programs.kitty = {
    enable = true;
    settings = {
      disable_ligatures = "cursor";
      background_opacity = "0.75";
      confirm_os_window_close = 0;

      enable_audio_bell = "no";
    };
  };

  programs.git = {
    enable = true;
    userEmail = "abone9999@gmail.com";
    userName = "LeixB";
    signing.key = "FC035BB2BB28E15D";
    signing.signByDefault = true;

    ignores = [ "*~" "*.swp" "/.direnv/" ];

    aliases = {
      lg =
        "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
    };

    delta = {
      enable = true;
      options = { line-numbers = true; };
    };
    lfs.enable = true;

    extraConfig = {
      init = { defaultBranch = "master"; };
      pull = { rebase = true; };
    };
  };

  # Direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.global.warn_timeout = "30m";
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      cat = "bat";
      vim = "nvim";
      vi = "nvim";
      o = "xdg-open";
      gtd = "nvim -c 'Neorg workspace gtd' -c 'Neorg gtd views'";
      notes = "nvim -c 'Neorg workspace notes'";
      journal = "nvim -c 'Neorg journal'";
    };
    interactiveShellInit = ''
      set fish_greeting
      fish_vi_key_bindings
      bind -M insert \e\; accept-autosuggestion

      set fish_cursor_default     block      blink
      set fish_cursor_insert      line       blink
      set fish_cursor_replace_one underscore blink
      set fish_cursor_visual      block
    '';
    functions = {
      gitignore =
        "curl -sL https://www.gitignore.io/api/$argv | tail -n+5 | head -n-2";
    };
  };

  programs.tmux = {
    enable = true;
    terminal = "xterm-kitty";
    keyMode = "vi";
    extraConfig = ''
      set -g mouse on
    '';
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.exa = {
    enable = true;
    enableAliases = true;
  };

  programs.bat = {
    enable = true;
    config.map-syntax = [ "flake.lock:JSON" ];
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      nix_shell = { symbol = "❄️ "; };
      rlang = { detect_files = [ ]; };
    };
  };

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      yzhang.markdown-all-in-one
      github.copilot
      editorconfig.editorconfig
      golang.go
    ];
  };

  programs.zathura.enable = true;

  programs.nix-index.enable = true;
  home.file.".cache/nix-index/files".source = pkgs.nix-index-database;

  programs.discord = {
    enable = true;
    openASAR = true;

    package = pkgs.discord-canary;

    options = {
      SKIP_HOST_UPDATE = true;

      IS_MAXIMIZED = false;
      IS_MINIMIZED = false;

      MIN_WIDTH = 0;
      MIN_HEIGHT = 0;

      openasar = {
        setup = true;
        quickstart = true;
      };
    };
  };

  programs.firefox = {
    enable = true;
    # package = pkgs.stable.firefox;
    extensions = with pkgs.firefox-addons; [
      bitwarden
      darkreader
      https-everywhere
      (languagetool.overrideAttrs (oldAttrs: {
        meta.unfree = false;
      })) # Dirty workaround since nixpkgs.config.allowUnfree does not work with firefox-addons flake
      netflix-1080p
      no-pdf-download
      privacy-badger
      refined-github
      ublock-origin
      sponsorblock
      tree-style-tab
    ];

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
      };

      bookmarks = {
        wikipedia = {
          keyword = "wiki";
          url = "https://en.wikipedia.org/wiki/Special:Search?search=%s&go=Go";
        };

        "kernel.org".url = "https://www.kernel.org";
        whatsapp.url = "https://web.whatsapp.com/";
        github.url = "https://github.com";
        gmail.url = "https://gmail.com";

        # nix
        nixos.url = "https://nixos.org";

        nixos-packages = {
          keyword = "pkgs";
          url = "https://search.nixos.org/packages?query=%s";
        };

        nixos-options = {
          keyword = "opts";
          url = "https://search.nixos.org/options?query=%s";
        };

        home-manager.url = "https://rycee.gitlab.io/home-manager/options.html";

        home-manager-options = {
          keyword = "hmopts";
          url = "https://mipmip.github.io/home-manager-option-search/?%s";
        };

        nix-pr-tracker = {
          keyword = "nixpr";
          url = "https://nixpk.gs/pr-tracker.html?pr=%s";
        };

        murder-bridge = {
          keyword = "aram";
          url = "https://www.murderbridge.com/champion/%s/";
        };

        mmr = {
          keyword = "mmr";
          url = "https://euw.whatismymmr.com/%s";
        };

        opgg = {
          keyword = "opgg";
          url = "https://euw.op.gg/summoners/euw/%s";
        };

        ugg = {
          keyword = "ugg";
          url = "https://u.gg/lol/champions/%s/build";
        };

        # streaming
        disneyplus.url = "https://disneyplus.com";
        netflix.url = "https://netflix.com";
        plex.url = "https://app.plex.tv";
        twitch = {
          keyword = "twtv";
          url = "https://twitch.tv/%s";
        };
        youtube.url = "https://youtube.com";

        # upc
        atenea.url = "https://atenea.upc.edu";
        disc.url = "https://discos.fib.upc.edu";
        learn.url = "https://learnsql2.fib.upc.edu";
        ccbda.url = "https://ccbda-upc.github.io";
        raco.url = "https://raco.fib.upc.edu";
      };
    };
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.11";
}
