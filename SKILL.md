---
name: codex-dream-skin-studio
description: Install, customize, apply, verify, repair, update, or restore a safe reversible theme for the official macOS Codex Desktop app. Use when someone wants to turn a personal image into a Codex home banner and full-task background, fix blurry or cropped player photos and off-center icons, switch between the bundled Spain and Argentina World Cup presets, preserve the native sidebar/composer/menus, or troubleshoot the verified loopback CDP theme session.
---

# Codex Dream Skin Studio

Turn an image into a live Codex Desktop theme without editing the official application bundle. Use the self-contained engine in `assets/engine`; do not depend on a separate project checkout.

## Language

Use English by default. Pass `--language es` to create Spanish interface copy, prompts, and World Cup preset text. Pass `--language en` explicitly when deterministic English output is required. Keep the Skill instructions and command output in English so the package remains broadly reusable.

## Scope

- Support macOS and the official signed Codex Desktop bundle `com.openai.codex`.
- Treat Claude Desktop and Gemini as separate adapters. Do not run this Codex injector against either app.
- Preserve native Codex interaction. This skill changes live styling and adds non-interactive decoration; it does not replace the interface with a screenshot.

## Load the references

Read [references/safety-and-qa.md](references/safety-and-qa.md) before any install, start, restart, verification, or restore.

Read [references/theme-authoring.md](references/theme-authoring.md) before selecting an image crop, creating a custom theme, or applying a World Cup preset.

## Resolve the skill

Resolve `SKILL_DIR` to the directory containing this `SKILL.md`. Use the path supplied by the skill catalog or invocation; never hard-code another user's home directory.

The command router is:

```bash
"$SKILL_DIR/scripts/dream-skin.sh" <action> [arguments]
```

Available actions are `test`, `install`, `customize`, `preset`, `start`, `verify`, `doctor`, `restore`, and `engine-path`.

## Workflow

### 1. Inspect before mutating

1. Confirm the host is macOS.
2. Confirm the official Codex app exists and is signed.
3. Run the bundled automated tests:

```bash
"$SKILL_DIR/scripts/dream-skin.sh" test
```

4. Run a non-live doctor check when an installation already exists:

```bash
"$SKILL_DIR/scripts/dream-skin.sh" doctor
```

If Codex is already open without the verified Dream Skin endpoint, do not restart it until the user explicitly authorizes a restart.

### 2. Install or update

Install the bundled engine without launching first:

```bash
"$SKILL_DIR/scripts/dream-skin.sh" install --no-launch
```

This installs a user-owned copy at `~/.codex/codex-dream-skin-studio`, creates reversible theme state under `~/Library/Application Support/CodexDreamSkinStudio`, and leaves the official app untouched.

### 3. Build the theme

For the Argentina preset:

```bash
"$SKILL_DIR/scripts/dream-skin.sh" preset argentina --language en --no-apply
```

For the Spain preset:

```bash
"$SKILL_DIR/scripts/dream-skin.sh" preset spain --language en --no-apply
```

For a user image:

```bash
"$SKILL_DIR/scripts/dream-skin.sh" customize \
  --image "/absolute/path/to/image.jpg" \
  --name "My Codex Theme" \
  --layout portrait \
  --position "right center" \
  --scale "100%" \
  --language en \
  --no-apply
```

Use `portrait` for a standing player or person. Use `cover` for a landscape image that should fill the home banner. Start portrait subjects at `100%`; increase scale only when the source contains excessive empty space.

For Spanish, use the same command with `--language es`. User-provided names, taglines, and quotes remain unchanged; generated defaults and preset copy are localized.

### 4. Apply safely

If Codex is closed, start the verified themed session:

```bash
"$SKILL_DIR/scripts/dream-skin.sh" start
```

If Codex is open without the verified endpoint, explain that applying requires a restart. Only after explicit authorization run:

```bash
"$SKILL_DIR/scripts/dream-skin.sh" start --restart-existing
```

Never bypass this authorization with process-killing commands.

### 5. Verify the real interface

Capture and verify the home route:

```bash
"$SKILL_DIR/scripts/dream-skin.sh" verify \
  --screenshot "/tmp/codex-dream-skin-home.png"
```

Then open a normal task and capture it without reloading:

```bash
"$SKILL_DIR/scripts/dream-skin.sh" verify \
  --screenshot "/tmp/codex-dream-skin-task.png"
```

Inspect both images. A machine pass is necessary but not sufficient. Confirm:

- Home: the entire subject is readable, the head is sharp, the subject is not accidentally cut in half, and card icons are centered.
- Task: the photo covers the full main canvas rather than only one side; messages, Outputs, sidebar, and composer remain readable and interactive.
- Both: no horizontal overflow, fake controls, rasterized UI, or decoration intercepting pointer events.

Finish with:

```bash
"$SKILL_DIR/scripts/dream-skin.sh" doctor --require-live
```

Require JSON fields `pass: true`, `officialAppSignatureValid: true`, `modifiesAppAsar: false`, and `live: true`.

### 6. Iterate on crop or clarity

When the subject is clipped or blurry:

1. Prefer a higher-resolution source over CSS sharpening.
2. Keep the long edge at roughly 2400–3200 px before import.
3. For a standing player, switch to `--layout portrait --scale "100%"`.
4. Adjust `--position` in small steps such as `"60% center"` or `"right 45%"`.
5. Reapply and recapture both home and task screenshots.

Do not claim the issue is fixed from config inspection alone.

### 7. Restore

Remove the live theme without changing the saved Codex base-theme values:

```bash
"$SKILL_DIR/scripts/dream-skin.sh" restore
```

For a full rollback after explicit restart authorization:

```bash
"$SKILL_DIR/scripts/dream-skin.sh" restore \
  --restore-base-theme \
  --restart-codex
```

Add `--uninstall` only when the user explicitly asks to remove the installed Dream Skin files.

## Report the result

Report the selected theme, whether a restart occurred, the live doctor JSON outcome, the screenshot paths, and any remaining crop or readability issue. State explicitly that the official app signature remains valid and `app.asar` was not modified.
