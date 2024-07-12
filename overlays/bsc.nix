final: prev:
let
  paraverVersion = "4.11.4";
in
# assert (final.lib.strings.compareVersions paraverVersion prev.paraver.version) != 1; # once this fails, remove src overrides
{
  paraverKernel = prev.paraverKernel.overrideAttrs (oldAttrs: {
    version = paraverVersion;
    src = final.fetchFromGitHub {
      owner = "bsc-performance-tools";
      repo = "paraver-kernel";
      rev = "v${paraverVersion}";
      sha256 = "sha256-1LiEyF2pBkSa4hf3hAz51wBMXsXYpNqHgIeYH1OHE9M=";
    };
  });

  paraver = prev.wxparaver.overrideAttrs (oldAttrs: {
    version = paraverVersion;

    src = final.fetchFromGitHub {
      owner = "bsc-performance-tools";
      repo = "wxparaver";
      rev = "v${paraverVersion}";
      sha256 = "sha256-0bsFnDnPwOa/dzSKqPJ91Zw23NYWTs0GcC6tv3WQqMs=";
    };

    patches = [
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

  wxparaver-adwaita = final.wrapGTKTheme "Adwaita:dark" final.paraver;
}
