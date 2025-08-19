# vim: sw=2 ts=2:
{ config, lib, pkgs, osConfig, system, inputs, ... }:
let
  username = config.home.username;

  catppuccin-style = {
    name = "Colloid-Dark-Catppuccin";
    package = pkgs.colloid-gtk-theme.override {
      tweaks = [ "nord" "dracula" "gruvbox" "everforest" "catppuccin" "rimless" ];
    };
  };
in
{
  imports = [
    ../modules/all.nix
    ./sops.nix
    ./mime-apps.nix
    ./neovim.nix
    ./firefox.nix
    ./ssh.nix
    ./vcs.nix
    #./mpris.nix
  ];

  # Let Home Manager install and manage itself.
  #programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.homeDirectory = "/home/${username}";

  theme = {
    enable = true;
    font = {
      family = "JetBrainsMono Nerd Font Mono";
      size = lib.mkDefault 13;
    };
    enableKittyTheme = true;
    enableAlacrittyTheme = true;
    enableFootTheme = true;
    enableBatTheme = true;
    enableZathuraTheme = true;
    enableLuakitTheme = true;
    enableDunstTheme = true;
  };

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.capitaine-cursors-themed;
    name = "Capitaine Cursors (Nord)";
    x11.enable = true;
    size = lib.mkDefault 48;
  };

  gtk = {
    enable = true;
    theme = catppuccin-style;
    iconTheme = {
      name = "Arc";
      package = pkgs.arc-icon-theme;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style = catppuccin-style;
  };

  home.sessionVariables = {
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
    acpi # battery info
    alsa-utils # sound
    bottom # system monitor
    cachix # nix binary cache manager
    devenv # Reproducible development environment
    fd # find alternative
    feh # image viewer
    file # file type detection
    flameshot # screenshot tool
    gh # github cli
    gimp3-with-plugins
    git-extras # git extensions
    simple-scan # scanner
    kitty-imgdiff # image diff
    inkscape # vector graphics editor
    krita # image editor
    libnotify # notification daemon
    libqalculate # calculator
    libreoffice # office suite
    miniserve # file server
    miniupnpc # upnp client
    # mpris-notifier # media change notification
    mpv # video player
    neofetch # system info
    notify # notification daemon
    pavucontrol # pulseaudio volume control
    pcmanfm # file manager
    playerctl # media player control
    powertop # power usage monitor
    qalculate-gtk # calculator (GUI)
    ripgrep # grep alternative
    sshfs # ssh filesystem mount
    tealdeer # simple help pages for commands
    thunderbird
    unzip # zip file extraction
    vlc # video player
    waypipe # wayland remote desktop
    zip # zip file creation
    tg # telegram terminal
    plexamp
  ];

  xdg.configFile."WebCord/Themes/catppuccin.theme.css".text = ''
    @import url("https://catppuccin.github.io/discord/dist/catppuccin-macchiato.theme.css");
  '';

  home.sessionVariables.IPYTHONDIR = "${config.xdg.configHome}/ipython";
  xdg.configFile."ipython/profile_default/ipython_config.py" = {
    recursive = true;
    text = ''
      c = get_config()
      c.InteractiveShell.colors = 'Linux'
    '';
  };
  programs.sagemath = {
    # enable = true;
    package = pkgs.sageWithDoc;
    initScript = ''
      %colors Linux
    '';
  };

  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";
  };
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry-qt;
    defaultCacheTtl = 3600;
    defaultCacheTtlSsh = 3600;
  };

  home.file.".profile".text = ''
    . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
  '';

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

  systemd.user.services.gammastep.Install.WantedBy = lib.mkForce [ ];

  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;
    settings = {
      disable_ligatures = "cursor";
      background_opacity = "0.75";
      confirm_os_window_close = 0;

      enable_audio_bell = "no";

      remember_window_size = "no";
      initial_window_width = 1920;
      initial_window_height = 1080;

      update_check_interval = 0;

      notify_on_cmd_finish = "unfocused";
    };
  };

  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    installVimSyntax = true;
    settings = {
      theme = "catppuccin-macchiato";
      font-size = lib.mkDefault 10;
      window-decoration = "none";
      background-opacity = 0.75;
      shell-integration = "fish";
      gtk-titlebar = false;
      cursor-invert-fg-bg = true;
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        opacity = 0.75;
      };
    };
  };

  programs.foot = {
    enable = true;
    settings = {
      colors.alpha = 0.75;
      main.dpi-aware = "no";
    };
  };

  # Direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.global.warn_timeout = "30m";
  };

  programs.zk = {
    enable = true;
    settings = {
      notebook.dir = "~/notebook";
    };
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      cat = "bat";
      vim = "nvim";
      vi = "nvim";
      o = "xdg-open";
      gtd = "nvim -c 'Neorg workspace gtd' -c 'Neorg gtd views'";
      today = "nvim -c 'Neorg workspace gtd' -c 'lua TasksToday()'";
      notes = "nvim -c 'Neorg workspace notes'";
      journal = "nvim -c 'Neorg journal'";
    };
    shellAbbrs = {
      gco = "git checkout";
      gc = "git commit -v";
      gp = "git push";
      gpf = "git push --force-with-lease";
      gl = "git lg";
      gcm = {
        setCursor = true;
        expansion = "git commit -m \"%\"";
      };
      da = "direnv allow";
      dotdot = {
        regex = "^\\.\\.+$";
        function = "multicd";
      };
      "!!" = {
        position = "anywhere";
        function = "last_history_item";
      };
      L = {
        position = "anywhere";
        setCursor = true;
        expansion = "% | less";
      };
      G = {
        position = "anywhere";
        expansion = "| grep";
      };
    };
    interactiveShellInit = ''
      set fish_greeting
      fish_vi_key_bindings
      bind -M insert \e\; accept-autosuggestion

      set fish_cursor_default     block      blink
      set fish_cursor_insert      line       blink
      set fish_cursor_replace_one underscore blink
      set fish_cursor_visual      block

      if status is-interactive
          if string match -q -- '*ghostty*' $TERM
              set -g fish_vi_force_cursor 1
          end
      end
    '';
    functions = {
      gitignore =
        "curl -sL https://www.gitignore.io/api/$argv | tail -n+5 | head -n-2";
      multicd =
        "echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)";
      last_history_item = "echo $history[1]";
    };
    plugins = [
      {
        name = "bass";
        src = pkgs.fetchFromGitHub {
          owner = "edc";
          repo = "bass";
          rev = "79b62958ecf4e87334f24d6743e5766475bcf4d0";
          sha256 = "sha256-3d/qL+hovNA4VMWZ0n1L+dSM1lcz7P5CQJyy+/8exTc=";
        };
      }
    ];
  };

  programs.tmux = {
    enable = true;

    terminal = "alacritty";
    keyMode = "vi";
    escapeTime = 0;
    mouse = true;
    clock24 = true;
    baseIndex = 1;

    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = vim-tmux-navigator;
        extraConfig = ''
          # Use prefix ctrl+l to clear screen
          bind C-l send-keys C-l
        '';
      }
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavour 'macchiato'
          set -g @catppuccin_window_tabs_enabled on
        '';
      }
      yank
      open
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
        '';
      }
      tmux-thumbs
      tmux-fzf
    ];

    extraConfig = ''
      set -ag terminal-overrides ",*:Tc" # true color support
      set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'  # undercurl support
      set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'  # underscore colours - needs tmux-3.0

      set-option -g renumber-windows on

      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi V send-keys -X select-line
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      # Split panes in current path
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      set -g default-terminal "tmux-256color"

      set -g set-titles on
    '';

    # tmuxp.enable = true;
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.eza = {
    enable = true;
  };

  programs.bat = {
    enable = true;
    config.map-syntax = [ "flake.lock:JSON" ];
  };

  programs.starship =
    let
      starship_nerdfonts_toml = pkgs.runCommand "starship_nerdfonts" { } ''
        ${pkgs.starship}/bin/starship preset nerd-font-symbols -o $out
      '';
      starship_nerdfonts = builtins.fromTOML (builtins.readFile starship_nerdfonts_toml);
    in
    {
      enable = true;
      enableFishIntegration = true;

      settings = starship_nerdfonts // {
        nix_shell.symbol = "❄️ ";
        directory.read_only = " ";
        memory_usage.symbol = "󰍛 ";
        package.symbol = " ";
        meson.symbol = "🧰 ";
        nim.symbol = "👾 ";
        rlang = { detect_files = [ ]; symbol = "📊 "; };
      };
    };

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      yzhang.markdown-all-in-one
      editorconfig.editorconfig
      golang.go
    ];
  };

  programs.zathura.enable = true;
  programs.sioyek = {
    enable = true;
    bindings = {
      "reload" = "R";
      "quit" = "q";
    };
    config = {
      should_launch_new_window = "1";
    };
  };

  programs.notmuch.enable = true;
  programs.neomutt = {
    enable = true;
    editor = "nvim";
    sidebar.enable = true;
    sort = "reverse-threads";
    vimKeys = true;
    unmailboxes = true;
    extraConfig = builtins.readFile ./neomutt.theme;
  };

  sops.secrets.email_pass.path = "${config.xdg.configHome}/mail/sops";

  accounts.email.maildirBasePath = "Mail";
  accounts.email.accounts.bsc = {
    address = "abonerib@bsc.es";
    aliases = [ "aleix.boneribo@bsc.es" ];
    primary = true;
    userName = "abonerib";
    realName = "Aleix Boné";
    passwordCommand = "cat ${config.sops.secrets.email_pass.path}";
    imap = {
      host = "mail.bsc.es";
      port = 993;
      tls.enable = true;
    };
    smtp = {
      host = "mail.bsc.es";
      port = 465;
      tls.enable = true;
    };
    neomutt.enable = true;
    neomutt.mailboxType = "imap";
    notmuch.enable = true;
    notmuch.neomutt.enable = true;
  };

  programs.nix-index.enable = true;
}
