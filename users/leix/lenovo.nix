{ config, lib, pkgs, system, inputs, ... }:

let

  theme = (import ./theme.nix);

  HOME = "/home/leix";

  legendary = pkgs.writers.writeBashBin "legendary" ''
    ${pkgs.steam-run}/bin/steam-run ${pkgs.legendary-gl}/bin/legendary "$@"
  '';

  switch-audio = pkgs.writers.writeBashBin "switch-audio" ''
    headset="alsa_output.usb-Logitech_G733_Gaming_Headset-00.iec958-stereo"
    speakers="alsa_output.pci-0000_00_1f.3.analog-stereo"

    pactl="${pkgs.pulseaudio}/bin/pactl"

    current="$($pactl info | grep 'Default Sink' | cut -d':' -f 2 | tr -d ' ')"

    if [[ "$current" == "$speakers" ]]; then
        echo -n "   headset"
        $pactl set-default-sink "$headset"
    elif [[ "$current" == "$headset" ]]; then
        echo -n " 蓼 speakers"
        $pactl set-default-sink "$speakers"
    else
        echo -n "Unknown sink: $current"
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
in {
  imports = [
    ./common.nix
    ./sway.nix
  ];

  xdg.configFile = {

      "awesome".source = pkgs.awesome-config;

      "legendary/config.ini" = {
        text = lib.generators.toINI {} (
          let
            # location to install the games
            game_folder = "${HOME}/Games";

            # Steam folder
            steam_folder = "${HOME}/.steam/steam";
            proton_version = "Proton - Experimental";

            # Define alias
            set-alias = name: alias: {
              "Legendary.aliases".${alias} = name;
            };

            # Configure game to use proton
            proton-conf = { name, alias ? name } :
              (if name != alias then set-alias name alias else {})
              // {
                ${name} = {
                  wrapper = "\"${steam_folder}/steamapps/common/${proton_version}/proton\" run";
                  no_wine = true;
                };

                "${name}.env" = {
                  STEAM_COMPAT_DATA_PATH = "${game_folder}/.proton_data/${alias}";
                  STEAM_COMPAT_CLIENT_INSTALL_PATH="${steam_folder}";
                };
              };
          in
          builtins.foldl' lib.recursiveUpdate {
            Legendary = {
              disable_update_check = true;
              disable_update_notice = true;
              install_dir = "${game_folder}";
            };
          }
          [
            (proton-conf { name = "d6264d56f5ba434e91d4b0a0b056c83a"; alias = "TombRaider"; })
            (proton-conf { name = "f7cc1c999ac146f39b356f53e3489514"; alias = "RiseoftheTombRaider"; })
            (proton-conf { name = "890d9cf396d04922a1559333df419fed"; alias = "ShadowoftheTombRaider"; })
          ]
        );
      };
    };

  home.file.".launchhelper".source = pkgs.launchhelper + "/bin";

  home.packages = with pkgs; [
    lutris
    legendary
    i3lock-fancy-rapid
    switch-audio 
    open-arch-home
    close-arch-home
    geogebra
  ];
  services = {
    picom = {
      enable = true;
      backend = "glx";
      experimentalBackends = true;
      vSync = true;
      extraOptions = ''
        unredir-if-possible = true;
        use-damage = true;
        detect-transient = true;
        detect-client-leader = true;
        xrender-sync-fence = true;
      '';
    };

    mpd = {
      enable = true;
      musicDirectory = "nfs://192.168.1.3/volume1/music";
      extraConfig = ''
        audio_output {
          type            "pipewire"
          name            "PipeWire Sound Server"
        }
      '';
    };

    udiskie.enable = true;

    unclutter.enable = true;
  };

  programs.ncmpcpp = {
    enable = true;
    mpdMusicDir = "${HOME}/Music";
  };

  programs.rofi = {
    enable = true;
    font = "${theme.font} ${theme.font_size}";
    extraConfig = {
	    modi = "combi,drun,window";
      show-icons = true;
      cycle = false;
      combi-modi = "window,drun";
	    combi-hide-mode-prefix = true;
      display-combi = "";
    };
    theme = "~/.config/rofi/theme.rasi";
    # theme = builtins.toFile "theme.rasi" (''
      # * {
          # background: #0b0606;
          # foreground: #fbffff;
          # active-background: #6B4F4F;
          # urgent-background: #9D5045;
          # selected-urgent-background: #CA8D75;

    # '' + builtins.readFile ./rofi_theme.rasi);
  };

  xsession = {
    enable = true;

    numlock.enable = true;

    pointerCursor = {
      package = pkgs.capitaine-cursors;
      name = "capitaine-cursors";
      size = 32;
    };

    windowManager.awesome = {
      enable = true;
      luaModules = with pkgs; [ lain ];
      package = pkgs.awesome;
    };

  };

  xresources.extraConfig = ''
  ! ${theme.name}

  *.background: ${theme.background}
  *.foreground: ${theme.foreground}

  !black
  *color0: ${theme.color0}
  *color8: ${theme.color8}

  !red
  *color1: ${theme.color1}
  *color9: ${theme.color9}

  !green
  *color2: ${theme.color2}
  *color10: ${theme.color10}

  !yellow
  *color3: ${theme.color3}
  *color11: ${theme.color11}

  !blue
  *color12: ${theme.color12}
  *color4: ${theme.color4}

  !magenta
  *color5: ${theme.color5}
  *color13: ${theme.color13}

  !cyan
  *color6: ${theme.color6}
  *color14: ${theme.color14}

  !white
  *color7: ${theme.color7}
  *color15: ${theme.color15}
  '';

}
