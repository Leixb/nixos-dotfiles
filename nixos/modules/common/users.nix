{ pkgs, ... }:
{
  users.users.leix = {
    description = "Aleix";
    uid = 1000;
    isNormalUser = true;
    extraGroups = [
      "wheel" # Enable 'sudo' for the user.
      "networkmanager"
      "libvirtd"
      "audio"
      "video"
      "input"
    ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP01irZGcIE6n5svXRpAqFNgdRl15cum7vEV1go9qvI5 JuiceSSH"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPWmQFG8ogdMgYH0Ldi4gJK/PWBQBfnTXMwtqq4cHBCp leix@kuro"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMz6YAvxivW35ndT4rH8jBBTHYSaCW/mn2y7+pOnIuq+ leix@pavilion"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILbUye0Ne66GM3CYtEAvAqOKd5+fyuxCVaq5ebtCgT62 leix@asus"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIIFiqXqt88VuUfyANkZyLJNiuroIITaGlOOTMhVDKjf abonerib@bsc-84885016"
    ];
  };

  home-manager.users.leix = import ../../../home-manager/users/leix.nix;
}
