{ lib
, stdenv
, fetchurl
, python3
}:

stdenv.mkDerivation rec {
  pname = "eduroam";
  version = "2.0.4";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/GEANT/CAT/v${version}/devices/linux/Files/main.py";
    sha256 = "sha256-3BM7N932pv2HuU+1gqKVwNW09tbCNrtq2A4K6coeeXA=";
  };

  buildInputs = [ (python3.withPackages (pythonPackages: with pythonPackages; [
    distro
    dbus-python
    pyopenssl
  ])) ];

  unpackPhase = ''
    runHook preUnpack

    install -Dm0555 $src eduroam.py

    runHook postUnpack
  '';

  patches = [ ./UPC_cert.patch ];

  installPhase = ''
    runHook preInstall

    install -Dm0555 eduroam.py $out/bin/eduroam

    runHook postInstall
  '';

  meta.description = "Eduroam Configuration Assistant Tool (CAT) with UPC patches";
}
