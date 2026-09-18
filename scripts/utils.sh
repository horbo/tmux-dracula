#!/usr/bin/env bash

get_tmux_option() {
  local option="$1"
  local default_value="$2"
  local option_value="$(tmux show-option -gqv "$option")"
  if [ -z "$option_value" ]; then
    echo "$default_value"
  else
    echo "$option_value"
  fi
}

# a label set to `false` means the user disabled it, normalize that to empty
get_label() {
  local label
  label=$(get_tmux_option "$1" "$2")
  if [ "$label" == false ]; then
    label=""
  fi
  echo "$label"
}

# labels are embedded into a tmux format string, so the format metacharacters
# have to be neutralized before interpolation
escape_label() {
  local label="$1"
  label="${label//,/#,}"
  label="${label//\}/#\}}"
  echo "$label"
}

get_tmux_window_option() {
  local option="$1"
  local default_value="$2"
  local option_value="$(tmux show-window-options -v "$option")"
  if [ -z "$option_value" ]; then
    echo "$default_value"
  else
    echo "$option_value"
  fi
}

# normalize the percentage string to always have a length of 5
normalize_percent_len() {
  # the max length that the percent can reach, which happens for a two digit number with a decimal house: "99.9%"
  max_len=5
  percent_len=${#1}
  let diff_len=$max_len-$percent_len
  # if the diff_len is even, left will have 1 more space than right
  let left_spaces=($diff_len+1)/2
  let right_spaces=($diff_len)/2
  printf "%${left_spaces}s%s%${right_spaces}s\n" "" $1 ""
}

preserved_status_right() {
  local current preserved patterns pattern re
  current="$(tmux show-option -gqv status-right)"
  patterns="$(get_tmux_option "@dracula-preserve-status-right" "continuum_save.sh")"
  preserved=""
  for pattern in $patterns; do
    re="#\([^)]*${pattern}[^)]*\)"
    while [[ "$current" =~ $re ]]; do
      case "$preserved" in
        *"${BASH_REMATCH[0]}"*) ;;
        *) preserved+="${BASH_REMATCH[0]}" ;;
      esac
      current="${current/"${BASH_REMATCH[0]}"/}"
    done
  done
  printf '%s' "$preserved"
}
