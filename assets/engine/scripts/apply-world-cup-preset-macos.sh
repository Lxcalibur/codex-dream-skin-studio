#!/bin/bash

set -euo pipefail
. "$(cd "$(dirname "$0")" && pwd -P)/common-macos.sh"

PRESET="${1:-}"
if [ "$#" -gt 0 ]; then shift; fi
APPLY_NOW="true"
LANGUAGE="en"
while [ "$#" -gt 0 ]; do
  case "$1" in
    --language) LANGUAGE="${2:-}"; shift 2 ;;
    --no-apply) APPLY_NOW="false"; shift ;;
    *) fail "Unknown World Cup preset argument: $1" ;;
  esac
done

case "$LANGUAGE" in
  en|es) ;;
  *) fail "Language must be en or es." ;;
esac

case "$PRESET" in
  spain)
    SOURCE_IMAGE="$PROJECT_ROOT/assets/world-cup/lamine-yamal-spain-2025.jpg"
    if [ "$LANGUAGE" = "es" ]; then
      THEME_NAME="España · Yamal, tormenta dorada"
      TAGLINE="Juega con pasión, precisión y creatividad."
      QUOTE="PASIÓN · PRECISIÓN · GLORIA"
    else
      THEME_NAME="Spain · Yamal Golden Storm"
      TAGLINE="Play with passion, precision, and creativity."
      QUOTE="PASSION · PRECISION · GLORY"
    fi
    ACCENT="#f2c14e"
    SECONDARY="#d71920"
    HIGHLIGHT="#8f1620"
    ART_POSITION="82% center"
    ART_SCALE="100%"
    ;;
  argentina)
    SOURCE_IMAGE="$PROJECT_ROOT/assets/world-cup/lionel-messi-world-cup-2022-high-res.jpg"
    if [ "$LANGUAGE" = "es" ]; then
      THEME_NAME="Argentina · Messi campeón del mundo"
      TAGLINE="Deja que la inspiración fluya en celeste y blanco."
      QUOTE="CORAZÓN · MAGIA · GLORIA"
    else
      THEME_NAME="Argentina · Messi World Champion"
      TAGLINE="Let inspiration flow in sky blue and white."
      QUOTE="HEART · MAGIC · GLORY"
    fi
    ACCENT="#75bde8"
    SECONDARY="#f5f7f4"
    HIGHLIGHT="#d6ad4b"
    ART_POSITION="82% center"
    ART_SCALE="100%"
    ;;
  *)
    fail "Usage: $(basename "$0") <spain|argentina> [--language en|es] [--no-apply]"
    ;;
esac

[ -f "$SOURCE_IMAGE" ] || fail "World Cup preset artwork is missing: $SOURCE_IMAGE"
discover_codex_app
require_macos_runtime
ensure_state_root

/bin/mkdir -p "$THEME_DIR"
/bin/chmod 700 "$THEME_DIR"
IMAGE_NAME="$PRESET-world-cup.jpg"
TEMPORARY="$THEME_DIR/.$IMAGE_NAME.tmp.jpg"
PREPARED="$THEME_DIR/$IMAGE_NAME"
cleanup_temporary() { /bin/rm -f "$TEMPORARY"; }
trap cleanup_temporary EXIT

/usr/bin/sips -s format jpeg -s formatOptions 86 -Z 3200 "$SOURCE_IMAGE" --out "$TEMPORARY" >/dev/null \
  || fail "macOS could not prepare the $PRESET World Cup artwork."
[ -s "$TEMPORARY" ] || fail "The prepared $PRESET World Cup artwork is empty."
/bin/mv -f "$TEMPORARY" "$PREPARED"
/bin/chmod 600 "$PREPARED"

"$NODE" "$SCRIPT_DIR/write-theme.mjs" custom \
  --output-dir "$THEME_DIR" --image "$IMAGE_NAME" \
  --name "$THEME_NAME" --tagline "$TAGLINE" --quote "$QUOTE" \
  --accent "$ACCENT" --secondary "$SECONDARY" --highlight "$HIGHLIGHT" \
  --position "$ART_POSITION" --layout portrait --scale "$ART_SCALE" \
  --language "$LANGUAGE"
/usr/bin/find "$THEME_DIR" -maxdepth 1 -type f -name '*-world-cup.jpg' ! -name "$IMAGE_NAME" -delete
trap - EXIT

if [ "$APPLY_NOW" = "true" ]; then
  "$SCRIPT_DIR/start-dream-skin-macos.sh" --prompt-restart --language "$LANGUAGE"
fi

printf 'Applied World Cup preset: %s\n' "$THEME_NAME"
