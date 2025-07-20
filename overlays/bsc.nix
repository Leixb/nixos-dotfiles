final: prev:
let
  paraverVersion = "4.12.0";
in
# assert (final.lib.strings.compareVersions paraverVersion prev.paraver.version) != 1; # once this fails, remove src overrides
{
  paraverKernel = prev.paraverKernel.overrideAttrs (oldAttrs: {
    version = paraverVersion;
    buildInputs = oldAttrs.buildInputs ++ [ final.zlib final.libxml2 ];
    # TODO: merge with oldAttrs.patches
    patches = [
      ./paraver-dont-expand-colors.patch
      ./paraver-fix-libxml2.patch
    ];
    src = final.fetchFromGitHub {
      owner = "bsc-performance-tools";
      repo = "paraver-kernel";
      rev = "v${paraverVersion}";
      sha256 = "sha256-Xs7g8ITZhPt00v7o2WlTddbou8C8Rc9kBMFpl2WsCS4=";
    };
  });

  paraver = (prev.wxparaver.override { boost = final.boost186; }).overrideAttrs (oldAttrs: {
    version = paraverVersion;

    src = final.fetchFromGitHub {
      owner = "bsc-performance-tools";
      repo = "wxparaver";
      rev = "v${paraverVersion}";
      sha256 = "sha256-YsO5gsuEFQdki3lQudEqgo5WXOt/fPdvNw5OxZQ86Zo=";
    };

    patches = (final.lib.optional (oldAttrs ? patches) oldAttrs.patches) ++ [
      (final.fetchurl {
        url = "https://patch-diff.githubusercontent.com/raw/bsc-performance-tools/wxparaver/pull/14.patch";
        sha256 = "sha256-jJ/LTBxlsRfYvv4MFmXz/zMtPgP4piVUClf0Nxpg+Bk=";
      })
      ./paraver-fix-do-not-set-focus-on-redraw.patch
    ];
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ final.installShellFiles ];
    postInstall = oldAttrs.postInstall + ''
      install -Dm0644 icons/paraver.svg $out/share/icons/hicolor/scalable/apps/paraver.svg
      install -Dm0644 paraver.desktop $out/share/applications/paraver.desktop

      installManPage $out/share/doc/wxparaver_help_contents/man/*
    '';

    meta.mainProgram = "wxparaver";
  });

  wxGTK30 = final.wxGTK32;

  wxparaver-adwaita = final.wrapGTKTheme "Adwaita:dark" final.paraver;
}
