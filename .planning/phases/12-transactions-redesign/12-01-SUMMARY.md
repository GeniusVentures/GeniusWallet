---
phase: 12-transactions-redesign
plan: 01
subsystem: dashboard/transactions
tags: [badges, theme, accessibility, wcag, svg]
requires: [GWColors, GeniusWalletColors, flutter_svg, test/theme/theme_contrast_test.dart]
provides:
  - TransactionBadgeKind
  - TransactionBadgeSpec
  - badgeSpec
  - badgeGlyphColor
  - badgeGlyph
  - TransactionBadge
  - GeniusWalletColors.statusNeutral
affects: [12-03 (row), 12-04 (filter chips)]
tech-stack:
  added: []
  patterns:
    - "Computed glyph colour (white-vs-ink by measured contrast) instead of a hand-maintained per-kind table"
key-files:
  created:
    - lib/dashboard/home/widgets/transaction_badge.dart
    - assets/images/pickaxe.svg
    - test/dashboard/transaction_badge_test.dart
  modified:
    - lib/theme/genius_wallet_colors.dart
decisions:
  - "statusNeutral stays a mode-invariant static, NOT a GWColors field — the glyph is computed from the fill so the pair is AA-correct in both appearances without a second appearance-aware token"
  - "Glyph colour is computed, never tabled — statusSuccess flips ink→white between appearances and a fixed table would silently fail one"
metrics:
  duration: ~25 min
  completed: 2026-07-22
requirements: [TX-02]
status: complete
---

# Phase 12 Plan 01: Badge foundation Summary

One glyph/colour table covering all seven `TransactionType` values plus `pending` and `failed`,
an 18px `TransactionBadge` that renders it, the Slate fill token, the pickaxe asset, and a test
that measures the AA claim in both appearances rather than asserting it in a comment.

## What was built

**`GeniusWalletColors.statusNeutral` = `#64748B`** — the Slate fill sketch 012 picked for Sent and
Escrow (amber already means Pending, red already means Failed; reusing either would make a
successful send read as a problem). Added inside the existing `// Status` block, directly after
`statusWarning`. Doc comment carries the `ponytail:` note: FILL ONLY, mode-invariant, deliberately
not in `GWColors`; upgrade path is promotion to `GWColors` if a text consumer ever appears.

**`assets/images/pickaxe.svg`** — 24×24, `fill="none"`, `stroke="#000000"`, `stroke-width="3.2"`,
round caps/joins, the four `d` values copied verbatim from `P.pickaxe` in
`.planning/sketches/014-transactions-final/index.html`. Literal black stroke because the call site
recolours every non-transparent pixel via `ColorFilter.mode(..., BlendMode.srcIn)`. No
`pubspec.yaml` change — `assets/images/` is already declared (line 72).

**`lib/dashboard/home/widgets/transaction_badge.dart`** (~175 lines) exposes:
- `TransactionBadgeKind` — 9 values: sent, received, mint, job, escrow, swap, purchase, pending, failed
- `TransactionBadgeSpec` — immutable `{fill, icon?, svgAsset?, label}`, constructor asserts exactly one of icon/svgAsset
- `badgeSpec(kind, gw)` — the single table both 12-03 and 12-04 read
- `badgeGlyphColor(fill)` — picks whichever of white / `textOnBrand` measures higher against the fill
- `badgeGlyph(spec, {color, size})` — paints an `IconData` or an SVG, so callers never read `spec.icon` directly
- `TransactionBadge` — 18px circle, 2px ring defaulting to `gw.surfaceElevated` (never white), glyph at 11px, wrapped in `Semantics(label: spec.label)`

**`test/dashboard/transaction_badge_test.dart`** — 25 pure unit tests, no widget pumping, no asset
loading. Imports the existing `contrastRatio` from `test/theme/theme_contrast_test.dart` (no third
implementation added).

## Measured glyph colour per kind, per appearance

Real output from `Color.computeLuminance()` via the shared `contrastRatio` helper. AA floor 4.5:1.

