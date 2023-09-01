# vim: sw=2 ts=2:
{ config, lib, pkgs, osConfig, system, inputs, ... }:
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

  home.stateVersion = "22.05";
}
