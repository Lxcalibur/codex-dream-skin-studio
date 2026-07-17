# Safety and live QA

## Non-negotiable safety boundaries

- Never modify, unpack, replace, repack, sign, or back up the official Codex `.app` or `app.asar`.
- Discover `com.openai.codex` on each launch. Do not assume the internal executable path survives an update.
- Use only the Node.js runtime bundled with Codex after validating the app and runtime signatures, OpenAI Team ID `2DC432GLL2`, architecture, and Node.js major version 20 or newer.
- Bind Chromium DevTools Protocol to loopback. Accept only a listener owned by Codex or a legitimate descendant and only an `app://` renderer with expected native shell markers.
- Launch the themed session with the dedicated profile at `~/Library/Application Support/CodexDreamSkinStudio/profile`. Chromium 136+ requires a non-default `--user-data-dir` for remote debugging.
- Never copy, move, or symlink the user's default Codex browser profile into the isolated Dream Skin profile.
- Consider loopback CDP locally privileged. Restore fully when the user no longer wants the themed session.
- Preserve sidebar, navigation, project selector, messages, approvals, attachments, menus, Outputs, composer controls, keyboard focus, and scrolling.
- Keep every decorative layer at `pointer-events: none`.
- Never restart or force-stop an already-running Codex instance without explicit user authorization.
- Stop a saved injector only after PID, executable, command line, script path, and process start time match the recorded state.
- Back up and restore only `appearanceTheme` and `appearanceDarkCodeThemeId`; preserve unrelated TOML values.

## Machine acceptance

Run:

```bash
"$SKILL_DIR/scripts/dream-skin.sh" doctor --require-live
```

The result must report:

- `pass: true`
- `live: true`
- `officialAppSignatureValid: true`
- `modifiesAppAsar: false`
- `isolatedProfile: true`
- a loopback port
- the expected theme name and non-zero image/payload sizes

## Home visual acceptance

- A real image banner is visible at least 320 × 160 px.
- The subject's face is sharp at normal display scale.
- A standing player's body is readable; the crop is deliberate rather than accidental.
- Two to four native suggestion cards remain visible.
- Every circular card icon is geometrically centered.
- The real project selector, sidebar, and composer remain visible.
- No horizontal overflow exists.

## Task visual acceptance

- The selected image extends across the full main task canvas.
- The photo is atmospheric behind the interface and does not become a fake UI layer.
- Messages and Outputs retain enough contrast.
- Sidebar, composer, approvals, attachments, menus, and scrollbars remain native and reachable.
- Narrow windows hide optional decoration before it overlaps essential controls.

## Release acceptance

1. Run the bundled tests successfully.
2. Install from a clean copy without using global Node.js or npm.
3. Complete install → theme creation → live verify → task verify → restore → reinstall.
4. Verify once after a renderer reload.
5. Capture real CDP screenshots and retain the doctor JSON.
6. Confirm strict code-signature validation still succeeds for the official Codex app.

## Troubleshooting order

1. Run `doctor`.
2. Read `~/Library/Application Support/CodexDreamSkinStudio/start-error.log`.
3. Read injector and app logs from the same directory.
4. Verify the recorded port belongs to Codex.
5. Reinstall the bundled engine with `--no-launch`.
6. Ask for restart authorization only if the live endpoint cannot be established without restarting Codex.

Do not start with destructive cleanup or broad process termination.
