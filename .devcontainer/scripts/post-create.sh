#!/usr/bin/env bash
# Runs once when the Codespace is created
set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
log() { echo -e "${GREEN}[setup]${NC} $*"; }
warn() { echo -e "${YELLOW}[warn]${NC} $*"; }

log "🚀 Installing dependencies via uv..."

# venv is already mounted as a volume
if [ ! -d ".venv" ] || [ ! -f ".venv/bin/python" ]; then
  uv venv .venv --python 3.12
fi

# Priority: uv.lock > pyproject.toml > requirements.txt
if [ -f "uv.lock" ]; then
  log "→ uv sync (from lock file)"
  uv sync --frozen
elif [ -f "pyproject.toml" ]; then
  log "→ uv sync (from pyproject.toml)"
  uv sync
elif [ -f "requirements.txt" ]; then
  log "→ uv pip install -r requirements.txt"
  uv pip install -r requirements.txt
else
  warn "No dependency manifest — skipping"
fi

# Pre-commit — optional, only if config exists
if [ -f ".pre-commit-config.yaml" ]; then
  log "→ Installing pre-commit"
  uv tool install pre-commit >/dev/null 2>&1 || true
  uv run pre-commit install >/dev/null 2>&1 || true
fi

# Git hooks for safety
log "→ Configuring git hooks"
cat > .git/hooks/pre-commit <<'EOF'
#!/bin/sh
# Fast check on changed files only
CHANGED=$(git diff --cached --name-only --diff-filter=ACM | grep '\.py$' || true)
[ -z "$CHANGED" ] && exit 0
echo "🔍 Ruff check..."
uv run ruff check $CHANGED || exit 1
EOF
chmod +x .git/hooks/pre-commit

log "✅ Done in $(date +%s)!"
echo ""
echo "Useful commands:"
echo "  uv run python app.py     — run the app"
echo "  uv run pytest            — run tests"
echo "  uv add <package>         — add a dependency"
echo "  bash .devcontainer/scripts/clean.sh  — clean caches"