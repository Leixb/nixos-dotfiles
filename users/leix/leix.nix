{ osConfig, ... }:
{
  import = [ ./home.nix ];
  home.username = osConfig.users.users.leix.name;
}
