#!/usr/bin/env bash

set -e

SCRIPTS_DIR="./scripts"
UNINSTALL_SUFFIX="_uninstall.sh"

print_help() {
  echo "Usage: ./uninstall.sh [module1 module2 ...]"
  echo "  No arguments: uninstall all modules"
  echo "  --list      : list available modules"
  echo "  --help      : show this help message"
}

run_uninstall() {
  local module="$1"
  local script="${SCRIPTS_DIR}/${module}${UNINSTALL_SUFFIX}"

  if [[ ! -x "$script" ]]; then
    echo "❌ No uninstall script found for module: $module"
    exit 1
  fi

  echo "🧹 Uninstalling ${module}..."
  "$script"
  echo "✅ Uninstalled: ${module}"
}

if [[ "$1" == "--help" ]]; then
  print_help
  exit 0
elif [[ "$1" == "--list" ]]; then
  ./scripts/list.sh
  exit 0
elif [[ $# -eq 0 ]]; then
  echo "🔁 Uninstalling all modules..."
  for script in ${SCRIPTS_DIR}/*${UNINSTALL_SUFFIX}; do
    module=$(basename "$script" "$UNINSTALL_SUFFIX")
    run_uninstall "$module"
  done
else
  for module in "$@"; do
    run_uninstall "$module"
  done
fi
