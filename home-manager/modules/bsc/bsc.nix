{ config, lib, pkgs, ... }:
let
  # allocate marenostrum node or reuse previous allocation
  qalloc = pkgs.writeShellScriptBin "qalloc" ''
    set -eo pipefail

    HOURS="''${1:-9}"
    QUEUE=gp_"''${2:-bsccs}"

    queue="$(ssh mn5 squeue | tail -n1 | awk '{ print $8 }')"

    if [[ "$queue" =~ ^[ag]s[0-9]{2}r[0-3]b[0-9]{2}$ ]]; then
        echo "Reusing allocation $queue" >&2
        node="$queue"
    else
        echo "Requesting $HOURS hours allocation @ $QUEUE" >&2

        OUT="$(mktemp)"
        function cleanup {
            rm -f "$OUT"
        }
        trap cleanup EXIT

        ssh mn5 salloc -A bsc15 --qos "$QUEUE" --exclusive --time=$HOURS:00:00  --no-shell |& tee "$OUT"

        node="$(tail -n1 "$OUT" | cut -f 3 -d' ')"

        ${lib.getExe pkgs.libnotify} "Allocation granted" "$node is ready for job"
    fi

    exec ssh "$node"
  '';
in
{
  home.packages = with pkgs; [
    msmtp
    qalloc
    wxparaver-adwaita
    papercut-adwaita
    slack
    rocketchat-desktop
    openfortivpn
    distrobox
    hyperfine
    jq
    gdb
    bear # generate compile_commands.json from arbitrary Makefiles
    ungoogled-chromium
    radare2
    cling
    glab # gitlab cli
  ];

  xdg.configFile."distrobox/distrobox.conf" = lib.mkForce {
    text = ''
      container_additional_volumes="/etc/profiles/per-user:/etc/profiles/per-user:ro /etc/static/profiles/per-user:/etc/static/profiles/per-user:ro /nix:/nix:ro"
    '';
  };

  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };

  sops.secrets.ssh_config_bsc.path = "${config.home.homeDirectory}/.ssh/config.d/bsc";
  sops.secrets.ssh_mn5_pubkey.path = "${config.home.homeDirectory}/.ssh/.mn5_pubkey";

  programs.git.settings.user.name = "Aleix Boné";
  programs.git.includes = [{ path = config.sops.secrets.git_config_bsc.path; }];
  sops.secrets.git_config_bsc.path = "${config.xdg.configHome}/git/config.d/secret.inc";

  programs.ssh = {
    enable = true;

    matchBlocks."*".addKeysToAgent = "yes";

    includes = [
      config.sops.secrets.ssh_config_bsc.path
    ];
  };

  programs.fish.shellAliases = {
    p = "ssh tent p";
  };

  programs.firefox.profiles =
    let
      mkProfile = port:
        {
          id = port;
          isDefault = false;
          settings = {
            "network.proxy.allow_hijacking_localhost" = true;
            "network.proxy.socks" = "localhost";
            "network.proxy.socks_port" = port;
            "network.proxy.type" = 1; # socks5
          };
        };
    in
    {
      # custom profiles for ssh socks5 dynamic port forwarding proxies
      # ssh -D <host>
      SSH_dynamic_forward1 = mkProfile 1080;
      SSH_dynamic_forward2 = mkProfile 1081;

      # # bsc bookmarks
      ${config.home.username}.bookmarks.settings = [
        {
          toolbar = true;
          bookmarks = import ./bookmarks.nix;
        }
      ];
    };

  programs.jujutsu.settings = {
    user.email = "aleix.boneribo@bsc.es";

    "--scope" = [
      {
        "--when" = {
          repositories = [
            "~/Documents/Personal"
            "~/.dotfiles"
          ];
        };
        user.email = "abone9999" + "@" + "gmail.com";
      }
    ];
  };

}
