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
    runHook preInstall

    install -Dm0555 launchhelper2.py $out/bin/launchelper2
    install -Dm0444 injector.py $out/bin/injector.py

    runHook postInstall
  '';

  meta.description = "League of Legends launcher helper for linux";
}