| Kind | Dark fill | Dark glyph | Ratio | Light fill | Light glyph | Ratio |
|---|---|---|---|---|---|---|
| sent | `#64748B` | white | 4.76 | `#64748B` | white | 4.76 |
| received | `#0AD89C` | `#000B18` | 10.66 | `#07875F` | white | 4.53 |
| mint | `#C28FFF` | `#000B18` | 8.17 | `#C28FFF` | `#000B18` | 8.17 |
| job | `#0AAEE6` | `#000B18` | 7.74 | `#0AAEE6` | `#000B18` | 7.74 |
| escrow | `#64748B` | white | 4.76 | `#64748B` | white | 4.76 |
| swap | `#64748B` | white | 4.76 | `#64748B` | white | 4.76 |
| purchase | `#0AD89C` | `#000B18` | 10.66 | `#07875F` | white | 4.53 |
| pending | `#FFC42E` | `#000B18` | 12.43 | `#FFC42E` | `#000B18` | 12.43 |
| failed | `#FF4D4D` | `#000B18` | 6.05 | `#D92D2D` | white | 4.81 |

Every pairing clears AA in both appearances. Nothing had to be substituted; no colour from the
design contract failed.

**The two flips are why the colour is computed and not tabled:**
- `received` / `purchase` flip **ink → white** (statusSuccess `#0AD89C` → `#07875F`)
- `failed` flips **ink → white** (statusError `#FF4D4D` → `#D92D2D`)

A fixed per-kind glyph colour would have been correct in exactly one appearance.

**Two thin margins to watch if a palette edit is ever proposed:** light `received`/`purchase` at
4.53 and dark/light `sent`/`escrow`/`swap` at 4.76. Both are above the floor but have almost no
headroom — the test will catch a darkening of white or a lightening of the fill immediately.

## Where the implementation diverges from the sketch drawing (for 12-06's walk)

1. **`failed` glyph colour differs from sketch 014.** The sketch's palette table sets
   `failed: { f:'#FF4D4D', g:'#FFFFFF' }` — white on red measures **3.27:1**, i.e. the sketch itself
   still carries the k81 / 05-VERIFICATION Gap-1 regression. `badgeGlyphColor` picks ink (6.05:1)
   instead. This is the plan working as designed, but it means the shipped failed badge will look
   darker-glyphed than the HTML mockup. Do not "fix" it back.
2. **Sketch glyph colours are per-kind bespoke inks** (`#04241A` on received, `#1B0733` on mint,
   `#3A2A00` on pending); the implementation uses the single `textOnBrand` `#000B18` for all ink
   cases, per the plan. Visually near-identical, slightly cooler.
3. **`Icons.north_east` / `Icons.south_west` vs the sketch's `P.up` / `P.down`.** The sketch draws a
   diagonal line plus an open polyline arrowhead (a hollow "arrow out" mark). Material's
   `north_east` / `south_west` are **solid filled triangular arrowheads** on a shaft. Same semantic,
   heavier visual weight. Worth an eyeball at 11px against the lighter stroked pickaxe.
4. **`Icons.dns` vs `P.server`.** `dns` is Material's server rack — two stacked rounded rects with
   an indicator dot, which is what the sketch draws. Closest match in the set; no FontAwesome import
   needed. It is a *filled* glyph though, so it reads heavier than the sketch's 3.2-stroke outline.
5. **Pickaxe stroke weight at render size.** The sketch renders the pickaxe in a 9px box; the badge
   renders it at 11px. With `stroke-width="3.2"` in a 24 viewBox the effective stroke goes from
   ~1.2px (sketch) to ~1.47px (app) — slightly bolder than the mockup. Intentional side effect of
   the 11px glyph size the plan specifies; flag only if it looks blobby next to the filled Material
   icons.

Net for the walk: the mint pickaxe is the only stroked glyph among nine; the other eight are filled
Material icons. If the row looks inconsistent, that mismatch is the reason — not a bug.

## Deviations from Plan

