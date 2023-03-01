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

  catppuccin-style = {
    name = "Catppuccin-Macchiato-Standard-Peach-Dark";
    package = pkgs.catppuccin-gtk.override {
      accents = [ "pink" "blue" "peach" ];
      variant = "macchiato";
    };
  };
in
{
  imports = [ ./mime-apps.nix ./neovim.nix ../modules/all.nix ./firefox.nix ];

  # Let Home Manager install and manage itself.
  #programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = username;
  home.homeDirectory = "/home/${username}";

  home.file.".gof5/config.yaml".text = /* yaml */ ''
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
    enableLuakitTheme = true;
  };

  # gtk = {
  #   enable = true;
  #   theme = {
  #     package = pkgs.gnome.gnome-themes-extra;
  #     name = "Adwaita-dark";
  #   };
  # };



  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.capitaine-cursors;
    name = "capitaine-cursors";
    size = 32;
  };

  gtk = {
    enable = true;
    theme = catppuccin-style;
    iconTheme = {
      name = "Arc";
      package = pkgs.arc-icon-theme;
    };
    gtk3.bookmarks = [ "file:///home/leix/Documents/UPC" ];
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = catppuccin-style;
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

  programs.taskwarrior.enable = true;
  xdg.dataFile."task/hooks/on-modify.timewarrior" = {
    executable = true;
    source = "${pkgs.timewarrior}/share/doc/timew/ext/on-modify.timewarrior";
  };

  home.packages = with pkgs; [
    timewarrior
    webcord
    cachix
    waypipe
    # inputs.devenv.packages.x86_64-linux.devenv
    # todoist-electron # electron 15 EOL
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
    (zotero.overrideAttrs (final: old: rec {
      # TODO: remove this when 6.0.22 is in nixpkgs
      version = "6.0.22";

      src = fetchurl {
        url = "https://download.zotero.org/client/release/${version}/Zotero-${version}_linux-x86_64.tar.bz2";
        sha256 = "sha256-OXlX4E5C6UEDR3+fDYB3O5isO8vABpd6hvrq+4kZ1iA=";
      };

      postInstall = ''
        wrapProgram "$out/bin/zotero" --set GTK_THEME "Adwaita:light"
      '';
    }))
    zotero7
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
    manix
    nix-tree
    nx-libs
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
    terminal = "xterm-kitty";
    keyMode = "vi";
    extraConfig = ''
      set -g mouse on
      setw -g mode-keys vi
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

  programs.discord = {
    enable = true;
    openASAR = true;

    # package = pkgs.discord-canary;

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
