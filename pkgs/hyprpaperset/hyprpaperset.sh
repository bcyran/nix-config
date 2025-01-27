#!/usr/bin/env bash

if [[ $# -lt 1 ]]; then
  echo "Missing required argument PATH!" >&2
  echo "Usage: hyprpaperset PATH" >&2
  exit 1
fi

if [[ ! -f $1 ]]; then
  echo "File not found: $1" >&2
  exit 1
fi

mapfile -t monitors < <(hyprctl monitors | awk '/Monitor/ {print $2}')
# Symlinks confuse hyprpaper
real_path=$(realpath "$1")

hyprctl hyprpaper preload "${real_path}" > /dev/null

for monitor in "${monitors[@]}"; do
  hyprctl hyprpaper wallpaper "${monitor},${real_path}" > /dev/null
done

hyprctl hyprpaper unload unused > /dev/null
