#!/bin/bash
set -euo pipefail
INSTALLED="$HOME/.codex/codex-dream-skin-studio/scripts/verify-dream-skin-macos.sh"
OUTPUT="$HOME/Desktop/Codex Dream Skin Verification.png"
if [ ! -x "$INSTALLED" ]; then
  /usr/bin/osascript -e 'display alert "Run Install Codex Dream Skin.command first." as warning' >/dev/null
  exit 1
fi
"$INSTALLED" --screenshot "$OUTPUT"
/usr/bin/open "$OUTPUT"
