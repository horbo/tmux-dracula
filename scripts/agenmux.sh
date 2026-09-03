#!/usr/bin/env bash
# setting the locale, some users have issues with different locales, this forces the correct one
export LC_ALL=en_US.UTF-8

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $current_dir/utils.sh

# agenmux ships no binary on PATH: by default it sits in the plugin checkout
# next to this one, and @agenmux-bin overrides that
agenmux_bin() {
  local bin
  bin=$(get_tmux_option "@agenmux-bin" "")

  if [ -z "$bin" ]; then
    bin="$current_dir/../../agenmux/target/release/agenmux"
    if [ ! -x "$bin" ]; then
      bin=$(command -v agenmux)
    fi
  fi

  echo "$bin"
}

main()
{
  local bin fg rate
  bin=$(agenmux_bin)

  if [ ! -x "$bin" ]; then
    return 0
  fi

  # agenmux closes every colored icon with #[default], which resets to
  # status-style and would punch a hole in the segment background
  fg="${1:-#f8f8f2}"

  rate=$(get_tmux_option "@dracula-agenmux-refresh-rate" 1)
  case "$rate" in
    '' | *[!0-9.]*) rate=1 ;;
  esac

  # agent state changes far more often than the status-interval tick, so this
  # is a job that never exits: tmux keeps the most recent line of a running
  # command and redraws the status line as new lines arrive, capped at once a
  # second
  while true; do
    "$bin" status | sed "s/#\[default\]/#[fg=$fg]/g"
    echo
    sleep "$rate"
  done
}

# run main driver
main "$@"
