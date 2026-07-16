#!/bin/bash
set -euo pipefail
INSTALLED="$HOME/.codex/codex-dream-skin-studio/scripts/start-dream-skin-macos.sh"
if [ ! -x "$INSTALLED" ]; then
  /usr/bin/osascript -e 'display alert "Run Install Codex Dream Skin.command first." as warning' >/dev/null
  exit 1
fi
exec "$INSTALLED" --prompt-restart
