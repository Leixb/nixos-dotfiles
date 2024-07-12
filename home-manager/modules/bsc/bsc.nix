{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    wxparaver-adwaita
    slack
    openfortivpn
    distrobox
    hyperfine
    jq
    gdb
  ];

  xdg.configFile."distrobox/distrobox.conf" = lib.mkForce {
    text = ''
      container_additional_volumes="/etc/profiles/per-user:/etc/profiles/per-user:ro /etc/static/profiles/per-user:/etc/static/profiles/per-user:ro /nix:/nix:ro"
    '';
  };

  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };

  sops.secrets.ssh_config_bsc.path = "${config.home.homeDirectory}/.ssh/config.d/bsc";

  programs.git.userName = "Aleix Boné";
  programs.git.includes = [{ path = config.sops.secrets.git_config_bsc.path; }];
  sops.secrets.git_config_bsc.path = "${config.xdg.configHome}/git/config.d/secret.inc";

  programs.ssh = {
    enable = true;

    addKeysToAgent = "yes";

    includes = [
      config.sops.secrets.ssh_config_bsc.path
    ];
  };

  programs.firefox.profiles.${config.home.username}.bookmarks = [
    {
      toolbar = true;
      bookmarks = import ./bookmarks.nix;
    }
  ];
}
