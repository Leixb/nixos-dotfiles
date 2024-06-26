{ lib, pkgs, config, osConfig, ... }: {
  home.username = osConfig.users.users.leix.name;

  imports = [ ../modules/taskwarrior.nix ../modules/mime-apps.nix ];

  home.packages = with pkgs; [
    miniupnpc
    # beekeeper-studio
    zotero7
    solaar
    luakit
    manix
    nix-tree
    nx-libs
    nix-output-monitor # nom
    steam-run
  ];
}
