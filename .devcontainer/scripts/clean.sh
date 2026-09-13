#!/usr/bin/env bash
# Clean caches and junk
set -uo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
BEFORE=$(df --output=avail /workspaces | tail -1)

echo -e "${YELLOW}🧹 Cleaning...${NC}"

# Python junk
find . -type d -name "__pycache__" -prune -exec rm -rf {} + 2>/dev/null
find . -type f -name "*.pyc" -delete 2>/dev/null
find . -type d -name ".pytest_cache" -prune -exec rm -rf {} + 2>/dev/null
find . -type d -name ".ruff_cache" -prune -exec rm -rf {} + 2>/dev/null
find . -type d -name ".mypy_cache" -prune -exec rm -rf {} + 2>/dev/null
find . -type d -name ".coverage*" -delete 2>/dev/null
find . -type d -name "htmlcov" -prune -exec rm -rf {} + 2>/dev/null

# uv: keep last 7 days of cache
uv cache prune --ci 2>/dev/null || true

# pip cache (in case it was used)
rm -rf ~/.cache/pip 2>/dev/null || true

# Logs
find . -type f -name "*.log" -mtime +7 -delete 2>/dev/null

# VS Code workspace storage (heavy)
rm -rf ~/.vscode-server/data/User/workspaceStorage/*/state.vscdb* 2>/dev/null || true

AFTER=$(df --output=avail /workspaces | tail -1)
SAVED=$(( (AFTER - BEFORE) / 1024 ))
echo -e "${GREEN}✓ Freed: ~${SAVED} MB${NC}"