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

in
{
  imports = [
    ../modules/gaming.nix
    ../modules/xmonad.nix
    ../modules/mpd.nix
    ../modules/personal_git.nix
  ];

  home.packages = with pkgs; [
    switch-audio
    geogebra6
    obs-studio
    kdenlive
    ungoogled-chromium

    wxparaver-adwaita
  ];

  home.stateVersion = "21.11";
}
