#!/usr/bin/env bash
#
# A script for setting backlight on multiple devices at once
# External monitors exposed via sysfs using https://aur.archlinux.org/packages/ddcci-driver-linux-dkms/
# Uses `light` as a backend: https://github.com/haikarainen/light

set +o nounset

SAVE_FILE='/tmp/backlight_save'

progname="$(basename "$0")"
mapfile -t devices < <(light -L | grep 'auto\|ddcci' | sed 's/[[:blank:]]*//')
readonly progname devices

light_all() {
    for device in "${devices[@]}"; do
        light -s "${device}" "$@"
    done
}

is_number() {
    if [[ $1 =~ ^[0-9]+$ ]]; then
        true
    else
        false
    fi
}

save_value() {
    light -G > ${SAVE_FILE}
}

restore_value() {
    if [[ -f ${SAVE_FILE} ]]; then
        light_all -S "$(cat ${SAVE_FILE})"
    else
        err 'no saved value'
    fi
}

forget_value() {
    rm -f ${SAVE_FILE}
}

print_help() {
    echo "Usage: ${progname} [-h|--help] {set|get|up|down|save|restore|forget} [VALUE]"
    echo "Set backlight intensity of all available displays."
}

usage_err() {
    echo "${progname}: $1" >&2
    print_help
    exit 1
}

err() {
    echo "${progname}: $1" >&2
    exit 1
}

command="$1"
value="${2%\%}" # Allow for '%' in value
readonly command value

case "${command}" in
    set)
        [[ -n "${value}" ]] || usage_err 'missing VALUE'
        is_number "${value}" || usage_err 'VALUE must be a number'
        light_all -S "${value}"
        ;;
    get)
        light -G
        ;;
    up)
        is_number "${value:-10}" || usage_err 'VALUE must be a number'
        light_all -A "${value:-10}"
        ;;
    down)
        is_number "${value:-10}" || usage_err 'VALUE must be a number'
        light_all -U "${value:-10}"
        ;;
    save)
        save_value
        ;;
    restore)
        restore_value
        ;;
    forget)
        forget_value
        ;;
    -h | ?-help)
        print_help
        ;;
    *)
        usage_err "invalid argument '${command}'"
        ;;
esac
