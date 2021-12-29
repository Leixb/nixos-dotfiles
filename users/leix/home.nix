# vim: sw=2 ts=2:
{ config, lib, pkgs, inputs, ... }:

let


  dbeaver-adawaita = pkgs.symlinkJoin {
    name = "dbeaver";
    paths = [ pkgs.dbeaver ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/dbeaver" --set GTK_THEME "Adwaita:light"
    '';
  };

  open-arch-home = pkgs.writers.writeBashBin "open-arch-home" ''
    set -e
    ${pkgs.coreutils}/bin/mkdir -p /tmp/mnt

    sudo ${pkgs.util-linux}/bin/mount /dev/sda2 /tmp/mnt
    sudo ${pkgs.util-linux}/bin/losetup /dev/loop7 -P /tmp/mnt/leix.home
    sudo ${pkgs.cryptsetup}/bin/cryptsetup open /dev/loop7p1 leix
    sudo ${pkgs.util-linux}/bin/mount /dev/mapper/leix /tmp/mnt/leix
  '';

  close-arch-home = pkgs.writers.writeBashBin "close-arch-home" ''
    set -e

    sudo ${pkgs.util-linux}/bin/umount /dev/mapper/leix
    sudo ${pkgs.cryptsetup}/bin/cryptsetup close leix
    sudo ${pkgs.util-linux}/bin/losetup -d /dev/loop7
    sudo ${pkgs.util-linux}/bin/umount /dev/sda2
  '';

  vpn-connect = pkgs.writeShellScriptBin "vpn-connect" ''
    sudo ${pkgs.gof5}/bin/gof5 -server https://upclink.upc.edu -username aleix.bone
  '';

  theme = {
    name = "Nightfly";
    font = "Fira Mono";
    font_size = "11.0";
    
    background  = "#011627";
    foreground  = "#acb4c2";
    cursor  = "#9ca1aa";
    color0  = "#1d3b53";
    color1  = "#fc514e";
    color2  = "#a1cd5e";
    color3  = "#e3d18a";
    color4  = "#82aaff";
    color5  = "#c792ea";
    color6  = "#7fdbca";
    color7  = "#a1aab8";
    color8  = "#7c8f8f";
    color9  = "#ff5874";
    color10  = "#21c7a8";
    color11  = "#ecc48d";
    color12  = "#82aaff";
    color13  = "#ae81ff";
    color14  = "#7fdbca";
    color15  = "#d6deeb";
    selection_background  = "#b2ceee";
    selection_foreground  = "#080808";
  };

in
{
  # Let Home Manager install and manage itself.
  #programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "leix";
  home.homeDirectory = "/home/leix";

  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>Return";
      command="${pkgs.kitty}/bin/kitty";
      name="kitty";
    };
    "org/gnome/shell" = {
      favorite-apps=["firefox.desktop" "kitty.desktop" "org.gnome.Nautilus.desktop"];
    };
    "org/gnome/GWeather" = {
      temperature-unit = "centigrade";
    };
    "org/gnome/shell/weather" = {
      automatic-location=true;
    };
  };

  xdg = {
    enable = true;
    configFile = {
      "nvim" = {
        recursive = true;
        source = inputs.neovim-config.outPath;
      };
      # "awesome" = {
        # recursive = true;
        # source = inputs.awesome-config.outPath;
      # };
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    TERMINAL = "kitty";
    WINEDLLOVERRIDES = "winemenubuilder.exe=d"; # Prevent wine from making file associations
    WEBKIT_DISABLE_COMPOSITING_MODE = 1; # https://github.com/NixOS/nixpkgs/issues/32580
  };

  # xsession.windowManager.awesome = {
  #   enable = true;
  #   luaModules = [ pkgs.luaPackages.lain ];
  # };

  home.packages = with pkgs; [
    cachix
    neovim
    discord
    bitwarden
    tdesktop # telegram desktop
    gcc
    fd
    zathura
    bottom
    dbeaver-adawaita
    ripgrep
    lutris
    zotero
    manix
    zip
    open-arch-home
    close-arch-home
    flameshot
    gimp
    inkscape
    krita
    libreoffice
    mpv
    feh
    git-extras
    solaar
    headsetcontrol
    pavucontrol
    vpn-connect
    alsa-utils
  ] ++ [
    inputs.rnix-lsp.packages.x86_64-linux.rnix-lsp
  ];

  services = {
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
    };

    picom = {
      enable = true;
      backend = "glx";
      extraOptions = ''
      unredir-if-possible = true;
      '';
    };
  };

  programs.rofi = {
    enable = true;
    font = "${theme.font} ${theme.font_size}";
    extraConfig = {
	    modi = "combi,drun,window";
      show-icons = true;
      cycle = false;
      combi-modi = "window,drun";
	    combi-hide-mode-prefix = true;
      display-combi = "";
    };
  };

  programs.vscode = {
    enable = true;
  };

  programs.kitty = {
    enable = true;
    settings = {
      disable_ligatures = "cursor";
      background_opacity = "0.9";
      wayland_titlebar_color = theme.background;

      background = theme.background;
      foreground = theme.foreground;
      selection_foreground = theme.selection_foreground;
      selection_background = theme.selection_background;

      cursor  = theme.cursor;
      color0  = theme.color0;
      color8  = theme.color8;
      color1  = theme.color1;
      color9  = theme.color9;
      color2  = theme.color2;
      color10 = theme.color10;
      color3  = theme.color3;
      color11 = theme.color11;
      color4  = theme.color4;
      color12 = theme.color12;
      color5  = theme.color5;
      color13 = theme.color13;
      color6  = theme.color6;
      color14 = theme.color14;
      color7  = theme.color7;
      color15 = theme.color15;

      font_family = theme.font;
      font_size = theme.font_size;
    };
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
      options = {
        line-numbers = true;
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

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };

  # Direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableFishIntegration = true;
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      cat = "bat";
      vim = "nvim";
      vi = "nvim";
    };
    interactiveShellInit = ''
      set fish_greeting
      fish_vi_key_bindings

      set fish_cursor_default     block      blink
      set fish_cursor_insert      line       blink
      set fish_cursor_replace_one underscore blink
      set fish_cursor_visual      block

      set fish_color_normal         "${theme.color4}"  # default color
      set fish_color_command        "${theme.color12}" # commands like echo
      set fish_color_keyword        "${theme.color12}" --bold # keywords like if - this falls back on the command color if unset
      set fish_color_quote          "${theme.color3}"  # quoted text like "abc"
      set fish_color_redirection    "${theme.color14}" --bold # IO redirections like >/dev/null
      set fish_color_end            "${theme.color2}"  # process separators like ';' and '&'
      set fish_color_error          "${theme.color9}"  # syntax errors
      set fish_color_param          "${theme.color14}" # ordinary command parameters
      set fish_color_comment        "${theme.color8}"  # comments like '# important'
      set fish_color_selection      "${theme.color7}"  # selected text in vi visual mode
      set fish_color_operator       "${theme.color5}"  # parameter expansion operators like '*' and '~'
      set fish_color_escape         "${theme.color13}" # character escapes like 'n' and 'x70'
      set fish_color_autosuggestion "${theme.color8}"  # autosuggestions (the proposed rest of a command)
      set fish_color_cancel         "${theme.color1}"  # the '^C' indicator on a canceled command
      set fish_color_search_match   --background="${theme.color3}"  # history search matches and selected pager items (background only)
    '';
    functions = {
      gitignore = "curl -sL https://www.gitignore.io/api/$argv | tail -n+5 | head -n-2";
    };
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
  programs.bat.enable = true;

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    # Configuration written to ~/.config/starship.toml
    settings = {
      # add_newline = false;

      # character = {
      #   success_symbol = "[➜](bold green)";
      #   error_symbol = "[➜](bold red)";
      # };

      # package.disabled = true;
    };
  };

  programs.firefox = {
    enable = true;
    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      bitwarden
      darkreader
      https-everywhere
      languagetool
      matte-black-red
      no-pdf-download
      privacy-badger
      refined-github
      ublock-origin
    ];

    profiles.leix = {
      settings = {
        "media.ffmpeg.vaapi.enabled" = true;
        "media.rdd-ffmpeg.enabled" = true;

        "media.ffvpx.enabled" = false;
      };

      bookmarks = {
        wikipedia = {
          keyword = "wiki";
          url = "https://en.wikipedia.org/wiki/Special:Search?search=%s&go=Go";
        };
        "kernel.org" = {
          url = "https://www.kernel.org";
        };
      };
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Juno-ocean";
      package = pkgs.juno-theme;
    };
    iconTheme = {
      name = "Arc";
      package = pkgs.arc-icon-theme;
    };
    gtk3.bookmarks = [
      "file:///home/leix/Documents/UPC"
    ];
  };

  xsession.pointerCursor = {
    package = pkgs.capitaine-cursors;
    name = "capitaine-cursors";
    size = 32;
  };

  xresources.extraConfig = ''
  ! ${theme.name}

  *.background: ${theme.background}
  *.foreground: ${theme.foreground}

  !black
  *color0: ${theme.color0}
  *color8: ${theme.color8}

  !red
  *color1: ${theme.color1}
  *color9: ${theme.color9}

  !green
  *color2: ${theme.color2}
  *color10: ${theme.color10}

  !yellow
  *color3: ${theme.color3}
  *color11: ${theme.color11}

  !blue
  *color12: ${theme.color12}
  *color4: ${theme.color4}

  !magenta
  *color5: ${theme.color5}
  *color13: ${theme.color13}

  !cyan
  *color6: ${theme.color6}
  *color14: ${theme.color14}

  !white
  *color7: ${theme.color7}
  *color15: ${theme.color15}
  '';


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
