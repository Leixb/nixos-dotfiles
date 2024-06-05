{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    wxparaver
    slack
    openfortivpn
  ];

  sops.secrets.ssh_config_bsc.path = "${config.home.homeDirectory}/.ssh/config.d/bsc";

  programs.ssh = {
    enable = true;

    addKeysToAgent = "yes";

    includes = [
      config.sops.secrets.ssh_config_bsc.path
    ];
  };
}
