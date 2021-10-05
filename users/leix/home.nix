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

nixpkgs.config = {
  allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "discord"
    "vscode"
  ];
  };

  home.packages = with pkgs; [
    vscode
    discord
    swaylock
    swayidle
    wl-clipboard
    mako # notification daemon
    kitty # Alacritty is the default terminal in the config
    wofi # Dmenu is the default in the config but i recommend wofi since its wayland native
    tdesktop # telegram desktop
  ];

  home.file = {
    #".config/nvim/lua".source = ./neovim-config/lua;
    #".config/nvim/init.lua".source = ./neovim-config/init.lua;
    #".config/nvim/init.vim".text = "echo hello; luafile init.lua\n";
  };

  # Direnv
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.fish.enable = true;

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
