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

bar_configured_count=0
waybar --config "${effective_config}" | while read -r line; do
    echo "${line}"
    if [[ "${line}" == *"Bar configured"* ]]; then
        ((bar_configured_count++))
        if [[ ${bar_configured_count} -ge ${num_monitors} ]]; then
            # Notify systemd once the "Bar configured" message is printed once for each of the bars
            systemd-notify --ready
        fi
    fi
done
