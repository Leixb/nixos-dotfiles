{ config, pkgs, lib, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "leix";
  home.homeDirectory = "/home/leix";

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true ;
    config = {
      modifier = "Mod4";
	    window = {
		    titlebar = false;
	    };
    };
  };

  home.packages = with pkgs; [
    vscode
    discord
    bitwarden
    swaylock
    swayidle
    wl-clipboard
    mako # notification daemon
    alacritty # Alacritty is the default terminal in the config
    wofi # Dmenu is the default in the config but i recommend wofi since its wayland native
    tdesktop # telegram desktop
  ];

  home.file = {
    #".config/nvim/lua".source = ./users/leix/neovim-config/lua;
    #".config/nvim/init.lua".source = ./users/leix/neovim-config/init.lua;
    #".config/nvim/init.vim".text = "echo hello; luafile init.lua\n";
  };

  programs.neovim.configure = {
    customRC = ''
    luafile ~/.config/nvim/init.lua
    '';
  };

  programs.git = {
    userEmail = "abone9999@gmail.com";
    userName = "LeixB";

    ignores = [
      "*~"
      "*.swp"
    ];

    extraConfig = {
      init = {
        defaultBranch = "master";
      };
    };
  };

  # Direnv
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.fish = {
    enable = true;
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
  #programs.firefox.extensions = with nur.repos.rycee.firefox-addons; [
  programs.firefox.extensions = with pkgs.nur.repos.rycee.firefox-addons; [
    https-everywhere
    privacy-badger
    ublock-origin
  ];

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
