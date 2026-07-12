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
  local src_filepath=""
  local in_nested=false
  local -a content
  while IFS= read -r line; do
    case "$state" in
      IDLE|WAITING)
        if [[ "$line" =~ '^## (create|modify|delete|move|copy) - `?([^ `]+)`?' ]]; then
          action="${match[1]}"
          filepath="${match[2]}"
          if [[ "$filepath" == /* ]]; then
            echo "mdapply: warning - skipping absolute path: $filepath"
            action=""
            filepath=""
            state="IDLE"
            continue
          fi
          case "$action" in
            delete)
              if [[ -d "$filepath" ]]; then
                rm -rf "$filepath"
              else
                rm -f "$filepath"
              fi
              echo "mdapply: done   delete $filepath"
              action=""
              filepath=""
              state="IDLE"
              ;;
            move|copy)
              src_filepath="$filepath"
              filepath=""
              state="AWAITING_TO"
              ;;
            create|modify)
              state="WAITING"
              ;;
          esac
        elif [[ "$state" == "WAITING" && "$line" == '```'* ]]; then
          content=()
          in_nested=false
          state="CAPTURING"
        fi
        ;;
      AWAITING_TO)
        if [[ "$line" =~ '^## to - `?([^ `]+)`?' ]]; then
          local dst_filepath="${match[1]}"
          if [[ "$dst_filepath" == /* ]]; then
            echo "mdapply: warning - skipping absolute path: $dst_filepath"
            action=""
            src_filepath=""
            state="IDLE"
            continue
          fi
          local dst_dir="${dst_filepath%/*}"
          if [[ "$dst_dir" != "$dst_filepath" ]]; then
            mkdir -p "$dst_dir"
          fi
          if [[ "$action" == "move" ]]; then
            mv "$src_filepath" "$dst_filepath"
            echo "mdapply: done   move $src_filepath -> $dst_filepath"
          else
            cp "$src_filepath" "$dst_filepath"
            echo "mdapply: done   copy $src_filepath -> $dst_filepath"
          fi
          action=""
          src_filepath=""
          state="IDLE"
        else
          echo "mdapply: warning - expected '## to - <path>' after $action, got: $line"
          action=""
          src_filepath=""
          state="IDLE"
        fi
        ;;
      CAPTURING)
        if [[ "$line" =~ '^```[a-zA-Z]+' ]]; then
          in_nested=true
          content+=("$line")
        elif [[ "$line" == '```' ]]; then
          if [[ "$in_nested" == true ]]; then
            in_nested=false
            content+=("$line")
          else
            if (( ${#content} == 0 )); then
              echo "mdapply: warning - empty capture for $action $filepath, discarded"
            else
              local dir="${filepath%/*}"
              if [[ "$dir" != "$filepath" ]]; then
                mkdir -p "$dir"
              fi
              printf "%s\n" "${content[@]}" > "$filepath"
              echo "mdapply: done   $action $filepath"
            fi
            action=""
            filepath=""
            in_nested=false
            content=()
            state="IDLE"
          fi
        else
          content+=("$line")
        fi
        ;;
    esac
  done <<< "$input"
  if [[ "$state" == "CAPTURING" ]]; then
    echo "mdapply: warning - unclosed file block for $action $filepath, discarded"
  fi
}
