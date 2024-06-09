# vim: sw=2 ts=2:
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    armcord # discord client
    calibre # ebook manager
    gamescope # game window capture
    josm # OpenStreetMap Java editor
  ];
}
