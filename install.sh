#!/usr/bin/env bash

set -e

SCRIPTS_DIR="./scripts"
INSTALL_SUFFIX="_install.sh"

print_help() {
  echo "Usage: ./install.sh [module1 module2 ...]"
  echo "  No arguments: install all modules"
  echo "  --list      : list available modules"
  echo "  --help      : show this help message"
}

run_install() {
  local module="$1"
  local script="${SCRIPTS_DIR}/${module}${INSTALL_SUFFIX}"

  if [[ ! -x "$script" ]]; then
    echo "❌ No install script found for module: $module"
    exit 1
  fi

  echo "🔧 Installing ${module}..."
  "$script"
  echo "✅ Finished: ${module}"
}

if [[ "$1" == "--help" ]]; then
  print_help
  exit 0
elif [[ "$1" == "--list" ]]; then
  ./scripts/list.sh
  exit 0
elif [[ $# -eq 0 ]]; then
  echo "🔁 Installing all modules..."
  for script in ${SCRIPTS_DIR}/*${INSTALL_SUFFIX}; do
    module=$(basename "$script" "$INSTALL_SUFFIX")
    run_install "$module"
  done
else
  for module in "$@"; do
    run_install "$module"
  done
fi
