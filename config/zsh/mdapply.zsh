mdapply() {
  _mdapply_get_clipboard() {
    if command -v wl-paste >/dev/null 2>&1; then
      wl-paste
    elif command -v xsel >/dev/null 2>&1; then
      xsel -o
    elif command -v xclip >/dev/null 2>&1; then
      xclip -o -selection clipboard
    elif command -v pbpaste >/dev/null 2>&1; then
      pbpaste
    else
      echo "mdapply: no clipboard tool found (wl-paste/xsel/xclip/pbpaste)" >&2
      return 1
    fi
  }

  local input
  input=$(_mdapply_get_clipboard) || return 1

  echo "mdapply: got $(echo "$input" | wc -l) lines from clipboard"

  local state="IDLE"
  local action=""
  local filepath=""
  local -a content

  while IFS= read -r line; do
    case "$state" in
      IDLE|WAITING)
        if [[ "$line" =~ '^## (create|modify|delete) - ([^ ]+)' ]]; then
          action="${match[1]}"
          filepath="${match[2]}"

          if [[ "$filepath" == /* ]]; then
            echo "mdapply: warning - skipping absolute path: $filepath"
            action=""
            filepath=""
            state="IDLE"
            continue
          fi

          if [[ "$action" == "delete" ]]; then
            rm -f "$filepath"
            echo "mdapply: done   delete $filepath"
            action=""
            filepath=""
            state="IDLE"
          else
            state="WAITING"
          fi

        elif [[ "$state" == "WAITING" && "$line" == '```'* ]]; then
          content=()
          state="CAPTURING"
        fi
        ;;

      CAPTURING)
        if [[ "$line" == '```'* ]]; then
          local dir="${filepath%/*}"
          if [[ "$dir" != "$filepath" ]]; then
            mkdir -p "$dir"
          fi

          printf "%s\n" "${content[@]}" > "$filepath"

          echo "mdapply: done   $action $filepath"
          action=""
          filepath=""
          content=()
          state="IDLE"
        else
          content+=("$line")
        fi
        ;;
    esac
  done <<< "$input"
}
