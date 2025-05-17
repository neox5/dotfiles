#!/usr/bin/env bash

INSTALL_SUFFIX="_install.sh"
UNINSTALL_SUFFIX="_uninstall.sh"
SCRIPTS_DIR="./scripts"

echo "📦 Available modules:"
for script in "$SCRIPTS_DIR"/*$INSTALL_SUFFIX; do
  base=$(basename "$script" "$INSTALL_SUFFIX")
  if [[ -f "$SCRIPTS_DIR/${base}${UNINSTALL_SUFFIX}" ]]; then
    echo "  - $base"
  fi
done
