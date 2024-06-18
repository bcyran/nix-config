#!/usr/bin/env bash

set +o errexit

CONFIG_DEFAULT="@configDefaultPath@"
CONFIG_MULTI="@configMultiPath@"

trap "killall waybar" EXIT

num_monitors=$(hyprctl monitors | grep -c Monitor)

effective_config=${CONFIG_DEFAULT}
if [[ ${num_monitors} -gt 1 ]]; then
    effective_config=${CONFIG_MULTI}
fi

waybar --config "${effective_config}" &
readonly pid=$!

# Only report the waybar systemd service as started after the bar is started
# and an additional delay for internal initialization.
sleep 1
systemd-notify --ready

wait ${pid}
