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
      { map = [ "index" "pager" ]; key = "S"; action = "vfolder-from-query"; }
      { map = [ "index" "pager" ]; key = "dd"; action = "noop"; }
      { map = [ "index" "pager" ]; key = "dt"; action = "noop"; }
      { map = [ "index" "pager" ]; key = "dT"; action = "noop"; }
      { map = [ "index" "pager" ]; key = "O"; action = "noop"; }
      { map = [ "index" "pager" ]; key = "A"; action = "create-alias"; }
      { map = [ "index" "pager" ]; key = "a"; action = "noop"; }
    ];
    macros = [
      { map = [ "index" "pager"]; key = "O"; action = "<shell-escape>systemctl --user start mbsync && afew -v --move-mails && notmuch new && mbsync -a<enter><sync-mailbox>"; } # Full sync
      { map = [ "index" "pager" ]; key = "dd"; action = "<modify-labels>+trash -inbox -unread<enter>"; }
      { map = [ "index" "pager" ]; key = "a"; action = "<modify-labels>+archive -inbox<enter>"; }
      { map = [ "index" "pager" ]; key = "dT"; action = "<tag-thread><modify-labels>+trash -inbox -unread<enter>"; }
      { map = [ "index" "pager" ]; key = "dt"; action = "<tag-subthread><modify-labels>+trash -inbox -unread<enter>"; }
      { map = [ "index" "pager" ]; key = "\\cb"; action = "<enter-command>unset wait_key<enter><pipe-message>${lib.getExe pkgs.urlscan}<enter><enter-command>set wait_key<enter>"; } # follow urls
      { map = [ "attach" "compose" ]; key = "\\cb"; action = "<enter-command>unset wait_key<enter><pipe-message>${lib.getExe pkgs.urlscan}<enter><enter-command>set wait_key<enter>"; } # follow urls
      { map = [ "index" "pager" ]; key = "\\ct"; action = "<modify-labels>!todo\\n"; } # Toggle todo
    ];
    extraConfig =
      let
        mailcap = pkgs.writeText "mailcap" ''
          text/html; ${lib.getExe pkgs.w3m} -I %{charset} -T text/html; copiousoutput; description=HTML Text; nametemplate=%s.html
          text/html; ${lib.getExe config.programs.firefox.package} %s; nametemplate=%s.html; needsterminal
          image/*; ${lib.getExe pkgs.timg} -g80x40 %s; needsterminal
          application/pdf; ${lib.getExe pkgs.zathura} '%s'
        '';
      in
      ''
        auto_view text/html image/jpeg image/png image/gif
        alternative_order text/enriched text/plain text/html

        set mailcap_path = ${mailcap}

        set nm_unread_tag = unread
        set mail_check_stats = yes

        set spoolfile = "notmuch://?query=tag:inbox"

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

  services.imapnotify = {
    enable = true;
    path = [ pkgs.coreutils pkgs.systemd ];
  };

  programs.notmuch = {
    enable = true;
    new.tags = [ "new" ];
    hooks.postNew = let
      notmuchPostNew = pkgs.writeShellApplication {
        name = "notmuch-post";
        meta.mainProgram = "notmuch-post";
        runtimeInputs = with pkgs; [
          libnotify
          notmuch
          jq
        ] ++ (lib.optionals config.programs.afew.enable [ config.programs.afew.package ]);
        text =
          ''
          NEW_COUNT=$(notmuch count tag:new)
          if [ "$NEW_COUNT" -eq 0 ]; then
            exit 0
          fi

          notify-send "📬 Mail" "$NEW_COUNT new message(s)" -i mail-unread
          ${lib.optionalString config.programs.afew.enable "afew --tag --new"}
        '';
      };
    in lib.getExe notmuchPostNew;
  };

  programs.afew = {
    enable = true;
    extraConfig = ''
      [SpamFilter]
      [KillThreadsFilter]
      [ListMailsFilter]

      [Filter.1]
      message = Tag BSC account
      query = path:bsc/**
      tags = +bsc

      [Filter.2]
      message = Tag UPC account
      query = path:upc/**
      tags = +upc

      [Filter.3]
      message = Vicenç
      query = from:vbeltran@bsc.es
      tags = +boss

      [Filter.4]
      message = Gitlab
      query = from:gitlab@gitlab.bsc.es
      tags = +gitlab

      [HeaderMatchingFilter.1]
      header = X-Mailer
      pattern = Gitea
      tags = +gitea

      [ArchiveSentMailsFilter]
      sent_tag = sent

      [Filter.5]
      message = Remove inbox from sent mail explicitly
      query = tag:sent
      tags = -inbox;-new

      [InboxFilter]

      [Filter.6]
      message = Tag archived mail
      query = NOT tag:inbox AND NOT tag:sent AND NOT tag:drafts AND NOT tag:spam AND NOT tag:trash
      tags = +archive

      [Filter.7]
      message = Remove inbox tag from trash
      query = tag:trash
      tags = -inbox

      [MailMover]
      folders = bsc/Inbox bsc/Trash bsc/Spam bsc/Archives bsc/Drafts
      rename = True

      bsc/Inbox = 'tag:archive':bsc/Archives 'tag:trash':bsc/Trash 'tag:spam':bsc/Spam
      bsc/Trash = 'NOT tag:trash':bsc/Inbox
      bsc/Drafts = 'tag:trash':bsc/Trash
      bsc/Spam = 'NOT tag:spam':bsc/Inbox 'tag:trash':bsc/Trash
      bsc/Archives = 'tag:inbox':bsc/Inbox 'tag:trash':bsc/Trash
    '';
  };

  sops.secrets.email_pass.path = "${config.xdg.configHome}/mail/sops";

  programs.lieer.enable = true;
  services.lieer.enable = true;

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

    imapnotify = {
      enable = true;
      boxes = [ "Inbox" ];
      onNotify = "systemctl --user start mbsync";
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
        { name = "unread"; query = "tag:unread AND NOT tag:trash"; }
        { name = "todo"; query = "tag:todo"; }
        { name = "flagged"; query = "tag:flagged"; }
        { name = "archive"; query = "tag:archive AND NOT tag:trash"; }
        { name = "all"; query = "NOT tag:trash"; }

        { name = "drafts"; query = "tag:drafts AND NOT tag:trash"; }
        { name = "sent"; query = "tag:sent"; type = "messages"; }

        { name = "spam"; query = "tag:spam"; }
        { name = "trash"; query = "tag:trash"; }

        { name = "lists"; query = "tag:lists"; }
        { name = "l.bsc"; query = "tag:lists/bsc-cns"; }
        { name = "l.personal"; query = "tag:lists/personal"; }
        { name = "l.star"; query = "tag:lists/star"; }
        { name = "l.jungle"; query = "tag:lists/jungle"; }
        { name = "l.nix"; query = "tag:lists/nix"; }
        { name = "l.dare"; query = "tag:lists/dare_sw_wp26"; }
      ];
    };

    mbsync = {
      enable = true;
      extraConfig.channel.Create = "Both";
    };
  };

  # Run notmuch new after lieer import
  systemd.user.services.lieer-upc.Service.ExecStartPost = "${lib.getExe pkgs.notmuch} new";

  accounts.email.accounts.upc = {
    address = "aleix.bone@estudiantat.upc.edu";
    aliases = [ "aleix.bone@est.fib.upc.edu" ];
    flavor = "gmail.com";
    realName = "Aleix Boné";
    folders.inbox = "mail";

    lieer = {
      enable = true;
      sync.enable = true;
      settings = {
        account = "me";
        ignore_tags = [ "new" "upc" ];
      };
    };

    notmuch.enable = true;

    neomutt.enable = true;
    neomutt.mailboxType = "maildir";

    notmuch.neomutt = {
      enable = true;
      virtualMailboxes = [
        { name = "inbox"; query = "tag:inbox"; }
        { name = "unread"; query = "tag:unread AND NOT tag:trash"; }
        { name = "todo"; query = "tag:todo"; }
        { name = "flagged"; query = "tag:flagged"; }
        { name = "archive"; query = "tag:archive AND NOT tag:trash"; }
        { name = "all"; query = "NOT tag:trash"; }

        { name = "drafts"; query = "tag:drafts AND NOT tag:trash"; }
        { name = "sent"; query = "tag:sent"; type = "messages"; }

        { name = "spam"; query = "tag:spam"; }
        { name = "trash"; query = "tag:trash"; }

        { name = "lists"; query = "tag:lists"; }
      ];
    };
  };
}
