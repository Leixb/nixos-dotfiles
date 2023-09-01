#!/usr/bin/env bash

function clamp {
	min=$1
	max=$2
	val=$3
	if test "$val" -lt "$min"; then
		echo "$min"
	elif test "$val" -gt "$max"; then
		echo "$max"
	else
		echo "$val"
	fi
}

direction=$1
current=$2
if test "$direction" = "down"; then
	target=$(clamp 1 10 $((current + 1)))
	echo "jumping to $target"
	hyprctl dispatch workspace "$target"
elif test "$direction" = "up"; then
	target=$(clamp 1 10 $((current - 1)))
	echo "jumping to $target"
	hyprctl dispatch workspace "$target"
fi
