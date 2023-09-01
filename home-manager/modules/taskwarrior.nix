{ config, lib, pkgs, ... }:

let
  taskwarrior = pkgs.symlinkJoin {
    name = "taskwarrior-wrapped";
    paths = [ pkgs.taskwarrior ];
    nativeBuildInputs = [ pkgs.makeBinaryWrapper ];
    postBuild = ''
      wrapProgram $out/bin/task \
        --prefix PATH : ${pkgs.python3}/bin
    '';
  };

in
{
  # programs.taskwarrior = {
  #   enable = true;
  #   package = taskwarrior;
  # };
  xdg.dataFile."task/hooks/on-modify.timewarrior" = {
    executable = true;
    source = "${pkgs.timewarrior}/share/doc/timew/ext/on-modify.timewarrior";
  };

  home.packages = with pkgs; [
    taskwarrior
    timewarrior
    vit
    tasksh
  ];

  programs.starship.settings = {
    # format = lib.concatStrings [
    #   "$all"
    #   "$\{custom.tasks}"
    # ];
    custom.tasks = {
      command = "task status:pending count";
      symbol = "📝 ";
      style = "bold blue";
    };
  };
}
