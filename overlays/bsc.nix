final: prev:
{
  paraver = prev.wxparaver.overrideAttrs (oldAttrs: {
    patches = (final.lib.optional (oldAttrs ? patches) oldAttrs.patches) ++ [
      (final.fetchurl {
        url = "https://patch-diff.githubusercontent.com/raw/bsc-performance-tools/wxparaver/pull/14.patch";
        sha256 = "sha256-jJ/LTBxlsRfYvv4MFmXz/zMtPgP4piVUClf0Nxpg+Bk=";
      })
    ];
    postInstall = oldAttrs.postInstall + ''
      install -Dm0644 icons/paraver.svg $out/share/icons/hicolor/scalable/apps/paraver.svg
      install -Dm0644 paraver.desktop $out/share/applications/paraver.desktop
    '';
    meta.mainProgram = "wxparaver";
  });

  wxparaver-adwaita = final.wrapGTKTheme "Adwaita:dark" final.paraver;

  papercut-adwaita = final.wrapGTKTheme "Adwaita:light" final.papercut;
}
