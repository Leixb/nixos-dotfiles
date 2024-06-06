{ config, ... }:
{
  programs.git.userName = "LeixB";
  programs.git.includes = [{ path = config.sops.secrets.git_config.path; }];
  sops.secrets.git_config.path = "${config.xdg.configHome}/git/config.d/secret.inc";
}
