# vim: sw=2 ts=2:
{ config, lib, pkgs, osConfig, system, inputs, ... }:
{
  sops.secrets.ssh_config_home.path = "${config.home.homeDirectory}/.ssh/config.d/home";
  sops.secrets.ssh_config_nas_lan.path = "${config.home.homeDirectory}/.ssh/config.d/nas_lan";
  sops.secrets.ssh_config_router.path = "${config.home.homeDirectory}/.ssh/config.d/router";
  sops.secrets.ssh_config_mc.path = "${config.home.homeDirectory}/.ssh/config.d/mc";

  # services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;

    addKeysToAgent = "yes";

    includes = [
      config.sops.secrets.ssh_config_home.path
      config.sops.secrets.ssh_config_nas_lan.path
      config.sops.secrets.ssh_config_router.path
      config.sops.secrets.ssh_config_mc.path
    ];
  };
}
