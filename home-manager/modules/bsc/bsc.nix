{ config, lib, pkgs, ... }:
let

  paraverKernel = pkgs.paraverKernel.overrideAttrs (oldAttrs: {
    version = "4.11.4";
    src = pkgs.fetchFromGitHub {
      owner = "bsc-performance-tools";
      repo = "paraver-kernel";
      rev = "v4.11.4";
      sha256 = "sha256-1LiEyF2pBkSa4hf3hAz51wBMXsXYpNqHgIeYH1OHE9M=";
    };
  });

  paraver = (pkgs.wxparaver.overrideAttrs (oldAttrs: {
    version = "4.11.4";

    src = pkgs.fetchFromGitHub {
      owner = "bsc-performance-tools";
      repo = "wxparaver";
      rev = "v4.11.4";
      sha256 = "sha256-0bsFnDnPwOa/dzSKqPJ91Zw23NYWTs0GcC6tv3WQqMs=";
    };

    patches = [
      (pkgs.fetchurl {
        url = "https://patch-diff.githubusercontent.com/raw/bsc-performance-tools/wxparaver/pull/14.patch";
        sha256 = "sha256-jJ/LTBxlsRfYvv4MFmXz/zMtPgP4piVUClf0Nxpg+Bk=";
      })
      ../../../packages/wxparaver/0001-fix-do-not-set-focus-on-redraw.patch
    ];
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs.installShellFiles ];
    postInstall = oldAttrs.postInstall + ''
      install -Dm0644 icons/paraver.svg $out/share/icons/hicolor/scalable/apps/paraver.svg
      install -Dm0644 paraver.desktop $out/share/applications/paraver.desktop

      installManPage $out/share/doc/wxparaver_help_contents/man/*
    '';
  })).override { inherit paraverKernel; };

  wxparaver-adawaita = pkgs.symlinkJoin {
    name = "wxparaver";
    paths = [ paraver ];
    nativeBuildInputs = with pkgs; [ makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/wxparaver" --set GTK_THEME "Adwaita:dark"
    '';
  };
in
{
  home.packages = with pkgs; [
    wxparaver-adawaita
    slack
    openfortivpn
    toolbox
  ];

  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };

  sops.secrets.ssh_config_bsc.path = "${config.home.homeDirectory}/.ssh/config.d/bsc";

  programs.git.userName = "aleixbonerib";
  programs.git.includes = [{ path = config.sops.secrets.git_config_bsc.path; }];
  sops.secrets.git_config_bsc.path = "${config.xdg.configHome}/git/config.d/secret.inc";

  programs.ssh = {
    enable = true;

    addKeysToAgent = "yes";

    includes = [
      config.sops.secrets.ssh_config_bsc.path
    ];
  };

  programs.firefox.profiles.${config.home.username}.bookmarks = [
    {
      toolbar = true;
      bookmarks = import ./bookmarks.nix;
    }
  ];
}
