---
created: 2026-07-22T13:20:00.000Z
title: Responsive type/button scale + stop scattering custom styles across pages
area: ui
severity: major
files:
  - lib/theme/genius_wallet_typography.dart
  - lib/components/buttons/gw_button.dart
  - test/freeze_rule_test.dart
---

## The ask (Braian, 2026-07-22, during 06-02's walk)

> "We need to make the fonts smaller for the mobile version, it looks too big, same thing for
> buttons. We should have a way to have reusable components and do the changes in a single place in
> those reusable components and not having too many custom styles in each page. We need to revise
> all texts there for looking good at cellphone / tablet / desktop versions."

Two distinct problems, raised together:

1. **No responsive type or control scale.** Sizes that read correctly on desktop are too large on
   mobile.
2. **Styling is scattered per-page**, so fixing #1 today would mean touching dozens of files instead
   of one.

## Measured 2026-07-22 — this is not an impression

| Signal | Count |
|---|---|
| Inline `TextStyle(` in `lib/` outside `lib/theme/` | **150**, across **56 files** |
| Hardcoded `fontSize:` outside `lib/theme/` | **108** |
| Breakpoint awareness in `GeniusWalletTypography` | **zero** — no `context`, no `Breakpoint` reference |

`genius_wallet_typography.dart` is a **flat, fixed scale**: 32 / 28 / 24 / 20 / 18 / 16 / 14 / 13,
hardcoded. There is no mobile variant for a screen to opt into even if it wanted one. So every
screen that needed smaller text on a phone had no choice but to hand-roll a `TextStyle` — which is
the direct cause of problem #2.

## ⛔ THE TRAP — do not reach for the obvious fix

**`AutoSizeText` and `FittedBox` are BANNED.** `test/freeze_rule_test.dart` fails with a file:line if
either appears in a dashboard-reachable source.

They caused a **hard app freeze**: a font size derived continuously from constraints produced a
distinct `TextStyle` every frame during a drag-resize, thrashing skia's fixed-size `ParagraphCache`
(`SkLRUCache<ParagraphCacheKey>::remove` at 1580–1953 stack samples). Layout never settled, the
frame never committed, and the window was dead until killed. It took **two** attempts to fix —
`37639d5` quantised the height-derived size but left `AutoSizeText` free to re-fit on WIDTH, and the
app froze again the same afternoon.

**The binding rule: no dimension may be derived continuously from constraints.** Booleans and
literals only.

Therefore the responsive scale must be **discrete steps selected by breakpoint** — e.g. a
`GeniusWalletTypography.of(context)` (or a `GWTypography` ThemeExtension) returning a *different
fixed size* per breakpoint band. A bounded set of sizes is safe; a computed one is the bug.

**Related exposure:** `lib/` still contains **24 files using `AutoSizeText`**, and `freeze_rule_test`
only scans dashboard-reachable directories. **Onboarding and the generated `*.g.dart` components are
currently unguarded** and are equally capable of this hang. Widening `_scannedDirs` to `lib/` is the
stated upgrade path — worth doing as part of this work, since this work will touch text everywhere.

## Shape of the fix (not yet planned)

1. Give the type scale breakpoint bands (phone / tablet / desktop), resolved from `GeniusBreakpoints`
   — discrete, never computed.
2. Same for control sizing — `GWButton` already has `GWButtonSize`; the question is whether a size
   band should be *implied* by breakpoint rather than passed per call site.
3. Sweep the 150 inline `TextStyle(` occurrences onto the scale. Expect a long tail where a call
   site is doing something legitimately bespoke; those should be rare and deliberate.
4. Widen `freeze_rule_test`'s `_scannedDirs` to `lib/` once the 24 `AutoSizeText` uses are converted.

## Scope note

**This is NOT a Phase 06 defect and must not be treated as one.** It is cross-cutting, it predates
the onboarding re-skin, and it touches 56 files. It needs its own phase (or at minimum its own
plan), with the freeze rule as an explicit constraint in the brief. Raised during 06-02's walk only
because onboarding is where it was noticed.
