#!/usr/bin/env bash

readonly backlight="backlight"

light_print() {
    while true; do
        ${backlight} get | cut -d "." -f 1
        inotifywait -e modify /sys/class/backlight/intel_backlight/brightness > /dev/null 2>&1
    done
}

light_print
