{ config, ... }:
{
  sops.secrets.gitlab_hydra = {
    sopsFile = ../secrets/bsc.yaml;
    owner = config.users.users.hydra.name;
    group = config.users.users.hydra.group;
    mode = "0440";
  };

  services.hydra = {
    enable = true;
    hydraURL = "http://localhost:3000"; # externally visible URL
    listenHost = "localhost";
    notificationSender = "hydra@localhost"; # e-mail of Hydra service
    # a standalone Hydra will require you to unset the buildMachinesFiles list to avoid using a nonexistant /etc/nix/machines
    buildMachinesFiles = [ ];
    # you will probably also want, otherwise *everything* will be built from scratch
    useSubstitutes = true;
    extraConfig = ''
      Include ${config.sops.secrets.gitlab_hydra.path}
    '';
  };

  nix.settings.extra-allowed-uris = [
    "git+ssh://git@bscpm04.bsc.es"
    "git+ssh://git@gitlab-internal.bsc.es"
  ];
}
