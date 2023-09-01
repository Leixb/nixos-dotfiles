# vim: sw=2 ts=2:
{ config, lib, pkgs, osConfig, system, inputs, ... }:
{
  sops.secrets.ssh_config_home_lan.path = "${config.home.homeDirectory}/.ssh/config.d/home_lan";
  sops.secrets.ssh_config_home_wan.path = "${config.home.homeDirectory}/.ssh/config.d/home_wan";
  sops.secrets.ssh_config_nas_lan.path = "${config.home.homeDirectory}/.ssh/config.d/nas_lan";

  programs.ssh = {
    enable = true;

    includes = [
      config.sops.secrets.ssh_config_home_lan.path
      config.sops.secrets.ssh_config_home_wan.path
      config.sops.secrets.ssh_config_nas_lan.path
    ];
  };
}
