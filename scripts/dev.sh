#!/usr/bin/env bash
# Universal dev runner
set -euo pipefail

if [ -f "app/main.py" ] && grep -q "FastAPI" app/main.py 2>/dev/null; then
  echo "🚀 FastAPI (app.main:app)"
  exec uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
elif [ -f "main.py" ] && grep -q "FastAPI" main.py 2>/dev/null; then
  echo "🚀 FastAPI (main:app)"
  exec uvicorn main:app --reload --host 0.0.0.0 --port 8000
elif [ -f "manage.py" ]; then
  echo "🚀 Django"
  exec python manage.py runserver 0.0.0.0:8000
elif [ -f "app.py" ]; then
  echo "🚀 Flask/app.py"
  exec python app.py
elif [ -f "main.py" ]; then
  echo "🚀 Python main.py"
  exec python main.py
else
  echo "❌ No entry point found. Run manually: python <file>"
  exit 1
fi
