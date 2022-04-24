{
  config,
  lib,
  pkgs,
  system,
  inputs,
  ...
}: let
  HOME = "/home/leix";

  legendary = pkgs.writers.writeBashBin "legendary" ''
    ${pkgs.steam-run}/bin/steam-run ${pkgs.legendary-gl}/bin/legendary "$@"
  '';
in {
  xdg.configFile."legendary/config.ini" = {
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
        proton-conf = {
          name,
          alias ? name,
        }:
          (
            if name != alias
            then set-alias name alias
            else {}
          )
          // {
            ${name} = {
              wrapper = "\"${steam_folder}/steamapps/common/${proton_version}/proton\" run";
              no_wine = true;
            };

            "${name}.env" = {
              STEAM_COMPAT_DATA_PATH = "${game_folder}/.proton_data/${alias}";
              STEAM_COMPAT_CLIENT_INSTALL_PATH = "${steam_folder}";
            };
          };
      in
        builtins.foldl' lib.recursiveUpdate
        {
          Legendary = {
            disable_update_check = true;
            disable_update_notice = true;
            install_dir = "${game_folder}";
          };
        }
        [
          (proton-conf {
            name = "d6264d56f5ba434e91d4b0a0b056c83a";
            alias = "TombRaider";
          })
          (proton-conf {
            name = "f7cc1c999ac146f39b356f53e3489514";
            alias = "RiseoftheTombRaider";
          })
          (proton-conf {
            name = "890d9cf396d04922a1559333df419fed";
            alias = "ShadowoftheTombRaider";
          })
        ]
    );
  };

  home.file.".launchhelper".source = pkgs.launchhelper + "/bin";

  home.packages = with pkgs; [
    lutris
    legendary
    minecraft
  ];
}
