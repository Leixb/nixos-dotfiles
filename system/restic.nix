{ config, ... }:

let
  user = config.users.users.leix;
in
{
  sops.secrets.restic_password = {
    sopsFile = ./secrets/restic.yaml;
    owner = user.name;
  };
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  systemd.services.restic-backups-localbackup = {
    serviceConfig.SupplementaryGroups = [ config.users.groups.keys.name ];
  };

  services.restic.backups = {
    localbackup = {
      user = user.name;
      initialize = true;
      passwordFile = config.sops.secrets.restic_password.path;
      paths = map (x: "${user.home}/${x}") [
        "Documents"
        "Pictures"
        "Videos"
        ".config"
      ];
      repository = "/mnt/data/backups/restic";
      timerConfig = { OnCalendar = "weekly"; };
    };
  };
}
