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

      font_family = "Fira Mono";
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
  ! Powerarrow Dark

  *.background: #1A1A1A
  *.foreground: #DDDDFF

  !black
  *color0: #1A1A1A
  *color8: #6E6E6E

  !red
  *color1: #AF5360
  *color9: #EA6F81

  !green
  *color2: #447019
  *color10: #7BAB4E

  !yellow
  *color3: #D8D782
  *color11: #CFCD63

  !blue
  *color12: #92ADCB
  *color4: #648BB5

  !magenta
  *color5: #E5C8D6
  *color13: #CB92AD

  !cyan
  *color6: #406E6F
  *color14: #81DCDE

  !white
  *color7: #C6C6E5
  *color15: #DDDDFF
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
