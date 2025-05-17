#!/usr/bin/env bash

set -e

SCRIPTS_DIR="./scripts"
STATUS_SUFFIX="_status.sh"

if [[ "$1" == "--help" ]]; then
  echo "Usage: ./status.sh [module1 module2 ...]"
  echo "  No arguments: check all module statuses"
  echo "  --help      : show this help message"
  exit 0
fi

run_status() {
  local module="$1"
  local script="${SCRIPTS_DIR}/${module}${STATUS_SUFFIX}"

  if [[ -x "$script" ]]; then
    if "$script"; then
      echo "📦 $module: ✅ Installed"
    else
      echo "📦 $module: ❌ Not installed"
    fi
  else
    echo "📦 $module: ⚠️  No status check available"
  fi
}

if [[ $# -eq 0 ]]; then
  echo "🔍 Checking all modules..."
  for script in ${SCRIPTS_DIR}/*${STATUS_SUFFIX}; do
    module=$(basename "$script" "$STATUS_SUFFIX")
    run_status "$module"
  done
else
  for module in "$@"; do
    run_status "$module"
  done
fi
