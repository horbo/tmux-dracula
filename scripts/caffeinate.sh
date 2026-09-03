#!/usr/bin/env bash
# setting the locale, some users have issues with different locales, this forces the correct one
export LC_ALL=en_US.UTF-8

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $current_dir/utils.sh

# is any keep awake utility currently running?
# macOS: caffeinate. linux: systemd-inhibit, caffeine
caffeinate_is_running() {
  local pattern
  pattern=$(get_tmux_option "@dracula-caffeinate-process" "caffeinate|systemd-inhibit|caffeine")
  pgrep -x "$pattern" >/dev/null 2>&1
}

main()
{
  # storing the refresh rate in the variable RATE, default is 5
  RATE=$(get_tmux_option "@dracula-refresh-rate" 5)

  # Use the @dracula-caffeinate-refresh-rate plugin variable to override it.
  RATE_OVERRIDE=$(get_tmux_option "@dracula-caffeinate-refresh-rate" "")
  if [[ -n "$RATE_OVERRIDE" ]]; then
    RATE="$RATE_OVERRIDE"
  fi

  if caffeinate_is_running; then
    get_label "@dracula-caffeinate-label" " CAFFEINATED"
  else
    get_label "@dracula-caffeinate-off-label" false
  fi

  sleep $RATE
}

# run main driver
main
