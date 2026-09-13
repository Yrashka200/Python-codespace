#!/usr/bin/env bash
# Smart test runner
set -euo pipefail

[ -z "${VIRTUAL_ENV:-}" ] && [ -f ".venv/bin/activate" ] && source .venv/bin/activate

MODE="${1:-run}"

case "$MODE" in
  watch)
    # Requires pytest-watch — auto-installed
    pip show pytest-watch >/dev/null 2>&1 || pip install pytest-watch
    exec ptw -- --tb=short -q
    ;;
  cov)
    exec pytest --cov=src --cov-report=term-missing --cov-report=html
    ;;
  fast)
    # Only last failed tests
    exec pytest --lf -x -q
    ;;
  *)
    exec pytest -q --tb=short
    ;;
esac