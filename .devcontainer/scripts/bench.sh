#!/usr/bin/env bash
# Micro-benchmark of the environment
set -uo pipefail

echo "⏱  Benchmark..."

# Python startup
T=$( { /usr/bin/time -f "%e" .venv/bin/python -c "pass" ; } 2>&1 )
echo "  Python startup:   ${T}s"

# Import heavy libs
if .venv/bin/python -c "import fastapi" 2>/dev/null; then
  T=$( { /usr/bin/time -f "%e" .venv/bin/python -c "import fastapi" ; } 2>&1 )
  echo "  import fastapi:   ${T}s"
fi

# Disk write (important for the 32 GB tier)
T=$( { /usr/bin/time -f "%e" dd if=/dev/zero of=/tmp/bench bs=1M count=100 2>/dev/null ; } 2>&1 )
echo "  write 100MB:      ${T}s"
rm -f /tmp/bench

# uv resolve (simulates install)
T=$( { /usr/bin/time -f "%e" uv pip compile -q pyproject.toml -o /dev/null 2>&1 || true ; } 2>&1 | tail -1 )
[ -n "$T" ] && echo "  uv resolve:       ${T}s"