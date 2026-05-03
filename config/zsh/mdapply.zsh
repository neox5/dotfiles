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

  local lines
  lines=$(echo "$input" | wc -l)
  echo "mdapply: got ${lines} lines from clipboard"

  echo "$input" | awk '
  /^## (create|modify|delete) - / {
      action = $2
      filepath = $4
      gsub(/^["'"'"']|["'"'"']$/, "", filepath)
      if (substr(filepath, 1, 1) == "/") {
          print "mdapply: warning - skipping absolute path: " filepath
          action = ""
          filepath = ""
          next
      }
      if (action == "delete") {
          system("rm -f \"" filepath "\"")
          print "mdapply: done   delete " filepath
          action = ""
          filepath = ""
      } else {
          waiting = 1
      }
      next
  }
  /^```/ {
      if (in_code) {
          sub(/\n$/, "", content)
          dir = filepath
          sub(/[^/]*$/, "", dir)
          if (dir != "") system("mkdir -p \"" dir "\"")
          print content > filepath
          close(filepath)
          print "mdapply: done   " action " " filepath
          action = ""
          filepath = ""
          content = ""
          in_code = 0
      } else if (waiting) {
          in_code = 1
          waiting = 0
          content = ""
      }
      next
  }
  in_code {
      content = content $0 "\n"
  }'
}
