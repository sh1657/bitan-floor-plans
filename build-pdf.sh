#!/bin/bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
PORT=8766
HTML="$DIR/plan5-export.html"
OUT="$DIR/plan5-bitan.pdf"
OUT_HE="$DIR/תכנית-5-בitan.pdf"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

if [[ ! -f "$HTML" ]]; then
  echo "Missing $HTML" >&2
  exit 1
fi
if [[ ! -x "$CHROME" ]]; then
  echo "Chrome not found at $CHROME" >&2
  exit 1
fi

python3 -m http.server "$PORT" --directory "$DIR" >/dev/null 2>&1 &
PID=$!
trap 'kill "$PID" 2>/dev/null || true' EXIT
sleep 1

"$CHROME" \
  --headless=new \
  --disable-gpu \
  --no-pdf-header-footer \
  --run-all-compositor-stages-before-draw \
  --virtual-time-budget=20000 \
  --print-to-pdf="$OUT" \
  "http://127.0.0.1:$PORT/plan5-export.html"

cp "$OUT" "$OUT_HE"
xattr -cr "$OUT" "$OUT_HE" 2>/dev/null || true
echo "Created: $OUT ($(du -h "$OUT" | cut -f1))"
