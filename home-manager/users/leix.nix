{ lib, pkgs, config, osConfig, ... }: {
  home.username = osConfig.users.users.leix.name;

  imports = [ ../modules/upc.nix ../modules/taskwarrior.nix ../modules/mime-apps.nix ];

  programs.git.userName = "LeixB";
  programs.git.includes = [{ path = config.sops.secrets.git_config.path; }];
  sops.secrets.git_config.path = "${config.xdg.configHome}/git/config.d/secret.inc";

  home.packages = with pkgs; [
    jutge
    miniupnpc
    plexamp
    tdesktop
    element-desktop
    beekeeper-studio
    zotero7
    (symlinkJoin {
      name = "zotero";
      paths = [ zotero ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram "$out/bin/zotero" --set GTK_THEME "Adwaita:light"
      '';
    })
    solaar
    headsetcontrol
    home-assistant-cli
    luakit
    manix
    nix-tree
    nx-libs
    nix-output-monitor
  ];
}
