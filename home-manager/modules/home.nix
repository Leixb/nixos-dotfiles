# vim: sw=2 ts=2:
{ config, lib, pkgs, osConfig, system, inputs, ... }:
let
  username = config.home.username;

  catppuccin-style = {
    name = "Catppuccin-Macchiato-Standard-Peach-dark";
    package = pkgs.catppuccin-gtk.override {
      accents = [ "pink" "blue" "peach" ];
      variant = "macchiato";
    };
  };
in
{
  imports = [ ../modules/all.nix ./sops.nix ./hyprland.nix ./mime-apps.nix ./neovim.nix ./firefox.nix ./ssh.nix ];

  # Let Home Manager install and manage itself.
  #programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.homeDirectory = "/home/${username}";

  theme = {
    enable = true;
    font = {
      family = "JetBrainsMono Nerd Font Mono";
      size = 13;
    };
    enableKittyTheme = true;
    enableAlacrittyTheme = true;
    enableFootTheme = true;
    enableBatTheme = true;
    enableZathuraTheme = true;
    enableLuakitTheme = true;
  };

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.capitaine-cursors;
    name = "capitaine-cursors";
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
    platformTheme = "gnome";
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
    acpi
    alsa-utils
    bottom
    cachix
    calibre
    comma
    devenv
    fd
    feh
    file
    flameshot
    gamescope
    gcr
    gh
    gimp-with-plugins
    git-extras
    gnome.simple-scan
    inkscape
    krita
    libnotify
    libqalculate
    libreoffice
    miniserve
    miniupnpc
    mpv
    neofetch
    notify
    pavucontrol
    pcmanfm
    playerctl
    powertop
    qalculate-gtk
    ripgrep
    sshfs
    unzip
    vlc
    waypipe
    webcord # discord
    zip
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
    enable = true;
    package = pkgs.stable.sageWithDoc;
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


  programs.git = {
    enable = true;
    signing.key = "~/.ssh/id_ed25519.pub";
    signing.signByDefault = true;

    userName = lib.mkDefault username;

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
      gpg = { format = "ssh"; };
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
      # gtd = "nvim -c 'Neorg workspace gtd' -c 'Neorg gtd views'";
      # today = "nvim -c 'Neorg workspace gtd' -c 'lua TasksToday()'";
      notes = "nvim -c 'Neorg workspace notes'";
      gtd = "nvim -c 'Neorg workspace tfm'";
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
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-nvim 'session'
        '';
      }
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
    '';

    tmuxp.enable = true;
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
    enableAliases = true;
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
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      yzhang.markdown-all-in-one
      github.copilot
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

  programs.nix-index.enable = true;
  home.file.".cache/nix-index/files".source = pkgs.nix-index-database;
}