{ lib
, fetchurl
, runCommand
, symlinkJoin
, modpack ? null
, extra_mods ? [ ]
}:
let
  modrinth_index = builtins.fromJSON (builtins.readFile "${modpack}/modrinth.index.json");

  files = builtins.filter (file: !(file ? env) || file.env.server != "unsupported") modrinth_index.files;

  downloads = builtins.map
    (file:
      fetchurl {
        urls = file.downloads;
        inherit (file.hashes) sha512;
      }
    )
    files;

  paths = builtins.map (builtins.getAttr "path") files;

  derivations = lib.zipListsWith
    (path: download:
      let
        folder_name = builtins.match "(.*)/(.*$)" path;
        folder = builtins.head folder_name;
        name = builtins.head (builtins.tail folder_name);
      in
      runCommand name { } ''
        mkdir -p "$out/${folder}"
        cp ${download} "$out/${path}"
      ''
    )
    paths
    downloads;

in
symlinkJoin {
  inherit (modrinth_index) name;
  paths = derivations ++ [ "${modpack}/overrides" ] ++ extra_mods;
}
