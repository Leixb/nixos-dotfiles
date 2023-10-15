{ pkgs, ... }:
let
  switch-audio = pkgs.writers.writeBashBin "switch-audio" ''
    headset="alsa_output.usb-Logitech_G733_Gaming_Headset-00.iec958-stereo"
    speakers="alsa_output.pci-0000_00_1f.3.analog-stereo"

    pactl="${pkgs.pulseaudio}/bin/pactl"

    current="$($pactl info | grep 'Default Sink' | cut -d':' -f 2 | tr -d ' ')"

    if [[ "$current" == "$speakers" ]]; then
        echo " 󰋎 headset"
        $pactl set-default-sink "$headset"
    elif [[ "$current" == "$headset" ]]; then
        echo " 󰓃 speakers"
        $pactl set-default-sink "$speakers"
    else
        echo "Unknown sink: $current"
    fi
  '';

  open-arch-home = pkgs.writers.writeBashBin "open-arch-home" ''
    set -e
    ${pkgs.coreutils}/bin/mkdir -p /tmp/mnt

    sudo ${pkgs.util-linux}/bin/mount /dev/sda2 /tmp/mnt
    sudo ${pkgs.util-linux}/bin/losetup /dev/loop7 -P /tmp/mnt/leix.home
    sudo ${pkgs.cryptsetup}/bin/cryptsetup open /dev/loop7p1 leix
    sudo ${pkgs.util-linux}/bin/mount /dev/mapper/leix /tmp/mnt/leix
  '';

  close-arch-home = pkgs.writers.writeBashBin "close-arch-home" ''
    set -e

    sudo ${pkgs.util-linux}/bin/umount /dev/mapper/leix
    sudo ${pkgs.cryptsetup}/bin/cryptsetup close leix
    sudo ${pkgs.util-linux}/bin/losetup -d /dev/loop7
    sudo ${pkgs.util-linux}/bin/umount /dev/sda2
  '';
in
{
  imports = [ ../modules/sway.nix ../modules/gaming.nix ../modules/xmonad.nix ../modules/mpd.nix ../modules/autorandr.nix ];

  home.packages = with pkgs; [
    switch-audio
    open-arch-home
    hyprland-nvidia
    close-arch-home
    geogebra
    obs-studio
    kdenlive
    # matlab
    ungoogled-chromium
  ];

  home.stateVersion = "21.11";
}
