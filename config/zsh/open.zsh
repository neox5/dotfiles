open() {
  if command -v nautilus &>/dev/null; then
    nautilus "$@" >/dev/null 2>&1 &!
  elif command -v dolphin &>/dev/null; then
    dolphin "$@" >/dev/null 2>&1 &!
  fi
}
