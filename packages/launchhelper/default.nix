{ lib
, stdenv
, fetchFromGitHub
, python39
}:

stdenv.mkDerivation rec {
  pname = "launchhelper";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "CakeTheLiar";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-J7Mf1sAgPkJkjQbP6dD2aXsa0P8pte65I25KcJCMvrg=";
  };

  buildInputs = [(python39.withPackages (pythonPackages: with pythonPackages; [
    psutil
  ]))];

  doCheck = false;

  installPhase = ''
  mkdir -p $out/bin
    cp launchhelper2.py $out/bin/launchelper2
    cp injector.py $out/bin/injector.py

    chmod +x $out/bin/launchelper2
  '';

  meta.description = "League of Legends launcher helper for linux";
}
