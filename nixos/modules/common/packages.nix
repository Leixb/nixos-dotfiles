{ pkgs, ... }:
{
  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    cntr
    vim
    wget
    openssl
  ];
}
