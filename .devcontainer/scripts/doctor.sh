#!/usr/bin/env bash
# Environment diagnostics — runs on postStart
set -uo pipefail

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

echo -e "${CYAN}╭─────────────────────────────────────╮${NC}"
echo -e "${CYAN}│   🩺  Codespace Health Report       │${NC}"
echo -e "${CYAN}╰─────────────────────────────────────╯${NC}"

# --- CPU ---
CORES=$(nproc)
LOAD=$(awk '{print $1}' /proc/loadavg)
echo -e "  CPU:     ${CORES} cores, load: ${LOAD}"

# --- RAM ---
if [ -f /proc/meminfo ]; then
  TOTAL_MB=$(awk '/MemTotal/{printf "%d", $2/1024}' /proc/meminfo)
  AVAIL_MB=$(awk '/MemAvailable/{printf "%d", $2/1024}' /proc/meminfo)
  USED_MB=$((TOTAL_MB - AVAIL_MB))
  PCT=$((USED_MB * 100 / TOTAL_MB))
  if [ "$PCT" -gt 85 ]; then
    COLOR=$RED
  elif [ "$PCT" -gt 65 ]; then
    COLOR=$YELLOW
  else
    COLOR=$GREEN
  fi
  echo -e "  RAM:     ${COLOR}${USED_MB}/${TOTAL_MB} MB (${PCT}%)${NC}"
fi

# --- Disk ---
DISK=$(df -h /workspaces 2>/dev/null | awk 'NR==2{print $3"/"$2" ("$5")"}')
echo -e "  Disk:    ${DISK:-n/a}"

# --- venv ---
if [ -d ".venv" ]; then
  PY_VER=$(.venv/bin/python --version 2>&1)
  PKGS=$(ls .venv/lib/python*/site-packages 2>/dev/null | wc -l)
  echo -e "  venv:    ${GREEN}✓${NC} ${PY_VER}, ~${PKGS} packages"
else
  echo -e "  venv:    ${RED}✗ not found${NC}"
fi

# --- uv cache ---
if command -v uv >/dev/null 2>&1; then
  CACHE=$(du -sh ~/.cache/uv 2>/dev/null | cut -f1)
  echo -e "  uv:      ${GREEN}✓${NC} cache ${CACHE:-0}"
fi

# --- Top 3 largest dirs ---
echo -e "\n  ${YELLOW}Top-3 largest dirs in workspace:${NC}"
du -sh .[!.]* * 2>/dev/null | sort -rh | head -3 | while read -r size path; do
  echo -e "    ${size}\t${path}"
done

# --- Warnings ---
WARNINGS=()
[ "$(df --output=pcent /workspaces | tail -1 | tr -d '% ')" -gt 80 ] && WARNINGS+=("Disk >80% — run clean.sh")
command -v docker >/dev/null && WARNINGS+=("Docker detected — may eat RAM")

if [ ${#WARNINGS[@]} -gt 0 ]; then
  echo -e "\n  ${YELLOW}⚠ Warnings:${NC}"
  for w in "${WARNINGS[@]}"; do echo -e "    • $w"; done
fi
echo ""