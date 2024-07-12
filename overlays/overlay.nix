final: prev:
{
  wrapGTKTheme = theme: package: final.symlinkJoin {
    name = "${package.name}-${theme}";
    paths = [ package ];
    nativeBuildInputs = [ final.makeWrapper ];
    postBuild = ''
      wrapProgram "${final.lib.getExe package}" --set GTK_THEME "${theme}"
    '';
  };
}
