final: prev:
let
  packages = ../packages;
  lib = prev.lib;
  isDir = (_: v: v == "directory");
in
lib.pipe packages [
  builtins.readDir
  (lib.filterAttrs isDir)
  builtins.attrNames
  (lib.flip lib.genAttrs (name:
    prev.callPackage (packages + "/${name}") { }))
]
