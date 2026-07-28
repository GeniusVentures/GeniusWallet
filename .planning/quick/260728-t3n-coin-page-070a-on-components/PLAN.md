---
task: 260728-t3n
title: "Coin page onto base components (sketch 070-A), glyphs to one accent"
sketch: 070
variant: A
created: 2026-07-28
commits: false   # CLAUDE.md: "Do not create commits"
---

# 070-A on the coin page

Sketch 070 winner **A · On components**, with the glyph sub-question answered by Jakub the same day:
**one accent**. Sketch 061 owns this page's chrome and is untouched here.

## Tasks

### 1 · Convert card

- `Token Price`: raw `TextField` with a notched `label:` Row → `GWTextField(readOnly, label: 'Token
  price', fill: surfaceSunken)`, the `READ-ONLY` chip moving to `suffix`.
  **Deviation from the sketch, stated:** `GWTextField.label` is a `String`, not a `Widget`, so the
  chip cannot sit on the label line without growing a parameter for one consumer - the same test
  everything else this week was held to. `suffix` is an existing parameter and puts the chip on the
  thing it describes.
- `Token Amount`: `labelText:` → `GWTextField(label: 'Token amount', focusRing: true, fill:
  surfaceSunken)`. Keeps `keyboardType: numberWithOptions(decimal: true)` and the live
  `_calculateTotalValue`.
- **Edge weights differ on purpose.** The editable field rests at `borderControl` (3.30:1, via
  `focusRing`); the read-only one keeps the component's `borderSubtle` default (1.32:1). A read-only
  display is not a control under 1.4.11, and the difference is information: the louder edge is the
  one you can type in. `focusRing` on the price field is explicitly rejected - `readOnly` fields
  still take focus in Flutter, so it would light a gradient promising an edit that cannot happen.
- `Total:` bare `bodyLarge` → a one-row `GWDetailGrid`.

### 2 · Info card

- `statRow` → real `GWDetailGrid` rows with `kGWDetailRowPadding`. Drops the hand-written 11/12
  padding, the `Divider(height: 1)` list and the bare `Column`.
- Address row → whole-row tap target, glyph at rest, `showAppSnackBar` confirm.
  **`_CopyRow` is NOT promoted.** It would reach 2 consumers, under the 3+ bar `GWKicker`,
  `GWSelectRow` and `GWWarningNote` cleared - and the two rows are not the same shape anyway (this
  one has a leading glyph and truncates 6…6; the receipt's chunks 8+8). Promotion would mean two new
  parameters for one extra consumer. A local row matching the receipt's *behaviour* is the call.
- All six glyphs → `brandPrimaryOnSurface`. The rainbow's own comment is replaced, not deleted, and
  carries the measurement.

### 3 · Check + gates

- One test: the six glyphs render ONE colour (a rainbow regression is invisible in dark, which is
  exactly how it survived), and the amount field is inside a `GWFocusRing`.
- `flutter analyze lib` = 59. `flutter test` from 355/1. Hot reload via the FIFO, never `R`.
- Record the inherited light-mode finding (`textSecondary` on the sunken well = 4.23:1 vs 4.5) as a
  `GWDetailGrid`-wide item for the light pass, not a fix here.
