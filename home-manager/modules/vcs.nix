{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.git = {
    enable = true;
    signing.key = "~/.ssh/id_ed25519.pub";
    signing.signByDefault = true;

    userName = lib.mkDefault config.home.username;

    ignores = [
      "*~"
      "*.swp"
      "/.direnv/"
      ".gdb_history"
      "result"
      "result-*"
      "compile_commands.json"
    ];

    aliases = {
      lg = "log --color --graph  --abbrev-commit --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'";
      l = "log --color --graph --abbrev-commit --pretty=format:'%C(magenta)%h%C(reset) %C(bold blue)<%an>%Creset %Cgreen(%ar)%Creset %C(yellow)%D%Creset%n%s%n'";
      wd = "diff --word-diff";
      wdiff = "diff --word-diff";
      blamec = "blame -w -C -C -C";
    };

    delta = {
      enable = true;
      options = {
        line-numbers = true;
      };
    };
    lfs.enable = true;

    attributes = [
      "*.pdf diff=pdf"
    ];

    extraConfig = {
      core = {
        compression = 9;
        whitespace = "error";
        preloadindex = true;
      };

      url = {
        "git@github.com:".insteadOf = "gh:";
        "git@github.com:leixb/".insteadOf = "leixb:";
        "git@git.sr.ht:~".insteadOf = "sh:";
        "git@gitlab-internal.bsc.es:".insteadOf = "bsc:";
        "git@bscpm04.bsc.es:".insteadOf = "pm:";
        "gitea@hut:".insteadOf = "jungle:";
      };

      status = {
        branch = true;
        showStash = true;
      };

      diff = {
        renames = "copies";
        interHunkContext = 10;
        pdf.command = lib.getExe pkgs.diffpdf;
      };

      init = {
        defaultBranch = "master";
      };
      pull = {
        rebase = true;
      };
      gpg = {
        format = "ssh";
      };
      rerere = {
        enabled = true;
      }; # reuse recorded resolution of conflicted merges
      column = {
        ui = "auto";
      };
      branch = {
        sort = "-committerdate";
      };
      fetch = {
        writeCommitGraph = true;
      };
      core = {
        fsmonitor = true;
      };
      commit.verbose = true;
    };
  };

  programs.git-cliff.enable = true;

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        email = "aleix.boneribo@bsc.es";
        name = "Aleix Boné";
      };

      revset-aliases = {
        "closest_bookmark(to)" = "heads(::to & bookmarks())";
        "closest_pushable(to)" = "heads(::to & ~description(exact:'') & (~empty() | merges()))";
        "closest_merge(to)" = "heads(::to & merges())";
      };

      aliases = {
        tug = [
          "bookmark"
          "move"
          "--from"
          "closest_bookmark(@-)"
          "--to"
          "closest_pushable(@)"
        ];
        stack = [
          "rebase"
          "-A"
          "trunk()"
          "-B"
          "closest_merge(@)"
          "-r"
        ];
        stage = [
          "stack"
          "closest_merge(@)+:: ~ empty()"
        ];

        l = [ "log" ];
        s = [ "status" ];
        fetch = [
          "git"
          "fetch"
        ];
        push = [
          "git"
          "push"
        ];
        remote = [
          "git"
          "remote"
        ];
        "show-" = [
          "show"
          "-r"
          "@-"
        ];
        "desc-" = [
          "describe"
          "-r"
          "@-"
        ];
        "diff-" = [
          "diff"
          "-r"
          "@-"
        ];
      };

      # Prevent pushing work in progress or anything explicitly labeled "private"
      git.private-commits = "description(glob:'wip:*') | description(glob:'private:*')";

      ui = {
        default-command = "log";
        diff-editor = ":builtin";
        pager = "delta";
        diff-formatter = ":git"; # needed for delta
      };

      signing = {
        behavior = "own";
        backend = "ssh";
        key = "~/.ssh/id_ed25519.pub";
      };

      templates = {
        draft_commit_description = ''
          concat(
            coalesce(description, default_commit_description, "\n"),
            surround(
              "\nJJ: This commit contains the following changes:\n", "",
              indent("JJ:     ", diff.stat(72)),
            ),
            "\nJJ: ignore-rest\n",
            diff.git(),
          )
        '';
      };

      fix.tools = {
        clang-format = {
          command =
            let
              # Wrapper around clang-format that comments pragmas so they get
              # indented properly
              clang-format-pragmas = pkgs.writeShellScriptBin "clang-format-pragmas" ''
                sed 's=#pragma=// CLANG_FORMAT &=' | \
                  "${lib.getBin pkgs.clang-tools}/bin/clang-format" "$@" | \
                  sed 's=// CLANG_FORMAT =='
              '';
            in
            [
              "${clang-format-pragmas}/bin/clang-format-pragmas"
              "--assume-filename=$path"
            ];
          patterns = [
            "glob:'**/*.cc'"
            "glob:'**/*.cpp'"
            "glob:'**/*.c'"
            "glob:'**/*.h'"
            "glob:'**/*.hpp'"
          ];
        };

        black = {
          command = [
            "${lib.getBin pkgs.black}"
            "-"
            "--stdin-filename=$path"
          ];
          patterns = [ "glob:'**/*.py'" ];
        };

        nixfmt = {
          command = [
            (lib.getBin pkgs.nixfmt-rfc-style)
            "--filename=$path"
          ];
          patterns = [ "glob:'**/*.nix'" ];
        };

        stylua = {
          command = [
            (lib.getBin pkgs.stylua)
            "--stdin-filepath=$path"
          ];
          patterns = [ "glob:'**/*.lua'" ];
        };
      };
    };
  };

}
