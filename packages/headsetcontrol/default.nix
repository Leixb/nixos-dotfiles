{ stdenv
, lib
, fetchFromGitHub
, cmake
, hidapi
}:

stdenv.mkDerivation rec {
  pname = "headsetcontrol";
  version = "2.6";

  src = fetchFromGitHub {
    owner = "Sapd";
    repo = "HeadsetControl";
    rev = version;
    sha256 = "0a7zimzi71416pmn6z0l1dn1c2x8p702hkd0k6da9rsznff85a88";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    hidapi
  ];

  configurePhase = ''
    cmake -B "build" .
  '';

  buildPhase = ''
    make -C "build"
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp build/headsetcontrol $out/bin

    ${
      if stdenv.isLinux then ''
        mkdir -p $out/lib/udev/rules.d
        cp build/70-headsets.rules $out/lib/udev/rules.d
    '' else ""
    }
  '';

  /*
  Test depends on having the apropiate headsets connected.
  */
  doCheck = false;

  meta = with lib; {
    description = "Sidetone and Battery status for Logitech G930, G533, G633, G933 SteelSeries Arctis 7/PRO 2019 and Corsair VOID (Pro)";
    longDescription = ''
      A tool to control certain aspects of USB-connected headsets on Linux. Currently,
      support is provided for adjusting sidetone, getting battery state, controlling
      LEDs, and setting the inactive time.
    '';
    homepage = "https://github.com/Sapd/HeadsetControl";
    license = licenses.gpl3;
    maintainers = with maintainers; [ leixb ];
    platforms = platforms.all;
  };
}
