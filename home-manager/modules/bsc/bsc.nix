{ config, lib, pkgs, ... }:
let

  paraver = pkgs.wxparaver.overrideAttrs (oldAttrs: {
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs.copyDesktopItems ];
  });

  wxparaver-adawaita = pkgs.symlinkJoin {
    name = "wxparaver";
    paths = [ paraver ];
    buildInputs = [ pkgs.makeWrapper pkgs.installShellFiles ];
    postBuild = ''
      wrapProgram "$out/bin/wxparaver" --set GTK_THEME "Adwaita:dark"
      installManPage $out/share/doc/wxparaver_help_contents/man/*
    '';
  };
in
{
  home.packages = with pkgs; [
    wxparaver-adawaita
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
