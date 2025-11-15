{ self, inputs, ... }:
{
  imports = [
    inputs.sops-nix.nixosModules.sops

    ./common/audio.nix
    ./common/bluetooth.nix
    ./common/boot.nix
    ./common/desktop-services.nix
    ./common/docs.nix
    ./common/firmware.nix
    ./common/fonts.nix
    ./common/graphics.nix
    ./common/headset.nix
    ./common/home-manager.nix
    ./common/hut-substituter.nix
    ./common/locale.nix
    ./common/lock.nix
    ./common/networking.nix
    ./common/nix.nix
    ./common/overlays.nix
    ./common/packages.nix
    ./common/performance.nix
    ./common/printing.nix
    ./common/security.nix
    ./common/sshd.nix
    ./common/systemd.nix
    ./common/users.nix
    ./common/zram.nix
  ];

  system.configurationRevision = self.rev or "dirty";
}
