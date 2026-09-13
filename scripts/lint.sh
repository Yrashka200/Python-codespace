#!/usr/bin/env bash
# One tool (ruff) instead of three
set -euo pipefail

[ -z "${VIRTUAL_ENV:-}" ] && [ -f ".venv/bin/activate" ] && source .venv/bin/activate

MODE="${1:-check}"

case "$MODE" in
  fix)
    echo "🔧 Autofixing..."
    ruff check --fix .
    ruff format .
    ;;
  *)
    echo "🔍 Checking..."
    ruff check .
    ruff format --check .
    ;;
esac