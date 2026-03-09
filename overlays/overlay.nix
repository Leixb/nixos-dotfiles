final: prev:
let
  lib = prev.lib;
in
{
  wrapGTKTheme =
    theme: package:
    final.symlinkJoin {
      name = "${package.name}-${theme}";
      paths = [ package ];
      nativeBuildInputs = [ final.makeWrapper ];
      postBuild =
        let
          binPath = lib.removePrefix (builtins.toString (lib.getBin package)) (lib.getExe package);
        in
        ''
          wrapProgram "$out${binPath}" --set GTK_THEME "${theme}"
        '';
    };

  vimPlugins = prev.vimPlugins // {
    fzf-lua = prev.vimPlugins.fzf-lua.overrideAttrs (oldAttrs: {
      doCheck = false;
    });
  };

  picom12 = prev.picom.overrideAttrs {
    version = "12.5";
    src = final.fetchFromGitHub {
      owner = "yshui";
      repo = "picom";
      tag = "v12.5";
      hash = "sha256-H8IbzzrzF1c63MXbw5mqoll3H+vgcSVpijrlSDNkc+o=";
      fetchSubmodules = true;
    };
  };

  nix-output-monitor = prev.nix-output-monitor.overrideAttrs {
    patches = [
      (final.fetchpatch {
        # fix ssh-ng:// build attribution
        url = "https://code.maralorn.de/maralorn/nix-output-monitor/commit/10a3cbcb0bdea960e7670e82ca5ee8abf37b9b5d.patch";
        sha256 = "sha256-Jpp4RRgcuX40KU+1Xtwe47NJ8KXEzPjCQ/+e1sSDSdA=";
      })
    ];
  };
}
