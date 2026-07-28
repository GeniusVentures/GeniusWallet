---
task: 260728-t3n
title: "Coin page onto base components (sketch 070-A), glyphs to one accent"
status: complete
sketch: 070
variant: A
date: 2026-07-28
commits: false   # CLAUDE.md: "Do not create commits"
analyze_lib: 59  # baseline
tests: "364 pass / 1 fail (from 355/1) - the single failure is the inherited local_wallet_storage_test.dart"
walk: pending
---

# 070-A shipped

Jakub, on a live walk of the coin page: *"lets come up with the design using base components we have
to match the rest of the app"* → sketch 070 → *"wez A na existing componentach bazowych"*.

## What changed

**Convert card.** Both fields left the notched Material floating label - the only pattern of its kind
in the app besides `custom_drop_down.dart` - for `GWTextField`, which puts the label above the box at
`labelMd`/`textSecondary`/`space4` like every other field the app ships. `Token amount` gained
`focusRing: true`, so the one editable control on the card lights the brand **gradient** instead of
the flat `brandPrimaryStrong` it lit before. That flat blue was structural rather than sloppy: **a
`BorderSide` takes a single `Color`, so no `InputBorder` can ever be a gradient**, which is the whole
reason `GWFocusRing` exists and why `GWTextField` grew the flag this morning in 260728-s9k. Both
fields take `fill: surfaceSunken`.

**`Total:` is no longer a caption.** It was a bare right-aligned `bodyLarge` - the card's one computed
answer and the only element on it with no structure at all. Now a one-row `GWDetailGrid`, so the
answer carries the same frame as the facts above it.

**Info card.** `statRow` was `GWDetailGrid` written out by hand - 11/12 padding (which is
`kGWDetailRowPadding` spelled in numbers), a 22px glyph slot, a bare `Column` with `Divider(height: 1)`
between children and no well around any of it - written days after the component shipped for the
receipt. Now it is the component.

**Address row.** The inline 15px `IconButton` is gone; the whole cell copies, the glyph is present at
rest, the confirmation is unchanged. The full address goes to the clipboard, never the `6…6` form the
row draws.

**Glyphs → one accent.** See below.

## Three decisions worth reading

**1 · The two Convert fields rest at DIFFERENT edge weights, on purpose.** The editable one is
`borderControl` (3.30:1) via `focusRing`; the read-only one keeps the component's `borderSubtle`
default (1.32:1). A read-only display is not a UI component under 1.4.11, and the difference is
information - the louder edge is the one you can type in. **`focusRing` on the price field was
rejected deliberately**: a `readOnly` field still takes focus in Flutter, so a gradient there would
promise an edit that cannot happen.

**2 · The READ-ONLY chip moved into `suffix`, not the label line.** Sketch 070-A drew it beside the
label. `GWTextField.label` is a `String`, not a `Widget`, and growing it for one consumer fails the
promotion test everything else this week was held to. `suffix` is an existing parameter and puts the
chip on the thing it describes. **Deviation from the sketch, flagged for the walk.**

**3 · `_CopyRow` was NOT promoted, and that is the finding.** Sharing the receipt's row would put it
at **two** consumers, under the 3+ bar `GWKicker`, `GWSelectRow` and `GWWarningNote` each had to
clear - and the two rows are not the same shape anyway: this one carries a leading glyph and
truncates `6…6`, the receipt's carries none and chunks 8+8 in four-character groups. Sharing would
mean two new parameters for one extra consumer. So `_CopyAddressRow` is local and shares the
**behaviour**, which is the part a user can tell apart. The ceiling is written on the class: two
implementations can drift and only a walk would notice; a third consumer makes the component worth
building, and at that point the glyph slot and the truncation strategy become its parameters.

## The glyph decision, and how it was made

Jakub picked **one accent** from a four-panel comparison in the sketch (rainbow/one-accent ×
dark/light, hard-coded so all four are visible at once). All six glyphs are now
`brandPrimaryOnSurface`.

