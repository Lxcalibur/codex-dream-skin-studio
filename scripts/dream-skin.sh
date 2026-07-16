#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd -P)"
ENGINE_DIR="$SKILL_DIR/assets/engine"
INSTALL_DIR="$HOME/.codex/codex-dream-skin-studio"

fail() {
  /usr/bin/printf 'Codex Dream Skin Skill: %s\n' "$*" >&2
  exit 1
}

usage() {
  /usr/bin/printf '%s\n' \
    'Usage: dream-skin.sh <action> [arguments]' \
    '' \
    'Actions:' \
    '  test                         Validate the bundled engine' \
    '  install [args]               Install or update the bundled engine' \
    '  customize [args]             Create a custom image theme' \
    '  preset <spain|argentina>     Create a bundled World Cup theme' \
    '  start [args]                 Start the verified themed Codex session' \
    '  verify [args]                Verify live UI and optionally screenshot' \
    '  doctor [args]                Validate signatures, payload, and live state' \
    '  restore [args]               Remove the theme or fully roll back' \
    '  engine-path                  Print the bundled engine path'
}

require_engine() {
  [ -x "$ENGINE_DIR/scripts/install-dream-skin-macos.sh" ] \
    || fail "Bundled engine is incomplete: $ENGINE_DIR"
}

require_install() {
  [ -x "$INSTALL_DIR/scripts/start-dream-skin-macos.sh" ] \
    || fail "Install the bundled engine first: $0 install --no-launch"
}

ACTION="${1:-}"
[ -n "$ACTION" ] || { usage; exit 2; }
shift

case "$ACTION" in
  test)
    require_engine
    exec "$ENGINE_DIR/tests/run-tests.sh" "$@"
    ;;
  install)
    require_engine
    exec "$ENGINE_DIR/scripts/install-dream-skin-macos.sh" "$@"
    ;;
  customize)
    require_install
    exec "$INSTALL_DIR/scripts/customize-theme-macos.sh" "$@"
    ;;
  preset)
    require_install
    exec "$INSTALL_DIR/scripts/apply-world-cup-preset-macos.sh" "$@"
    ;;
  start)
    require_install
    exec "$INSTALL_DIR/scripts/start-dream-skin-macos.sh" "$@"
    ;;
  verify)
    require_install
    exec "$INSTALL_DIR/scripts/verify-dream-skin-macos.sh" "$@"
    ;;
  doctor)
    require_install
    exec "$INSTALL_DIR/scripts/doctor-macos.sh" "$@"
    ;;
  restore)
    require_install
    exec "$INSTALL_DIR/scripts/restore-dream-skin-macos.sh" "$@"
    ;;
  engine-path)
    require_engine
    /usr/bin/printf '%s\n' "$ENGINE_DIR"
    ;;
  help|-h|--help)
    usage
    ;;
  *)
    usage >&2
    fail "Unknown action: $ACTION"
    ;;
esac
