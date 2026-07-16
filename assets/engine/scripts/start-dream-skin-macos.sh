#!/bin/bash

set -euo pipefail
. "$(cd "$(dirname "$0")" && pwd -P)/common-macos.sh"

record_start_error() {
  local code="$1"
  local line="$2"
  ensure_state_root
  printf '%s exit=%s line=%s\n' "$(/bin/date -u '+%Y-%m-%dT%H:%M:%SZ')" "$code" "$line" >> "$START_ERROR_LOG"
  printf 'Codex Dream Skin Studio: start failed at line %s (exit %s). See %s\n' "$line" "$code" "$START_ERROR_LOG" >&2
}
trap 'code=$?; record_start_error "$code" "$LINENO"' ERR

PORT=9341
PORT_EXPLICIT="false"
RESTART_EXISTING="false"
PROMPT_RESTART="false"
FOREGROUND_INJECTOR="false"
LANGUAGE="auto"
while [ "$#" -gt 0 ]; do
  case "$1" in
    --port) PORT="${2:-}"; PORT_EXPLICIT="true"; shift 2 ;;
    --restart-existing) RESTART_EXISTING="true"; shift ;;
    --prompt-restart) PROMPT_RESTART="true"; shift ;;
    --foreground-injector) FOREGROUND_INJECTOR="true"; shift ;;
    --language) LANGUAGE="${2:-}"; shift 2 ;;
    *) fail "Unknown start argument: $1" ;;
  esac
done
case "$PORT" in ''|*[!0-9]*) fail "Invalid port: $PORT" ;; esac
[ "$PORT" -ge 1024 ] && [ "$PORT" -le 65535 ] || fail "Port must be between 1024 and 65535."

discover_codex_app
require_macos_runtime
ensure_state_root

case "$LANGUAGE" in
  auto)
    LANGUAGE="$("$NODE" -e '
      const fs = require("node:fs");
      try {
        const value = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
        process.stdout.write(value.language === "es" ? "es" : "en");
      } catch {
        process.stdout.write("en");
      }
    ' "$THEME_DIR/theme.json")"
    ;;
  en|es) ;;
  *) fail "Language must be auto, en, or es." ;;
esac

if [ "$PORT_EXPLICIT" = "false" ] && [ -f "$STATE_PATH" ]; then
  saved_port="$(state_field port)" || fail "Could not read the existing state port."
  [ -n "$saved_port" ] && PORT="$saved_port"
fi

DEBUG_READY="false"
if verified_cdp_endpoint "$PORT"; then DEBUG_READY="true"; fi

if codex_is_running && [ "$DEBUG_READY" = "false" ]; then
  if [ "$PROMPT_RESTART" = "true" ] && [ "$RESTART_EXISTING" = "false" ]; then
    if [ "$LANGUAGE" = "es" ]; then
      /usr/bin/osascript -e 'display dialog "Codex debe reiniciarse una vez para activar Dream Skin." buttons {"Cancelar", "Reiniciar y aplicar"} default button "Reiniciar y aplicar" with title "Codex Dream Skin Studio"' >/dev/null \
        || fail "Theme launch was cancelled."
    else
      /usr/bin/osascript -e 'display dialog "Codex must restart once to activate Dream Skin." buttons {"Cancel", "Restart and apply"} default button "Restart and apply" with title "Codex Dream Skin Studio"' >/dev/null \
        || fail "Theme launch was cancelled."
    fi
    RESTART_EXISTING="true"
  fi
  [ "$RESTART_EXISTING" = "true" ] || fail "Codex is already running without the verified skin CDP endpoint. Close it first or pass --restart-existing."
  stop_codex true
fi

if [ "$DEBUG_READY" = "false" ]; then
  PORT="$(select_available_port "$PORT")"
  launch_codex_with_cdp "$PORT"
  wait_for_cdp "$PORT" || fail "Codex did not expose a verified loopback CDP endpoint on port $PORT within 35 seconds. See $APP_LOG"
fi

if [ -f "$STATE_PATH" ]; then
  stop_recorded_injector
  /bin/rm -f "$STATE_PATH"
fi

if [ "$FOREGROUND_INJECTOR" = "true" ]; then
  exec "$NODE" "$INJECTOR" --watch --port "$PORT" --theme-dir "$THEME_DIR"
fi

INJECTOR_PID="$(launch_injector_daemon "$PORT")"
/bin/sleep 0.8
/bin/kill -0 "$INJECTOR_PID" 2>/dev/null || fail "The injector exited during startup. See $INJECTOR_ERROR_LOG"
INJECTOR_STARTED_AT="$(process_started_at "$INJECTOR_PID")"
[ -n "$INJECTOR_STARTED_AT" ] || fail "Could not record the injector process start time."
CODEX_PID="$(codex_main_pids | /usr/bin/head -n 1)"
write_state "$PORT" "$INJECTOR_PID" "$INJECTOR_STARTED_AT" "$CODEX_PID"

if ! "$NODE" "$INJECTOR" --verify --port "$PORT" --theme-dir "$THEME_DIR" --timeout-ms 30000 >/dev/null; then
  /bin/launchctl remove "$INJECTOR_JOB_LABEL" >/dev/null 2>&1 || /bin/kill -TERM "$INJECTOR_PID" 2>/dev/null || true
  /bin/rm -f "$STATE_PATH"
  fail "Injection verification failed. The injector was stopped; see $INJECTOR_ERROR_LOG"
fi

printf 'Codex Dream Skin Studio %s is active on loopback port %s.\n' "$SKIN_VERSION" "$PORT"
