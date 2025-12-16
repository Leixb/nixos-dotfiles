# vim: sw=2 ts=2:
{ config, pkgs, ... }:
{
  sops.secrets.ssh_config_home.path = "${config.home.homeDirectory}/.ssh/config.d/home";
  sops.secrets.ssh_config_nas_lan.path = "${config.home.homeDirectory}/.ssh/config.d/nas_lan";
  sops.secrets.ssh_config_router.path = "${config.home.homeDirectory}/.ssh/config.d/router";
  sops.secrets.ssh_config_mc.path = "${config.home.homeDirectory}/.ssh/config.d/mc";

  # services.ssh-agent.enable = true;

  home.packages = [ pkgs.autossh ];

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks."*" = {
      forwardAgent = false;
      compression = false;
      addKeysToAgent = "yes";
      hashKnownHosts = false;
      # controlMaster = "auto";
      # controlPersist = "10m";
      # controlPath = "~/.ssh/master-%r@%n:%p";
      serverAliveInterval = 60;
      serverAliveCountMax = 10;
    };

    includes = [
      config.sops.secrets.ssh_config_home.path
      config.sops.secrets.ssh_config_nas_lan.path
      config.sops.secrets.ssh_config_router.path
      config.sops.secrets.ssh_config_mc.path
    ];
  };
}
