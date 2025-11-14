# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, self, pkgs, lib, inputs, ... }:
{

  imports = [
    ./common/audio.nix
    ./common/boot.nix
    ./common/fonts.nix
    ./common/locale.nix
    ./common/networking.nix
    ./common/nix.nix
    ./common/performance.nix
    ./common/printing.nix
    ./common/security.nix
    ./common/sshd.nix
    ./common/users.nix
    ./common/zram.nix
    ./common/packages.nix
    ./common/overlays.nix
    ./common/docs.nix
    ./common/home-manager.nix
    ./common/hut-substituter.nix
  ];

  services.fwupd.enable = true;

  services.acpid.enable = true;

  services.xserver.wacom.enable = true;

  services.gnome.gnome-keyring.enable = true;

  hardware.enableRedistributableFirmware = true;

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  programs.dconf.enable = true;
  programs.light.enable = true;

  programs.mtr.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  systemd.targets = {
    sleep.enable = true;
    suspend.enable = true;
    hibernate.enable = true;
    hybrid-sleep.enable = true;
  };

  services.systembus-notify.enable = true;

  services.udev.packages = with pkgs; [
    gnome-settings-daemon
    logitech-udev-rules
    headsetcontrol
  ];
  services.dbus.packages = with pkgs; [ gcr at-spi2-core ];

  # Mout MTP and other network shares
  services.gvfs.enable = true;

  # List services that you want to enable:

  xdg.portal.enable = true;

  # Put xserver log files in a proper location
  services.xserver.logFile = "/var/log/Xorg.0.log";

  sops.secrets.hass_env.sopsFile = ../secrets/hass.yaml;

  programs.i3lock =
    let
      source_hass = if config.networking.hostName == "kuro" then ". ${config.sops.secrets.hass_env.path}" else "";
    in
    {
      enable = true;
      package = pkgs.i3lock-fancy-rapid.override {
        i3lock = pkgs.writeShellScriptBin "i3lock" ''
          systemctl --user stop picom
          ${source_hass}

          ${pkgs.curl}/bin/curl --connect-timeout 5 -X POST \
          -H "Authorization: Bearer $HASS_TOKEN" \
          -H "Content-Type: application/json" \
          -d '{"hostname" : "${config.networking.hostName}"}' \
          $HASS_SERVER/api/events/nixos.lock &
          CURL_PID=$!

          ${pkgs.dunst}/bin/dunstctl set-paused true

          ${pkgs.i3lock-color}/bin/i3lock-color --nofork "$@"

          systemctl --user start picom
          ${pkgs.dunst}/bin/dunstctl set-paused false

          if ! kill $CURL_PID ; then
          ${pkgs.curl}/bin/curl --connect-timeout 5 -X POST \
          -H "Authorization: Bearer $HASS_TOKEN" \
          -H "Content-Type: application/json" \
          -d '{"hostname" : "${config.networking.hostName}"}' \
          $HASS_SERVER/api/events/nixos.unlock &
          fi
        '';
      };
    };

  system.configurationRevision = self.rev or "dirty";
}
