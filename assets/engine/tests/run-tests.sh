#!/bin/bash

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
NODE="${NODE:-/Applications/ChatGPT.app/Contents/Resources/cua_node/bin/node}"
[ -x "$NODE" ] || { printf 'Codex bundled Node.js was not found: %s\n' "$NODE" >&2; exit 1; }

while IFS= read -r file; do /bin/bash -n "$file"; done < <(
  /usr/bin/find "$ROOT" -type f \( -name '*.sh' -o -name '*.command' \) \
    ! -path '*/release/*' -print
)
while IFS= read -r file; do "$NODE" --check "$file" >/dev/null; done < <(
  /usr/bin/find "$ROOT/scripts" "$ROOT/assets" -type f \( -name '*.mjs' -o -name '*.js' \) -print
)

if /usr/bin/grep -R -n -E 'dream-skin-skin|DREAM_SKIN_SKIN|1\.0\.0-rc2' \
  "$ROOT/scripts" "$ROOT/assets" >/dev/null; then
  printf 'Legacy release-candidate identifiers remain in runtime files.\n' >&2
  exit 1
fi
if /usr/bin/grep -R -n -E '(writeFile|rename|copyFile|rm).*app\.asar' "$ROOT/scripts" >/dev/null; then
  printf 'A runtime script appears to mutate app.asar.\n' >&2
  exit 1
fi

"$NODE" "$ROOT/scripts/injector.mjs" --check-payload >/dev/null

TMP="$(/usr/bin/mktemp -d /tmp/codex-dream-skin-tests.XXXXXX)"
trap '/bin/rm -rf "$TMP"' EXIT
/bin/mkdir -p "$TMP/theme"
/bin/cp "$ROOT/assets/default-background.jpg" "$TMP/theme/background.jpg"
"$NODE" "$ROOT/scripts/write-theme.mjs" custom --output-dir "$TMP/theme" \
  --image background.jpg --name 'Test theme' --tagline 'Test tagline' --quote 'TEST' \
  --accent '#11aa55' --secondary '#22bbcc' --highlight '#663399' \
  --layout portrait --scale '132%' --language en >/dev/null
"$NODE" -e '
  const fs = require("node:fs");
  const value = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
  if (value.language !== "en" || value.artLayout !== "portrait" || value.artScale !== "132%") process.exit(1);
' "$TMP/theme/theme.json"
PAYLOAD_JSON="$("$NODE" "$ROOT/scripts/injector.mjs" --check-payload --theme-dir "$TMP/theme")"
"$NODE" -e '
  const value = JSON.parse(process.argv[1]);
  if (!value.pass || value.themeName !== "Test theme" || value.imageBytes < 1) process.exit(1);
' "$PAYLOAD_JSON"

/bin/mkdir -p "$TMP/theme-es"
/bin/cp "$ROOT/assets/default-background.jpg" "$TMP/theme-es/background.jpg"
"$NODE" "$ROOT/scripts/write-theme.mjs" custom --output-dir "$TMP/theme-es" \
  --image background.jpg --language es >/dev/null
"$NODE" -e '
  const fs = require("node:fs");
  const value = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
  if (value.language !== "es") process.exit(1);
  if (value.name !== "Mi tema Codex Dream Skin") process.exit(1);
  if (value.projectLabel !== "◉  Seleccionar proyecto") process.exit(1);
' "$TMP/theme-es/theme.json"

"$NODE" "$ROOT/scripts/write-theme.mjs" reset-demo --output-dir "$TMP/theme" >/dev/null
[ ! -e "$TMP/theme" ]
"$NODE" "$ROOT/scripts/write-theme.mjs" reset-demo --output-dir "$TMP/theme-es" >/dev/null
[ ! -e "$TMP/theme-es" ]

CONFIG="$TMP/config.toml"
BACKUP="$TMP/theme-backup.json"
/usr/bin/printf '%s\n' \
  'model = "gpt-5"' \
  '' \
  '[desktop]' \
  'appearanceTheme = "system"' \
  'appearanceDarkCodeThemeId = "vscode-dark"' \
  'keepMe = true' > "$CONFIG"
/bin/cp "$CONFIG" "$TMP/original.toml"
"$NODE" "$ROOT/scripts/theme-config.mjs" install "$CONFIG" "$BACKUP" >/dev/null
/usr/bin/grep -q 'appearanceTheme = "dark"' "$CONFIG"
"$NODE" "$ROOT/scripts/theme-config.mjs" restore "$CONFIG" "$BACKUP" >/dev/null
/usr/bin/cmp -s "$CONFIG" "$TMP/original.toml"

/usr/bin/env -u HOME /bin/bash -c '. "$1/scripts/common-macos.sh"; [ -n "$HOME" ] && [ "$SKIN_VERSION" = "1.0.0" ]' _ "$ROOT"
"$ROOT/scripts/doctor-macos.sh" >/dev/null

printf 'PASS: syntax, English/Spanish themes, payload, config round-trip, HOME recovery, signature, and doctor checks.\n'
