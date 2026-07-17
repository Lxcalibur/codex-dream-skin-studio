# Theme authoring and image fitting

## Source image selection

- Prefer JPEG, PNG, HEIC, TIFF, or WebP under 50 MB.
- Prefer a long edge of 2400–3200 px. The importer converts to JPEG and caps the long edge at 3200 px.
- Prefer an original or properly licensed source. Keep attribution when redistributing a preset.
- Do not use a screenshot containing fake Codex controls or raster text intended to impersonate the interface.

## Language

- Use `--language en` for English. This is the default.
- Use `--language es` for Spanish.
- The language option localizes generated names, taglines, project labels, status copy, restart prompts, and bundled preset text.
- Explicit `--name`, `--tagline`, and `--quote` values are preserved in either language.

## Layout decision

Use `cover` when:

- the image is landscape;
- the background itself should fill the banner;
- losing some outer edge is acceptable.

Use `portrait` when:

- the subject is a standing player or person;
- preserving the full body on the home screen matters;
- the source has a narrow vertical aspect ratio.

The task route combines a darkened full-canvas copy with a contained portrait layer. This avoids the “photo occupies only half of the screen” failure while keeping the subject's face and body complete.

## Crop controls

- `--position "right center"`: good default when text sits on the left.
- `--position "60% center"`: shift the subject gradually instead of jumping between keywords.
- `--position "right 45%"`: raise or lower the focal point with a percentage.
- `--scale "100%"`: safe default for a standing portrait.
- `--scale "110%"` to `"125%"`: use only when the source includes excess margins.
- Allowed scale range is 80%–180%.

Always verify both home and task routes after changing position, layout, or scale.

## Clarity rules

- Replacing a low-resolution source is better than adding blur, sharpening, or contrast filters.
- Avoid scaling a small portrait far beyond its native size.
- Keep gradients strong enough for readable text but weak enough that the face and uniform remain recognizable.
- If only the face is soft, inspect the source at 100% before changing CSS.
- If the body disappears, fix `layout`, `scale`, and `position` before changing container dimensions.

## Custom command

```bash
"$SKILL_DIR/scripts/dream-skin.sh" customize \
  --image "/absolute/path/to/image.jpg" \
  --name "My Theme" \
  --tagline "A short live-text subtitle" \
  --quote "A SHORT QUOTE" \
  --accent "#75aadb" \
  --secondary "#ffffff" \
  --highlight "#f6b40e" \
  --layout portrait \
  --position "right center" \
  --scale "100%" \
  --language en \
  --no-apply
```

Colors must be six-digit hex values. The name, tagline, and quote remain live DOM text.

## Bundled World Cup presets

### Argentina

- High-resolution Lionel Messi portrait.
- Argentina blue/white/gold palette.
- Home route uses portrait containment at 100%.
- Task route uses a full-canvas backdrop plus a contained subject layer.

### Spain

- High-resolution Lamine Yamal portrait.
- Spain red/yellow palette.
- Home route uses portrait containment at 100%.
- Task route uses a full-canvas backdrop plus a contained subject layer.

The source and license records are stored at `assets/engine/assets/world-cup/ATTRIBUTION.md`.

Spanish example:

```bash
"$SKILL_DIR/scripts/dream-skin.sh" preset argentina --language es --no-apply
```

## Icon alignment

Card icons must be centered independently of the label layout:

- place the SVG absolutely at 50% / 50%;
- translate by -50% / -50%;
- reset inherited margins and flex offsets;
- verify optical centering in the screenshot, not only computed bounds.
