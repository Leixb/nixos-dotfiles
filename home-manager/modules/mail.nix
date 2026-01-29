{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.neomutt = {
    enable = true;
    editor = "nvim";
    sidebar.enable = true;
    sort = "reverse-threads";
    vimKeys = true;
    unmailboxes = true;
    binds = [
      { map = [ "index" "pager" ]; key = "\\`"; action = "modify-labels"; }
    ];
    macros = [
      { map = [ "index" "pager" ]; key = "\\cb"; action = "<enter-command>unset wait_key<enter><pipe-message>${lib.getExe pkgs.urlscan}<enter><enter-command>set wait_key<enter>"; } # follow urls
      { map = [ "index" "pager" ]; key = "\\ct"; action = "<modify-labels>!todo\\n"; } # Toggle todo
    ];
    extraConfig =
      let
        mailcap = pkgs.writeText "mailcap" ''
          text/html; ${lib.getExe pkgs.w3m} -I %{charset} -T text/html; copiousoutput; description=HTML Text; nametemplate=%s.html
          text/html; ${lib.getExe config.programs.firefox.package} %s; nametemplate=%s.html; needsterminal
          image/*; ${lib.getExe pkgs.timg} -g80x40 %s; needsterminal
        '';
      in
      ''
        auto_view text/html image/jpeg image/png image/gif
        alternative_order text/enriched text/plain text/html

        set mailcap_path = ${mailcap}

        set spoolfile = "notmuch://?query=tag:inbox"
        set record = ${config.accounts.email.maildirBasePath}/bsc/Sent
        set postponed = ${config.accounts.email.maildirBasePath}/bsc/Drafts
        set trash = ${config.accounts.email.maildirBasePath}/bsc/Trash

        set nm_unread_tag = unread
        set mail_check_stats = yes

        set pager_format = "-%Z- %C/%m: %-20.20n   %s%*  -- (%P) %g"
        set index_format = "%4C %Z %{%b %d} %-15.15L (%?l?%4l&%4c?) %s %g"

        source ${./neomutt.theme}
      '';
  };

  programs.mbsync.enable = true;
  services.mbsync = {
    enable = true;
    postExec = lib.optionalString config.programs.notmuch.enable ''
      ${lib.getExe pkgs.notmuch} new
    '';
  };

  programs.notmuch = {
    enable = true;
    new.tags = [ "new" ];
    hooks.postNew = lib.optionalString config.programs.afew.enable ''
      ${lib.getExe config.programs.afew.package} --tag --new
    '';
  };

  programs.afew = {
    enable = true;
    extraConfig = ''
      [SpamFilter]
      [KillThreadsFilter]
      [ListMailsFilter]

      [Filter.1]
      message = Vicenç
      query = from:vbeltran@bsc.es
      tags = +boss

      [Filter.2]
      message = Gitlab
      query = from:gitlab@gitlab.bsc.es
      tags = +gitlab

      [HeaderMatchingFilter.1]
      header = X-Mailer
      pattern = Gitea
      tags = +gitea

      [MailMover]
      folders = bsc/Inbox bsc/Trash bsc/Spam bsc/Archives
      rename = True
      max_age = 0

      bsc/Inbox = 'tag:archive':bsc/Archives 'tag:trash':bsc/Trash 'tag:spam':bsc/Spam
      bsc/Trash = 'NOT tag:trash':bsc/Inbox
      bsc/Spam = 'NOT tag:spam':bsc/Spam
      bsc/Archives = 'tag:inbox':bsc/Inbox

      # [FolderNameFilter]
      # folder_blacklist =
      # folder_transforms = bsc/Drafts:drafts bsc/Sent:sent bsc/Trash:trash
      # maildir_separator = /

      [ArchiveSentMailsFilter]

      [Filter.3]
      message = Remove inbox from sent mail explicitly
      query = tag:sent
      tags = -inbox;-new

      [Filter.4]
      message = Tag archived mail
      query = NOT tag:inbox AND NOT tag:sent AND NOT tag:drafts AND NOT tag:spam AND NOT tag:trash
      tags = +archive;-bsc/Inbox;-Inbox

      [Filter.5]
      message = Remove inbox tag from trash
      query = tag:trash
      tags = -inbox;-bsc/Inbox;-Inbox

      [InboxFilter]
    '';
  };

  sops.secrets.email_pass.path = "${config.xdg.configHome}/mail/sops";

  accounts.email.maildirBasePath = "Mail";

  accounts.email.accounts.bsc = {
    address = "abonerib@bsc.es";
    aliases = [ "aleix.boneribo@bsc.es" ];
    primary = true;
    userName = "abonerib";
    realName = "Aleix Boné";
    passwordCommand = "cat ${config.sops.secrets.email_pass.path}";

    imap = {
      host = "mail.bsc.es";
      port = 993;
      tls.enable = true;
    };

    smtp = {
      host = "mail.bsc.es";
      port = 465;
      tls.enable = true;
    };

    neomutt.enable = true;
    neomutt.mailboxType = "maildir";

    notmuch.enable = true;
    notmuch.neomutt = {
      enable = true;
      virtualMailboxes = [
        { name = "inbox"; query = "tag:inbox"; }
        { name = "unread"; query = "tag:unread"; }
        { name = "todo"; query = "tag:todo"; }
        { name = "flagged"; query = "tag:flagged"; }
        { name = "archive"; query = "tag:archive"; }
        { name = "all"; query = "NOT tag:trash"; }

        { name = "drafts"; query = "tag:drafts"; }
        { name = "sent"; query = "tag:sent"; type = "messages"; }

        { name = "spam"; query = "tag:spam"; }
        { name = "trash"; query = "tag:trash"; }

        { name = "lists"; query = "tag:lists"; }
        { name = " - BSC-CNS"; query = "tag:lists/bsc-cns"; }
        { name = " - DARE WP26"; query = "tag:lists/dare_sw_wp26"; }
        { name = " - Personal"; query = "tag:lists/personal"; }
        { name = " - STAR"; query = "tag:lists/star"; }
        { name = " - jungle"; query = "tag:lists/jungle"; }
        { name = " - nix"; query = "tag:lists/nix"; }
      ];
    };

    mbsync = {
      enable = true;
      extraConfig.channel.Create = "Both";
    };
  };
}
