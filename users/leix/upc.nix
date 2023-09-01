{ config, lib, pkgs, osConfig, sops, system, inputs, ... }:
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
}
