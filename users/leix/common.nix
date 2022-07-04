# vim: sw=2 ts=2:
{
  config,
  lib,
  pkgs,
  system,
  inputs,
  ...
}: let
  theme = import ./theme.nix;

  username = "leix";

  dbeaver-adawaita = pkgs.symlinkJoin {
    name = "dbeaver";
    paths = [pkgs.dbeaver];
    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram "$out/bin/dbeaver" --set GTK_THEME "Adwaita:light"
    '';
  };

  vpn-connect = pkgs.writeShellScriptBin "vpn-connect" ''
    sudo ${pkgs.gof5}/bin/gof5 -server https://upclink.upc.edu -username aleix.bone "$@"
  '';
in {
  imports = [./mime-apps.nix];

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

  xdg = {
    enable = true;
    configFile = {
      "nvim" = {
        recursive = true;
        source = inputs.neovim-config.outPath;
      };
    };
    dataFile = let 
      prefix = "tree-sitter-";
      grammars = lib.filterAttrs (k: v: lib.hasPrefix prefix k) pkgs.tree-sitter-grammars;
      filtered = lib.mapAttrs' (name: value: lib.nameValuePair (lib.removePrefix prefix name) value) grammars;
    in
      lib.mapAttrs' (name: value: lib.nameValuePair "nvim/site/parser/${name}.so" {source = value;}) filtered;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    TERMINAL = "kitty";
    WINEDLLOVERRIDES = "winemenubuilder.exe=d"; # Prevent wine from making file associations
    WEBKIT_DISABLE_COMPOSITING_MODE = 1; # https://github.com/NixOS/nixpkgs/issues/32580

    DOCKER_CONFIG="${config.xdg.configHome}/docker";
    ANDROID_HOME="${config.xdg.dataHome}/android";
    CARGO_HOME="${config.xdg.dataHome}/cargo";
    GNUPGHOME="${config.xdg.dataHome}/gnupg";
    GRIPHOME="${config.xdg.configHome}/grip";
    PARALLEL_HOME="${config.xdg.configHome}/parallel";
    JUPYTER_CONFIG_DIR="${config.xdg.configHome}/jupyter";
    KERAS_HOME="${config.xdg.stateHome}/keras";
  };

  programs.neovim = {
    enable = true;
    package = pkgs.symlinkJoin {
      name = "neovim";
      paths = [pkgs.neovim-nightly];
      buildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/nvim \
          --add-flags "-u ${config.xdg.configHome}/nvim/init.lua"
      '';
    };
    extraPackages = with pkgs; [
      gcc
      git
      inputs.rnix-lsp.packages.x86_64-linux.rnix-lsp
      zathura
      ripgrep
      fd
    ];
    withPython3 = true;
    withRuby = true;
    withNodeJs = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };

  home.packages = with pkgs; [
    cachix
    discord
    todoist-electron
    plexamp
    ripcord
    bitwarden
    bitwarden-cli
    tdesktop # telegram desktop
    element-desktop
    fd
    zathura
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
  ];

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.capitaine-cursors;
    name = "capitaine-cursors";
    size = 32;
  };

  systemd.user.services.gammastep.Install.WantedBy = lib.mkForce [];

  services = {
    caffeine.enable = true;

    gammastep = {
      enable = true;
      longitude = 41.4;
      latitude = 2.0;
    };

    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      defaultCacheTtl = 3600;
      defaultCacheTtlSsh = 3600;
      pinentryFlavor = "gtk2";
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

      wayland_titlebar_color = theme.background;
    } // (lib.filterAttrs (n: v: n != "palette") theme);
  };

  programs.git = {
    enable = true;
    userEmail = "abone9999@gmail.com";
    userName = "LeixB";
    signing.key = "FC035BB2BB28E15D";
    signing.signByDefault = true;

    ignores = [
      "*~"
      "*.swp"
      "/.direnv/"
    ];

    aliases = {
      lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
    };

    delta = {
      enable = true;
      options = with theme.palette; {
        line-numbers = true;
        line-numbers-zero-style = "${white}";
        line-numbers-minus-style = "${red}";
        line-numbers-plus-style = "${green}";
      };
    };
    lfs.enable = true;

    extraConfig = {
      init = {
        defaultBranch = "master";
      };
      pull = {
        rebase = true;
      };
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
    };
    interactiveShellInit = ''
      set fish_greeting
      fish_vi_key_bindings
      bind -M insert \e\; accept-autosuggestion

      set fish_cursor_default     block      blink
      set fish_cursor_insert      line       blink
      set fish_cursor_replace_one underscore blink
      set fish_cursor_visual      block

      set fish_color_normal         "${theme.color4}"  # default color
      set fish_color_command        "${theme.color4}" # commands like echo
      set fish_color_keyword        "${theme.color4}" --bold # keywords like if - this falls back on the command color if unset
      set fish_color_quote          "${theme.color3}"  # quoted text like "abc"
      set fish_color_redirection    "${theme.color14}" --bold # IO redirections like >/dev/null
      set fish_color_end            "${theme.color2}"  # process separators like ';' and '&'
      set fish_color_error          "${theme.color1}"  # syntax errors
      set fish_color_param          "${theme.color6}" # ordinary command parameters
      set fish_color_comment        "${theme.color8}"  # comments like '# important'
      set fish_color_selection      "${theme.color7}"  # selected text in vi visual mode
      set fish_color_operator       "${theme.color5}"  # parameter expansion operators like '*' and '~'
      set fish_color_escape         "${theme.color13}" # character escapes like 'n' and 'x70'
      set fish_color_autosuggestion "${theme.color15}"  # autosuggestions (the proposed rest of a command)
      set fish_color_cancel         "${theme.color1}"  # the '^C' indicator on a canceled command
      set fish_color_search_match   --background="${theme.color3}"  # history search matches and selected pager items (background only)
    '';
    functions = {
      gitignore = "curl -sL https://www.gitignore.io/api/$argv | tail -n+5 | head -n-2";
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
  home.sessionVariables = {
    FZF_DEFAULT_OPTS = with theme.palette; builtins.concatStringsSep " " [
      "--color=bg+:${gray},bg:${black},spinner:${flamingo},hl:${red}"
      "--color=fg:${white},header:${red},info:${pink},pointer:${yellow}"
      "--color=marker:${yellow},fg+:${flamingo},prompt:${pink},hl+:${red}"
    ];
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
    config = {
      map-syntax = [
        "flake.lock:JSON"
      ];
      theme = "catppuccin";
    };
    themes = {
      catppuccin = builtins.readFile (pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "sublime-text"; # Bat uses sublime syntax for its themes
        rev = "95c5f44d8f75dc7e5cb7d20180e991aac3841440";
        sha256 = "sha256-RQCo35Gi8M0Xonkvd6EBPNeid1OLStIXIIHq4x5nM/U=";
      } + "/Catppuccin.tmTheme");
    };
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      nix_shell = {
        symbol = "❄️ ";
      };
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

  programs.firefox = {
    enable = true;
    # package = pkgs.stable.firefox;
    extensions = with pkgs.firefox-addons; [
      bitwarden
      darkreader
      https-everywhere
      (languagetool.overrideAttrs (oldAttrs: {meta.unfree = false;})) # Dirty workaround since nixpkgs.config.allowUnfree does not work with firefox-addons flake
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

  programs.nix-index.enable = true;

  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-teal-dark";
      package = pkgs.catppuccin-gtk;
    };
    iconTheme = {
      name = "Arc";
      package = pkgs.arc-icon-theme;
    };
    gtk3.bookmarks = [
      "file:///home/leix/Documents/UPC"
    ];
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
