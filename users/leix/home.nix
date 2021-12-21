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
  };

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    xwayland = false;
    config = {
      modifier = "Mod4";
      terminal = "kitty";
      menu = "wofi --show drun";
      input = {
        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
        };
      };
      window = {
        titlebar = false;
      };
      bars = [ ];
    };
  };

  xdg = {
    enable = true;
    configFile = {
      "nvim" = {
        recursive = true;
        source = inputs.neovim-config.outPath;
      };
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.packages = with pkgs; [
    cachix
    neovim
    discord
    bitwarden
    swaylock
    swayidle
    swaybg
    wl-clipboard
    mako # notification daemon
    wofi # Dmenu is the default in the config but i recommend wofi since its wayland native
    tdesktop # telegram desktop
    gcc
    fd
    zathura
    bottom
    dbeaver-adawaita
    ripgrep
    lutris
    zotero
  ] ++ [
    inputs.rnix-lsp.packages.x86_64-linux.rnix-lsp
  ];

  services = {
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
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
      wayland_titlebar_color = "#1c262b";

      background = "#1c262b";
      foreground = "#c1c8d6";
      cursor = "#b2b8c3";
      selection_background = "#6dc1b8";
      color0 = "#000000";
      color8 = "#767676";
      color1 = "#ee2a29";
      color9 = "#dc5b60";
      color2 = "#3fa33f";
      color10 = "#70be71";
      color3 = "#fee92e";
      color11 = "#fef063";
      color4 = "#1d80ef";
      color12 = "#53a4f3";
      color5 = "#8800a0";
      color13 = "#a94dbb";
      color6 = "#16aec9";
      color14 = "#42c6d9";
      color7 = "#a4a4a4";
      color15 = "#fffefe";
      selection_foreground = "#1c262b";
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
    ];

    aliases = {
      lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
    };

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

  programs.firefox.enable = true;
  programs.firefox.extensions = with pkgs.nur.repos.rycee.firefox-addons; [
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

  programs.firefox.profiles.leix = {
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

  programs.waybar = {
    enable = true;
    settings = [{
      modules-left = [ "sway/workspaces" "sway/mode" "wlr/taskbar" ];
      modules-center = [ "sway/window" ];
      modules-right = [
        "tray"
        "idle_inhibitor"
        "backlight"
        "pulseaudio"
        "bluetooth"
        "network"
        "memory"
        "cpu"
        "temperature"
        "disk"
        "sway/language"
        "battery"
        "clock"
      ];
    }];
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
