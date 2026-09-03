#!/usr/bin/env bash
# setting the locale, some users have issues with different locales, this forces the correct one
export LC_ALL=en_US.UTF-8

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $current_dir/utils.sh

# labels are embedded into a tmux format string, so the format metacharacters
# have to be neutralized before interpolation
escape_label() {
  local label="$1"
  label="${label//,/#,}"
  label="${label//\}/#\}}"
  echo "$label"
}

main()
{
  zoom_label=$(get_label "@dracula-zoom-indicator-label" "󰊓 ZOOM")

  format=""

  if [ -n "$zoom_label" ]; then
    format="#{?window_zoomed_flag,$(escape_label "$zoom_label"),}"
  fi

  echo "$format"
}

# run main driver
main
