# vim: sw=2 ts=2:
{ pkgs, osConfig, ... }:
let
  username = osConfig.users.users.marc.name;
in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.packages = with pkgs; [ ];

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

}
