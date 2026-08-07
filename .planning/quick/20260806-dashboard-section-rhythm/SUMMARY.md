---
phase: quick-260806-wys
plan: 01
type: execute
status: complete
completed: 2026-08-07
human_verified: 2026-08-07 by Jakub, on device, dark mode
commit: none - CLAUDE.md forbids commits, work is in the working tree
branch: redesign/navigation-260806
---

# 260806-wys - dashboard section rhythm

Jakub, reading the panels side by side on his iPhone: "w kazdej z sekcji jest box -> title -> i
reszta rzeczy w boxie, wiec te paddingi/gapy powinny byc takie same". Then, when the first framing
missed his point: "zobacz w Asset odleglosc miedzy borderem a 'Assets' a 'Assets' a tokenem
pierwszym jest taka sama - o to mi chodzilo".

**Approved on device 2026-08-07:** "tak border tytul jest ok - approved".

## What was actually wrong

The component introduced to guarantee this rhythm claimed in its own doc comment that it already
delivered "an identical title->panel-top padding AND title->first-row gap" across four panels. Half
of that was true: the box-to-title gap (R1) was 12 everywhere. The title-to-content gap (R2) was
**26 / 34 / 38 / 42.75 / 46** depending on the panel and was never once equal to R1.

The reason no amount of padding arithmetic had ever closed it: **every dashboard row is a
`ListTile`, and a `ListTile` does not size to its content.** It snaps to a default tile height (72
for a two-line tile with a leading widget) and centres the content inside. That centring slack is
real, unpadded whitespace sitting directly under the title, invisible in source, and it is what the
eye reads as the gap. `space8 + space4 = 24` was a belief about layout, not a measurement of it.

A second false derivation was found in `transactions_slim_view.dart:472-478`, which stated the
distance "is 24" and cited `GWTokenRow` - a widget neither panel renders. The Transactions panel had
then paid a real `space4` on its day label to match a number the panel it was matching never had.

## The fix

`GWSectionTitle` gained a `contentTopInset` parameter. Each call site now declares a fact about its
own content, and the component derives its bottom pad as
`max(0, kGWSectionTitleRenderedGap - kGWSectionTitleSlack - contentTopInset)`, so the RENDERED gap is
one number owned in one place. The ListTile centring slack is visible in source for the first time.

| Section | contentTopInset | pad | rendered gap |
| --- | --- | --- | --- |
| Compute, More news / Results, Results (empty), Transactions panel | 0 | `space8` | 26 |
| Next up | 8 | `space4` | 26 |
| All Markets | 12 | `space2` | 26 |
| Markets panel | 16.75 | 0 | 26.75 |
| Assets | 20 | 0 | 30 |

Markets and Assets floor at 0 because their content inset exceeds the 16 the pad can absorb.
**Assets at 30 is the section Jakub measured as already correct**, so that overshoot is the target,
not a residual.

**R1 = 12 at every site, unchanged.** He said "zachowaj padding ktory jest uzyty box vs title", so
R1 was an input to this task, never an output. Every resulting pad is an existing token.

## Why option B, since it was first presented wrongly

I initially told Jakub that option B "gives up per-section symmetry" - comparing R1's layout number
(12) against R2 without adding the host card's own 12pt padding, which the eye reads as part of the
border-to-title gap. Counting it:

```
visual above = cardPad(12) + edgePad(2) + slack(10) + ascent(~4)  ~= 28
visual below = slack(10) + bottomPad(16-C) + C + descent(~5)      ~= 31   for ALL C
```

So B is simultaneously cross-panel consistent AND per-section symmetric to the eye. Measured on
device beforehand: Assets 28.9 above / 31.3 below (the section he named as correct), Compute
27.9 / 17.7 (bottom-tight). **Option C - normalising the `ListTile` rows themselves - is withdrawn
as unnecessary**, and that withdrawal is recorded at the `coins_screen.dart` call site so it is not
rediscovered.

## Budget

Height probed across 8 states x 2 widths x 2 unit labels: max panel **306** against the 314 budget,
max card **332** against 340. `kDashboardPanelSlotHeight` did not move and no assertion was relaxed.

## Verification

- `flutter analyze` - 0 issues
- `flutter test` - **1035** passing (1018 baseline + 17 new)
- `test/components/gw_section_title_rhythm_test.dart` asserts the RENDERED gap at
  C = 0 / 8 / 12 / 16. A fixed pad passes the first case and fails the other three, which is exactly
  the regression that would otherwise creep back.
- On-device dark-mode walk - **approved by Jakub 2026-08-07**. Five of the eight call sites (Assets,
  Markets panel, All Markets, More news / Results, Next up) have no test harness and were covered by
  this step alone.

## Corrected, not edited around

Three comments asserting the old belief: `gw_section_title.dart` (the false "identical gap" claim),
`transactions_slim_view.dart` (the "distance is 24" derivation citing the wrong widget), and
`compute_panel.dart`'s restated figures.