**1. [Rule 1 - Bug] `Container` given `alignment: Alignment.center`**
- **Found during:** Task 2
- **Issue:** The plan specifies `Container(width: 18, height: 18)` with a child and no alignment. A
  `Container` with fixed width/height and no alignment passes **tight** constraints to its child.
  An `Icon` survives that (it centers internally), but `SvgPicture.asset(width: 11, height: 11)`
  under tight 14×14 constraints stretches to fill, so the pickaxe would have painted over the ring.
- **Fix:** added `alignment: Alignment.center`, which wraps the child in an `Align` and hands it
  loose constraints so it sizes itself at 11px. Commented in place.
- **Files modified:** `lib/dashboard/home/widgets/transaction_badge.dart`
- **Commit:** none — see below.

**2. [Scope] No commits created.**
- `./CLAUDE.md` says "Do not create commits" and the plan's `<objective>` repeats it. All work is
  left unstaged in the working tree. The executor's normal per-task atomic-commit protocol was
  suppressed for every task, and no `git add` was run.

**3. [Style] File is ~175 lines, not "under ~140".**
- The `switch` over nine kinds with `dartfmt`'s trailing-comma expansion plus the decision comments
  (mint-vs-job override, swap/purchase provenance, the k81 rationale on `badgeGlyphColor`) push it
  over. No extra abstraction was added; the overage is entirely the table and its comments.

## Verification actually run

| Check | Command | Result |
|---|---|---|
| Task 1 analyze | `flutter analyze lib/theme/genius_wallet_colors.dart` | **No issues found!** (2.8s) |
| Task 1 asset | `test -f assets/images/pickaxe.svg && grep -c 'viewBox="0 0 24 24"'` | file exists, `1` |
| Task 2 analyze | `flutter analyze lib/dashboard/home/widgets/transaction_badge.dart` | **No issues found!** (2.1s) |
| Task 3 test | `flutter test test/dashboard/transaction_badge_test.dart` | **+25: All tests passed!** — 18 of them are the 9 kinds × 2 appearances AA group |
| No regression | `flutter test` | `+54 -1` — 54 pass (was 29 before this plan; +25 is exactly this plan's new tests). The single failure is the pre-existing `test/local_wallet_storage_test.dart`: *"Missing definition of `main` method"* — the file is entirely commented out. Not caused by this plan. |

**Extra check, not in the plan (throwaway, removed after running):** the plan's test deliberately
avoids asset loading, which means a malformed SVG path would render as an empty picture and no test
would notice. I ran a one-off probe — `vg.loadPicture(SvgStringLoader(<file contents>), null)` — to
confirm `flutter_svg` parses the file: `size=Size(24.0, 24.0)`, non-null picture. The probe file was
deleted; `git status` is clean of it.

## Not verified

- **The badge has never been rendered on screen.** No app run, no golden, no widget pump. Nothing
  consumes `TransactionBadge` yet — 12-03 is its first caller. The ring-against-coin-art look, the
  11px glyph legibility, and the pickaxe's visual weight next to the filled Material icons are all
  open until 12-03 lands and 12-06 walks it.
- **Light mode is measured, not seen.** The 4.53 and 4.76 pairings pass the arithmetic; whether a
  4.53 glyph reads comfortably at 11px on a white-card panel is a human judgement the walk owes.

## Success criteria

- [x] Nine badge kinds covering all seven `TransactionType` values plus `pending` and `failed`
- [x] Every kind clears 4.5:1 glyph-vs-fill in both appearances, proven by a passing test
- [x] Mint = pickaxe (SVG), Job = `Icons.dns`; fills are the sketch 012/013 values, pinned by test
- [x] Ring defaults to `gw.surfaceElevated`, not white
- [x] No new package, no `pubspec.yaml` change, no commit created

## Self-Check: PASSED

- `lib/dashboard/home/widgets/transaction_badge.dart` — FOUND
- `assets/images/pickaxe.svg` — FOUND
- `test/dashboard/transaction_badge_test.dart` — FOUND
- `GeniusWalletColors.statusNeutral` — present in `lib/theme/genius_wallet_colors.dart`
- Commits — intentionally none (CLAUDE.md gate); nothing staged.