**This replaced a rainbow that was Jakub's own earlier explicit request**, so the code comment carries
the measurement rather than quietly dropping the old one. Five of the six colours were raw constants
tuned against the dark canvas; on the light well (`#CFD4DB`) they collapse:

| glyph | dark | light |
|---|---|---|
| `statusSuccess` (Market Cap) | 10.80 | **1.25** |
| `brandTertiary` (Circulating) | 8.27 | **1.63** |
| `brandPrimaryStrong` (Address) | 7.84 | **1.72** |
| `statusError` (Total Supply) | 6.13 | **2.19** |
| `statusNeutral` (Volume) | 4.21 | 3.19 |
| `brandPrimaryOnSurface` (Network) | 10.25 | **4.23** |

**Network was the tell.** It is the only appearance-aware colour in the set (`#14C8FF` dark /
`#0A6885` light) and the only one that survives. So the real choice was five new light-mode tokens or
the one colour that already carries both.

**None of it is a WCAG failure** - every row is fully identified by its label, so the glyphs are
decorative under 1.4.11. It is legibility, plus one semantic gain: `statusError` red is the app's
ERROR tone and it was being spent on Total Supply, where nothing is wrong. **Accepted cost, stated:
the card reads quieter and rows lose per-row colour coding.**

## Two widgets became public

`_MarketDataInfo` → **`CoinInfoCard`**, `_ConvertSection` → **`CoinConvertCard`**. Only so the check
below can pump them without standing up a `WalletDetailsCubit`, a router and a 24-field Hive model.
One call site each, both inside this file, both documented as such. Not an abstraction - a rename
that made the rule testable.

## Check

`test/tokens/coin_page_components_test.dart`, 3 tests. **Both defects it guards are invisible in the
mode we develop in, which is exactly how they survived on a shipped screen.**

- **All six glyphs are ONE colour, and it is `brandPrimaryOnSurface`.** Asserted as a set of size 1,
  not as "all pass contrast" - a contrast assertion would still be satisfied by five different
  colours that each clear a bar in dark, which is precisely the state this replaced. It first counts
  six `SketchIcon`s, or the set could collapse to one for the wrong reason.
- **Exactly one `GWFocusRing` in the Convert card**, plus the three labels rendering as plain `Text`
  rather than an `InputDecoration` notch.
- **The whole Address row copies the full address** - tapping the *label*, not the glyph, and
  asserting first that the full address is NOT on screen.

## Out of scope, untouched

`TokenActionBar` (already a component with three real states; Send/Swap genuinely disabled per
D-01/D-02, More GNUS-gated), `_buildSectionTitle` (already `GWKicker`), the chart, the page's
chrome/route/frame (sketch **061**, still `winner: null`), and which fields the Info card shows.
The mobile 152-D path is preserved - `_buildInfoSection` and `_buildConvertSection` still return the
cards standalone.

## Recorded, not fixed

**`GWDetailGrid`'s key text is 4.23:1 on the light well, under 4.5.** Appended as item 7 to
`todos/pending/2026-07-22-light-mode-verification-backlog.md`. **Inherited, not introduced** - the
transaction receipt shipped the same pairing today, so it is the component's finding at every
consumer, not this screen's. Two candidate fixes noted there, neither costed; the second (lightening
`_surfaceSunkenLight`) has the bigger blast radius because `surfaceSunken` is also the control-track
fill, the PIN screen and every search well. Deferred per the standing dark-first order.

## Gates

`flutter analyze lib` **59** = baseline. `flutter test` **364 pass / 1 fail**, from 355/1; the single
failure is the inherited `local_wallet_storage_test.dart`, fully commented out since 2025-05-25 and
therefore missing a `main()`. Hot-reloaded live (6 libraries), no new exceptions in the log. No
commits, no worktree, per `CLAUDE.md`.

**WALK PENDING**, and three things to look at specifically: the READ-ONLY chip in its new `suffix`
position, the two fields' deliberately different resting edges side by side, and the Info card in
**light** mode - which is the whole reason the glyph decision was made.
