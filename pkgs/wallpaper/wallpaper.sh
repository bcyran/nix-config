#!/usr/bin/env bash

set +o nounset

WALL_DIR="${MY_WALLPAPERS_DIR:-${HOME}/Obrazy/Tapety}"
SYMLINK_PATH="${WALL_DIR}/wallpaper"

progname="$(basename "$0")"
readonly progname

save_wallpaper() {
    if [[ $(readlink "${SYMLINK_PATH}") != "$1" ]]; then
        rm -f "${SYMLINK_PATH}"
        ln -s "$1" "${SYMLINK_PATH}"
        echo "Wallpaper saved: $(basename "$1")"
    fi
}

do_set_wallpaper() {
    if [[ -f ${SYMLINK_PATH} ]]; then
        hyprpaperset "${SYMLINK_PATH}"
        echo "Wallpaper set."
    else
        echo "No saved wallpaper. Please specify wallpaper to set."
        exit 1
    fi
}

set_new_wallpaper() {
    local candidates

    if [[ -f $1 ]]; then
        candidates=("$(realpath "$1")")
    else
        candidates=("${WALL_DIR}/$1"*)
    fi

    if [[ ${#candidates[@]} != 1 ]]; then
        echo "Multiple candidates:"
        for candidate in "${candidates[@]}"; do
            echo "- $(basename "${candidate}")"
        done
        exit 1
    else
        if [[ -f ${candidates[0]} ]]; then
            save_wallpaper "${candidates[0]}"
            do_set_wallpaper
        else
            echo "No wallpapers with given prefix."
            exit 1
        fi
    fi
}

try_set_wallpaper() {
    if [[ -n $1 ]]; then
        set_new_wallpaper "$1"
    else
        do_set_wallpaper
    fi
}

print_help() {
    echo "Usage: ${progname} [-h|--help] [wallpaper name prefix]"
    echo "Sets the wallpaper."
    echo "Wallpaper is searched in wallpapers directory by uniquely identifying prefix."
    echo "If no prefix is given, last set wallpaper is used."
}

usage_err() {
    echo "${progname}: $1" >&2
    print_help
    exit 1
}

arg="$1"
readonly arg

case "${arg}" in
    -h | ?-help)
        print_help
        ;;
    *)
        try_set_wallpaper "${arg}"
        ;;
esac
