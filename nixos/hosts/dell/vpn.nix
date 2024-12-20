{ config, lib, pkgs, ... }:
{
  sops.secrets.openfortivpn_config = {
    sopsFile = ./secrets_work/vpn.yaml;
    owner = "root";
  };

  systemd.services.openfortivpn = {
    enable = true;
    description = "OpenFortiVPN client";
    documentation = [ "https://github.com/adrienverge/openfortivpn" ];

    after = [ "network-online.target" ];
    wants = [ "network-online.target" "systemd-networkd-wait-online.service" ];
    wantedBy = lib.mkForce [ ];

    serviceConfig = {
      Type = "notify";
      PrivateTmp = true;
      ExecStart = "${lib.getExe pkgs.openfortivpn} -c ${config.sops.secrets.openfortivpn_config.path}";
      Restart = "on-failure";
      OOMScoreAdjust = -100;
      User = "root";
      Group = "root";
    };
  };
}
