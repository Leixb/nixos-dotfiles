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
  programs.taskwarrior = {
    enable = true;
    package = taskwarrior;
    config = {
      report.next.filter = "status:pending -WAITING limit:10";

      # Inbox report, where
      default.project = "inbox";
      report.inbox.filter = "project:inbox status:pending";
      report.inbox.description = "Tasks pending classification";
      report.inbox.columns = "id,start.age,entry.age,depends.indicator,priority,project,tags,recur.indicator,scheduled.countdown,due,until.remaining,description.count,urgency";
      urgency.user.project.inbox.coefficient = 2;

      # My contexts
      context.dotfiles.read = "project:dotfiles";
      context.dotfiles.write = "project:dotfiles";
      context.jobs.read = "project:Jobs";
      context.jobs.write = "project:Jobs";
      context.work.read = "+work";
      context.work.write = "+work";
      context.web.read = "+web";
      context.web.write = "+web";

      # Custom colors
      color.tag.bug = "bold white on color52";
      color.tag.doc = "color14";
      color.tag.test = "black on yellow";
      color.calendar.due.today = "black on rgb300";
      color.error = "rgb555 on rgb500";

      urgency.user.tag.bug.coefficient = 5;
      urgency.user.tag.test.coefficient = 2;
      urgency.user.tag.optional.coefficient = -6;

      # tasksh review configuration
      uda.reviewed.type = "date";
      uda.reviewed.label = "Reviewed";
      report._reviewed.description = "Tasksh review report."; # Adjust the filter to your needs.
      report._reviewed.columns = "uuid";
      report._reviewed.sort = "reviewed+,modified+";
      report._reviewed.filter = "( reviewed.none: or reviewed.before:now-6days ) and ( +PENDING or +WAITING )";
    };
    extraConfig = ''
      context=$TW_CONTEXT
    '';
  };

  xdg.dataFile."task/hooks/on-modify.timewarrior" = {
    executable = true;
    source = "${pkgs.timewarrior}/share/doc/timew/ext/on-modify.timewarrior";
  };

  home.packages = with pkgs; [
    timewarrior
    vit
    tasksh
  ];
}
