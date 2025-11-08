#!/usr/bin/env bash

# Adapted from: https://github.com/farooqu/mdadm-ntfysh

# Author: Daniele Sluijters, Umer Farooq
# Source: https://github.com/farooqu/mdadm-ntfy
# License: GPLv3
# Version: 0.1.0

set +o nounset

send_message() {
  priority=$1
  summary=$2
  body=$3
  tag=""
  ntfy_server="${NTFY_SERVER:-ntfy.sh}"
  topic="${TOPIC:-mdadm-ntfy}"

  if [[ "${priority}" = 'urgent' ]]; then
    tag='rotating_light'
  fi

  # Base curl options as array
  headers=(-H "Priority: ${priority}")

  # Add optional title header
  if [[ -n "${TITLE}" ]]; then
    headers+=(-H "Title: ${TITLE}")
  fi

  # Add optional icon header
  if [[ -n "${ICON}" ]]; then
    headers+=(-H "Icon: ${ICON}")
  fi

  # Add optional tags header
  if [[ -n "${tag}" ]]; then
    headers+=(-H "Tags: ${tag}")
  fi

  # Add optional authorization header
  if [[ -n "${NTFY_TOKEN}" ]]; then
    headers+=(-H "Authorization: Bearer ${NTFY_TOKEN}")
  fi

  # Define the message body
  if [[ -n "${body}" ]]; then
    message="${summary}

${body}"
  else
    message="${summary}"
  fi

  curl "${headers[@]}" -d "${message}" -u "${NTFY_SH_USER}:${NTFY_SH_PASSWORD}" "${ntfy_server}/${topic}"
}

EVENT=$1
ARRAY=$2
DEVICE=$3

case "${EVENT}" in
  'DeviceDisappeared')
    send_message 'urgent' "Array ${ARRAY} has disappeared"
    ;;
  'RebuildStarted')
    send_message 'default' "Rebuild was started for ${ARRAY}"
    ;;
  'RebuildFinished')
    send_message 'default' "Rebuild for ${ARRAY} has completed" 'Please note that it **may have succeeded** or **have failed**. You need to inspect the status of the array by hand'
    ;;
  'Rebuild'[0-9][0-9])
    percent=$(echo "${EVENT}" | cut -c8,9)
    send_message 'default' "Rebuild of ${ARRAY} at ${percent}%"
    ;;
  'Fail')
    send_message 'urgent' "${ARRAY} has marked device ${DEVICE} as faulty"
    ;;
  'FailSpare')
    send_message 'urgent' "Rebuild failed for ${DEVICE}" "Failed to replace a faulty device in ${ARRAY}"
    ;;
  'SpareActive')
    send_message 'default' "Rebuild succesfull for ${DEVICE}" "Replaced a faulty device in ${ARRAY}"
    ;;
  'NewArray')
    send_message 'default' "New array ${ARRAY} has been detected"
    ;;
  'DegradedArray')
    send_message 'urgent' "Array ${ARRAY} is degraded"
    ;;
  'MoveSpare')
    send_message 'default' "Spare from ${DEVICE} was moved to ${ARRAY}"
    ;;
  'SpareMissing')
    send_message 'urgent' "Spare(s) missing from ${ARRAY}" 'There are less spares available than required by its configuration'
    ;;
  'TestMessage')
    send_message 'low' "Found array ${ARRAY} at startup (test)"
    ;;
  *)
    logger -t 'mdadm-notify' "Unhandled message of type: ${EVENT} with arguments ${ARRAY} ${DEVICE}"
    ;;
esac

exit 0
