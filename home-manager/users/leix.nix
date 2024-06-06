{ lib, pkgs, config, osConfig, ... }: {
  home.username = osConfig.users.users.leix.name;

  imports = [ ../modules/upc.nix ../modules/taskwarrior.nix ../modules/mime-apps.nix ];

  home.packages = with pkgs; [
    jutge
    miniupnpc
    (mcaselector.overrideAttrs (oldAttrs: {
      nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs.wrapGAppsHook ];
    }))
    plexamp
    tdesktop
    element-desktop
    beekeeper-studio
    zotero7
    solaar
    headsetcontrol
    home-assistant-cli
    luakit
    manix
    nix-tree
    nx-libs
    nix-output-monitor # nom
    picard
    nicotine-plus
    logseq
  ];
}
