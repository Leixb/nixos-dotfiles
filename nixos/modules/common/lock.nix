{ config, pkgs, ... }:
{
  sops.secrets.hass_env.sopsFile = ../../secrets/hass.yaml;

  programs.i3lock =
    let
      source_hass =
        if config.networking.hostName == "kuro" then ". ${config.sops.secrets.hass_env.path}" else "";
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
}
