{ config, ... }: {
  sops.secrets.restic_password.sopsFile = ./secrets/restic.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  systemd.services.restic-backups-localbackup = {
    serviceConfig.SupplementaryGroups = [ config.users.groups.keys.name ];
  };

  services.restic.backups = {
    localbackup = {
      initialize = true;
      user = "leix";
      passwordFile = config.sops.secrets.restic_password.path;
      paths = [ "/home/leix" ];
      repository = "/mnt/data/backups/restic";
      timerConfig = { OnCalendar = "weekly"; };
    };
  };
}
