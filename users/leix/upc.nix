{ config, lib, pkgs, osConfig, sops, system, inputs, ... }:
let
  dbeaver-adawaita = pkgs.symlinkJoin {
    name = "dbeaver";
    paths = [ pkgs.dbeaver ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/dbeaver" --set GTK_THEME "Adwaita:light"
    '';
  };
in
{
  home.file.".gof5/config.yaml".text = /* yaml */ ''
    dns:
    - .upc.edu.
    - .upc.

    routes:
    - 10.0.0.0/8
    - 147.83.0.0/16
  '';

  sops.secrets.upc_vpn_username.path = "${config.xdg.stateHome}/.gof5_user";

  home.packages =
    let
      user = config.sops.secrets.upc_vpn_username.path;
      vpn-connect = pkgs.writeShellScriptBin "vpn-connect" ''
        USER="$(cat '${user}')"
        sudo ${pkgs.gof5}/bin/gof5 -server https://upclink.upc.edu -username "$USER" "$@"
      '';
    in
    [
      vpn-connect
      pkgs.eduroam
    ];

  gtk.gtk3.bookmarks = [ "file://${config.home.homeDirectory}/Documents/UPC" ];

  programs.firefox.profiles.leix.bookmarks = [

    {
      name = "UPC";
      bookmarks = [
        {
          name = "Raco";
          url = "https://raco.fib.upc.edu";
        }
        {
          name = "Atenea";
          url = "https://atenea.upc.edu";
        }
        {
          name = "Jutge";
          url = "https://jutge.org";
        }
        {
          name = "Discos";
          url = "https://discos.fib.upc.edu";
        }
        {
          name = "LearnSQL";
          url = "https://learnsql2.fib.upc.edu";
        }
        {
          name = "CCBDA";
          url = "https://ccbda-upc.github.io";
        }
      ];
    }
  ];

}
