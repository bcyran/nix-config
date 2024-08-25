#!/usr/bin/env bash

set +o nounset

SAVE_FILE='/tmp/backlight_save'

progname="$(basename "$0")"
readonly progname

is_number() {
    if [[ $1 =~ ^[0-9]+$ ]]; then
        true
    else
        false
    fi
}

get_value() {
    local raw_value
    raw_value=$(brillo -G)
    echo "${raw_value%.*}"
}

set_value() {
    brillo -e -S "$1"
}

increment_value() {
    local current_value new_value
    current_value=$(get_value)
    new_value=$((current_value + $1))
    if [[ new_value -le 100 ]]; then
        set_value ${new_value}
    else
        err "can't set value greater than 100"
    fi
}

decrement_value() {
    local current_value new_value
    current_value=$(get_value)
    new_value=$((current_value - $1))
    if [[ new_value -ge 0 ]]; then
        set_value ${new_value}
    else
        err "can't set value less than 0"
    fi
}

save_value() {
    get_value > ${SAVE_FILE}
}

restore_value() {
    if [[ -f ${SAVE_FILE} ]]; then
        set_value "$(cat ${SAVE_FILE})"
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
        set_value "${value}"
        ;;
    get)
        get_value
        ;;
    up)
        is_number "${value:-10}" || usage_err 'VALUE must be a number'
        increment_value "${value:-10}"
        ;;
    down)
        is_number "${value:-10}" || usage_err 'VALUE must be a number'
        decrement_value "${value:-10}"
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
