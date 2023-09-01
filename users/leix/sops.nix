{ config, osConfig, lib, pkgs, system, inputs, ... }:

{
  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  sops.defaultSopsFile = ../secrets/secrets.yaml;
}
