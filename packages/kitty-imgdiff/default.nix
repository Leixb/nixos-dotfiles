{ lib
, writeShellApplication
, imagemagick
, ghostscript
, git
, kitty
, liberation_ttf
, supported_extensions ? [
    "png"
    "jpg"
    "jpeg"
    "gif"
    "bmp"
    "tiff"
    "webp"
    "svg"
    "pdf"
    "eps"
    "ps"
  ]
}:
let regex = lib.concatStringsSep "|" supported_extensions; in
writeShellApplication {
  name = "imgdiff";
  # Diff images using imagemagick and show the result in kitty
  # Usage: imgdiff <image1> <image2>
  #
  # Unfortunately, this does not work with git diff
  # (unless --no-pager is used) since the pager deletes the escape
  # sequences (at least with delta and less -r).

  runtimeInputs = [
    ghostscript
    git
    imagemagick # compare and montage
    kitty
  ];

  text = ''
    function usage() {
      echo "Usage: $0 <image1> <image2>" >&2
      echo "Usage: $0 git <image1> ..." >&2
      exit 1
    }

    function inside_git() {
      git rev-parse --is-inside-work-tree &> /dev/null
    }
    function verify_git() {
      inside_git || {
        echo "Not inside a git repository" >&2
        exit 1
      }
    }

    REMOVE_FILE_LIST_FILE="$(mktemp)"
    export REMOVE_FILE_LIST_FILE

    function cleanup() {
      xargs rm < "$REMOVE_FILE_LIST_FILE"
      rm "$REMOVE_FILE_LIST_FILE"
    }

    FONT="${liberation_ttf}/share/fonts/truetype/LiberationSans-Regular.ttf"

    function diffgit() {
      FILE_NEW="$1"
      EXTENSION="''${FILE_NEW##*.}"
      FILE_OLD="$(mktemp --suffix=".$EXTENSION")"

      echo "$FILE_OLD" >> "$REMOVE_FILE_LIST_FILE"

      git show HEAD:"$FILE_NEW" > "$FILE_OLD"

      pairdiff "$FILE_OLD" "$FILE_NEW"
    }

    function gitmode() {
      trap cleanup EXIT
      {
        if [ "$#" -eq 0 ]; then
          git diff --name-only --diff-filter=M | \
            grep -E "\.(${regex})$"
        else
          echo "$@" | xargs -n1
        fi
      } | while read -r FILE; do
        diffgit "$FILE"
      done
    }

    function pairdiff() {
      echo "$1 -> $2" >&2
      compare "$1" "$2" png:- | \
        montage -font "$FONT" -geometry +4+4 "$1" - "$2" png:- | \
        kitty +kitten icat || true # For some reason, montage returns 1
    }

    if [ "$#" -eq 0 ]; then
      if inside_git; then
        gitmode "$@"
      else
        usage
      fi
    elif [ "$1" = "git" ]; then
      shift
      verify_git
      gitmode "$@"
    elif [ "$#" -eq 2 ]; then
      pairdiff "$@"
    else
      usage
    fi
  '';
}
