#!/bin/bash

set -euo pipefail
. "$(cd "$(dirname "$0")" && pwd -P)/common-macos.sh"

IMAGE=""
THEME_NAME=""
TAGLINE=""
QUOTE=""
ACCENT="#7cff46"
SECONDARY="#36d7e8"
HIGHLIGHT="#642a8c"
ART_POSITION="right center"
ART_LAYOUT="cover"
ART_SCALE="128%"
LANGUAGE="en"
APPLY_NOW="true"
RESET_DEMO="false"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --image) IMAGE="${2:-}"; shift 2 ;;
    --name) THEME_NAME="${2:-}"; shift 2 ;;
    --tagline) TAGLINE="${2:-}"; shift 2 ;;
    --quote) QUOTE="${2:-}"; shift 2 ;;
    --accent) ACCENT="${2:-}"; shift 2 ;;
    --secondary) SECONDARY="${2:-}"; shift 2 ;;
    --highlight) HIGHLIGHT="${2:-}"; shift 2 ;;
    --position) ART_POSITION="${2:-}"; shift 2 ;;
    --layout) ART_LAYOUT="${2:-}"; shift 2 ;;
    --scale) ART_SCALE="${2:-}"; shift 2 ;;
    --language) LANGUAGE="${2:-}"; shift 2 ;;
    --no-apply) APPLY_NOW="false"; shift ;;
    --reset-demo) RESET_DEMO="true"; shift ;;
    *) fail "Unknown customize argument: $1" ;;
  esac
done

case "$LANGUAGE" in
  en)
    IMAGE_PROMPT="Choose a theme image (a long edge of 2400 px or more is recommended)"
    NAME_PROMPT="Name this theme"
    DEFAULT_NAME="My Codex Dream Skin"
    DEFAULT_TAGLINE="Turn a favorite image into an interactive Codex workspace."
    DEFAULT_QUOTE="MAKE SOMETHING WONDERFUL"
    CANCEL_LABEL="Cancel"
    CONTINUE_LABEL="Continue"
    ;;
  es)
    IMAGE_PROMPT="Elige una imagen para el tema (se recomienda un lado largo de 2400 px o más)"
    NAME_PROMPT="Ponle un nombre a este tema"
    DEFAULT_NAME="Mi tema Codex Dream Skin"
    DEFAULT_TAGLINE="Convierte tu imagen favorita en un espacio de trabajo interactivo."
    DEFAULT_QUOTE="CREA ALGO MARAVILLOSO"
    CANCEL_LABEL="Cancelar"
    CONTINUE_LABEL="Continuar"
    ;;
  *) fail "Language must be en or es." ;;
esac

discover_codex_app
require_macos_runtime
ensure_state_root

if [ "$RESET_DEMO" = "true" ]; then
  "$NODE" "$SCRIPT_DIR/write-theme.mjs" reset-demo --output-dir "$THEME_DIR"
else
  if [ -z "$IMAGE" ]; then
    IMAGE="$(/usr/bin/osascript -e \
      'on run argv
         return POSIX path of (choose file with prompt (item 1 of argv) of type {"public.image"})
       end run' "$IMAGE_PROMPT")" \
      || fail "Image selection was cancelled."
  fi
  [ -f "$IMAGE" ] || fail "Selected image does not exist: $IMAGE"
  SOURCE_BYTES="$(/usr/bin/stat -f '%z' "$IMAGE")"
  [ "$SOURCE_BYTES" -le 52428800 ] || fail "Selected image is larger than 50 MB. Choose a smaller file."

  if [ -z "$THEME_NAME" ]; then
    THEME_NAME="$(/usr/bin/osascript -e \
      'on run argv
         return text returned of (display dialog (item 1 of argv) default answer (item 2 of argv) buttons {(item 3 of argv), (item 4 of argv)} default button (item 4 of argv))
       end run' "$NAME_PROMPT" "$DEFAULT_NAME" "$CANCEL_LABEL" "$CONTINUE_LABEL")" \
      || fail "Theme setup was cancelled."
  fi
  if [ -z "$TAGLINE" ]; then TAGLINE="$DEFAULT_TAGLINE"; fi
  if [ -z "$QUOTE" ]; then QUOTE="$DEFAULT_QUOTE"; fi

  /bin/mkdir -p "$THEME_DIR"
  /bin/chmod 700 "$THEME_DIR"
  image_name="background-$(/bin/date '+%Y%m%d-%H%M%S')-$$.jpg"
  temporary="$THEME_DIR/.${image_name}.tmp.jpg"
  prepared="$THEME_DIR/$image_name"
  cleanup_temporary() { /bin/rm -f "$temporary"; }
  trap cleanup_temporary EXIT
  /usr/bin/sips -s format jpeg -s formatOptions 84 -Z 3200 "$IMAGE" --out "$temporary" >/dev/null \
    || fail "macOS could not convert the selected image. Use PNG, JPEG, HEIC, TIFF, or WebP."
  [ -s "$temporary" ] || fail "The converted image is empty."
  PREPARED_BYTES="$(/usr/bin/stat -f '%z' "$temporary")"
  [ "$PREPARED_BYTES" -le 16777216 ] || fail "The prepared image is larger than 16 MB. Choose a simpler or smaller image."
  /bin/mv -f "$temporary" "$prepared"
  /bin/chmod 600 "$prepared"

  "$NODE" "$SCRIPT_DIR/write-theme.mjs" custom \
    --output-dir "$THEME_DIR" --image "$image_name" \
    --name "$THEME_NAME" --tagline "$TAGLINE" --quote "$QUOTE" \
    --accent "$ACCENT" --secondary "$SECONDARY" --highlight "$HIGHLIGHT" \
    --position "$ART_POSITION" --layout "$ART_LAYOUT" --scale "$ART_SCALE" \
    --language "$LANGUAGE"
  /usr/bin/find "$THEME_DIR" -maxdepth 1 -type f -name 'background-*' ! -name "$image_name" -delete
  trap - EXIT
fi

if [ "$APPLY_NOW" = "true" ]; then
  "$SCRIPT_DIR/start-dream-skin-macos.sh" --port 9341 --prompt-restart --language "$LANGUAGE"
fi

printf 'Codex Dream Skin Studio theme is ready.\n'
