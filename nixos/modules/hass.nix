{ config, pkgs, ... }:

{
  sops.secrets.hass_env.sopsFile = ../secrets/hass.yaml;

  systemd.services = {
    hass-online = {
      enable = true;
      unitConfig.Description = "Notify Home Assistant of boot completion";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      script = ''
        ${pkgs.home-assistant-cli}/bin/hass-cli event fire nixos.online --json '{ "hostname": "${config.networking.hostName}"}'
      '';

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        EnvironmentFile = config.sops.secrets.hass_env.path;
        SupplementaryGroups = [ config.users.groups.keys.name ];
        ExecStop = pkgs.writeShellScript "hass-offline" ''
          UPTIME="$(cut -d' ' -f1 /proc/uptime)"
          IDLETIME="$(cut -d' ' -f2 /proc/uptime)"
          NPROC="$(nproc --all)"
          ${pkgs.home-assistant-cli}/bin/hass-cli event fire nixos.shutdown --json "{ \"hostname\": \"${config.networking.hostName}\", \"cores\": $NPROC, \"uptime\": $UPTIME, \"idletime\": $IDLETIME }"
        '';
      };
    };
  };

}
