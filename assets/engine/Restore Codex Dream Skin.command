#!/bin/bash
set -euo pipefail
INSTALLED="$HOME/.codex/codex-dream-skin-studio/scripts/restore-dream-skin-macos.sh"
if [ ! -x "$INSTALLED" ]; then
  /usr/bin/osascript -e 'display alert "Codex Dream Skin Studio is not installed." as warning' >/dev/null
  exit 1
fi
exec "$INSTALLED" --restore-base-theme --restart-codex
