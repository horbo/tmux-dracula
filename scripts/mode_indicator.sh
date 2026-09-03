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
  prefix_label=$(get_label "@dracula-mode-indicator-prefix-label" "󰌌 PREFIX")
  copy_label=$(get_label "@dracula-mode-indicator-copy-label" "󰆏 COPY")
  sync_label=$(get_label "@dracula-mode-indicator-sync-label" false)

  # innermost first, so that the outer modes take priority
  format=""

  if [ -n "$sync_label" ]; then
    format="#{?pane_synchronized,$(escape_label "$sync_label"),$format}"
  fi

  if [ -n "$copy_label" ]; then
    format="#{?pane_in_mode,$(escape_label "$copy_label"),$format}"
  fi

  if [ -n "$prefix_label" ]; then
    format="#{?#{==:#{client_key_table},prefix},$(escape_label "$prefix_label"),$format}"
  fi

  echo "$format"
}

# run main driver
main
