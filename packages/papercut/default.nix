{
  fetchurl,
  stdenv,
  lib,
  jre,
  papercut_config ? {
    name = "print.bsc.es";
    ip = "192.168.3.109";
    port = "9191";
  },
}:

let
  version = "25.0.6.74685";
in
stdenv.mkDerivation {
  pname = "papercut";
  inherit version;

  src = fetchurl {
    url = "https://cdn.papercut.com/web/products/ng-mf/installers/ng/25.x/pcng-setup-${version}.sh";
    hash = "sha256-oOYEqtxnSohAOwnHg++AtsBlnGlC49r9Zx47oWKA9HQ=";
  };

  unpackPhase = ''
    runHook preUnpack

    dd if="$src" bs=4096 skip=1 | gunzip | tar x

    runHook postUnpack
  '';

  prePatch = ''
    sed -i 's#^JAVACMD=$#JAVACMD=${lib.getExe jre}#' papercut/client/linux/pc-client-linux.sh
    sed -i 's#lib/\*.jar#${placeholder "out"}/&#' papercut/client/linux/pc-client-linux.sh
  '';

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp papercut/client/linux/pc-client-linux.sh $out/bin/pc-client
    chmod +x $out/bin/pc-client

    cp -r papercut/client/win/lib $out/
    rm $out/lib/*.dll

    cat << EOF > "$out/bin/config.properties"
    server-name=${papercut_config.name}
    server-ip=${papercut_config.ip}
    server-port=${papercut_config.port}
    EOF

    runHook postInstall
  '';

  propagatedBuildInputs = [
    jre
  ];

  meta = {
    description = "Client software for PaperCut printers";
    homepage = "https://www.papercut.com";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ leixb ];
    mainProgram = "pc-client";
  };
}
