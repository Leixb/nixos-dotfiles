{
  imports = [
    ../modules/awesomewm.nix
    ../modules/gaming.nix
    ../modules/home.nix
    ../modules/sway.nix
  ];

  home-manager.users.marc = import ./home-manager/users/marc.nix;

  home.stateVersion = "23.05";
}
