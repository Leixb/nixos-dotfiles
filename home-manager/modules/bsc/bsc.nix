{ config, lib, pkgs, ... }:
let
  # allocate marenostrum node or reuse previous allocation
  qalloc = pkgs.writeShellScriptBin "qalloc" ''
    set -eo pipefail

    HOURS="''${1:-9}"
    QUEUE=gp_"''${2:-bsccs}"

    queue="$(ssh mn5 squeue | tail -n1 | awk '{ print $8 }')"

    if [[ "$queue" =~ ^gs[0-9]{2}r[0-3]b[0-9]{2}$ ]]; then
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
        mn5_key="$(cat ${config.sops.secrets.ssh_mn5_pubkey.path})"

        echo "$node $mn5_key" >>~/.ssh/known_hosts
    fi

    exec ssh "$node"
  '';
in
{
  home.packages = with pkgs; [
    msmtp
    qalloc
    wxparaver-adwaita
    slack
    rocketchat-desktop
    openfortivpn
    distrobox
    hyperfine
    jq
    gdb
    bear # generate compile_commands.json from arbitrary Makefiles
    ungoogled-chromium
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

  programs.git.userName = "Aleix Boné";
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
