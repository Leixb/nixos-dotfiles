#!/usr/bin/env bash

MONITOR=${1:-0}

hyprctl monitors -j | jq --raw-output .["$MONITOR"].activeWorkspace.id
# shellcheck disable=SC2016
socat -u "UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - | stdbuf -o0 grep '^workspace>>' | stdbuf -o0 awk -F '>>|,' '{print $2}'
