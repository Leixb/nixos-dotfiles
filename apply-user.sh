#!/bin/sh

pushd ~/.dotfiles
nix build .#homeManagerConfigurations.will.activationPackage
./result/activate
popd
