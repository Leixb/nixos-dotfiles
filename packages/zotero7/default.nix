{ lib
, stdenv
, fetchurl
, wrapGAppsHook
, makeDesktopItem
, alsa-lib
, libXext
, libXtst
, gtk2-x11
, atk
, cairo
, coreutils
, curl
, cups
, dbus-glib
, dbus
, dconf
, fontconfig
, freetype
, gdk-pixbuf
, glib
, glibc
, gtk3
, libX11
, libXScrnSaver
, libxcb
, libXcomposite
, libXcursor
, libXdamage
, libXfixes
, libXi
, libXinerama
, libXrender
, libXt
, libnotify
, adwaita-icon-theme
, libGLU
, libGL
, nspr
, nss
, pango
, gsettings-desktop-schemas
, autoPatchelfHook
}:

stdenv.mkDerivation rec {
  pname = "zotero";
  version = "7.0.0-beta.83";

  src = fetchurl {
    url = "https://download.zotero.org/client/beta/7.0.0-beta.83%2B066eda731/Zotero-7.0.0-beta.83%2B066eda731_linux-x86_64.tar.bz2";
    sha256 = "sha256-wqew12/Icv4XS+IJRVcf1Rh/ipqBhe8QGkP8ErfS4J0=";
  };

  nativeBuildInputs = [
    wrapGAppsHook
    autoPatchelfHook
  ];

  dontConfigure = true;
  dontBuild = true;
  # dontStrip = true;
  # dontPatchELF = true;

  buildInputs = [
    gsettings-desktop-schemas
    glib
    gtk3
    adwaita-icon-theme
    dconf
    atk
    cairo
    curl
    cups
    alsa-lib
    gtk2-x11
    libXtst
    dbus-glib
    dbus
    fontconfig
    freetype
    gdk-pixbuf
    glib
    glibc
    gtk3
    libX11
    libXScrnSaver
    libXcomposite
    libXcursor
    libxcb
    libXdamage
    libXext
    libXfixes
    libXi
    libXinerama
    libXrender
    libXt
    libnotify
    libGLU
    libGL
    nspr
    nss
    pango
  ];

  desktopItem = makeDesktopItem {
    name = "zotero-${version}";
    exec = "env GTK_THEME=adwaita zotero7 -url %U";
    icon = "zotero";
    comment = meta.description;
    desktopName = "Zotero 7";
    genericName = "Reference Management";
    categories = [ "Office" "Database" ];
    startupNotify = true;
    mimeTypes = [ "x-scheme-handler/zotero" "text/plain" ];
  };

  installPhase = ''
    runHook preInstall

    mkdir -p "$prefix/usr/lib/zotero-bin-${version}"
    cp -r * "$prefix/usr/lib/zotero-bin-${version}"

    mkdir -p "$out/bin"
    ln -s "$prefix/usr/lib/zotero-bin-${version}/zotero" "$out/bin/zotero7"

    # install desktop file and icons.
    mkdir -p $out/share/applications
    cp ${desktopItem}/share/applications/* $out/share/applications/
    for size in 32 64 128; do
      install -Dm444 icons/icon$size.png \
        $out/share/icons/hicolor/''${size}x''${size}/apps/zotero.png
    done

    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${lib.makeBinPath [ coreutils ]}
    )
  '';

  meta = with lib; {
    homepage = "https://www.zotero.org";
    description = "Collect, organize, cite, and share your research sources";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.agpl3Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ i077 ];
  };
}
