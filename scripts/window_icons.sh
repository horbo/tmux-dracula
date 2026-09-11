#!/usr/bin/env bash
# setting the locale, some users have issues with different locales, this forces the correct one
export LC_ALL=en_US.UTF-8

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $current_dir/utils.sh

# space separated `cmds=icon` entries, one icon can serve several commands via `|`
builtin_map="zsh|bash|fish|sh|dash=󰆍 nvim= vim|vi= claude=󰚩 lazygit|git|tig=󰊢 ssh|mosh=󰣀 docker|lazydocker=󰡨 python|python3|ipython= node|bun|deno=󰎙 htop|btop|top=󰍛 kubectl|k9s=󱃾 cargo= go= make=󰒓 man|less|bat=󰈙"

main()
{
  show_window_icons=$(get_tmux_option "@dracula-window-icons" false)

  if [ "$show_window_icons" != true ]; then
    echo ""
    return
  fi

  user_map=$(get_tmux_option "@dracula-window-icons-map" "")
  default_icon=$(get_label "@dracula-window-icons-default" "")

  # innermost first, so that the user entries end up outermost and take priority
  format=""

  if [ -n "$default_icon" ]; then
    format="$(escape_label "$default_icon") "
  fi

  IFS=' ' read -r -a entries <<< "$user_map $builtin_map"

  for ((i=${#entries[@]}-1; i>=0; i--)); do
    entry="${entries[$i]}"

    case "$entry" in
      *=*) ;;
      *) continue ;;
    esac

    cmds="${entry%%=*}"
    icon="${entry#*=}"

    if [ -z "$cmds" ]; then
      continue
    fi

    IFS='|' read -r -a cmd_list <<< "$cmds"

    for cmd in "${cmd_list[@]}"; do
      if [ -n "$cmd" ]; then
        format="#{?#{==:#{pane_current_command},$cmd},$(escape_label "$icon") ,$format}"
      fi
    done
  done

  echo "$format"
}

# run main driver
main
