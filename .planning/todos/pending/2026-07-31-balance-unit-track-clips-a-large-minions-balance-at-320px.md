# The balance unit two-segment track clips a large minions balance at the realistic 320px panel width

**Found:** 2026-07-31, during `260731-kc5` (the Compute panel balance unit two-segment
control track, sketch 170 scheme B), while writing
`test/dashboard/compute_balance_unit_track_test.dart`'s width-cost group.
**Status:** open. Decision required from Jakub - accept the cost, or fall back to scheme A.
**Severity:** cosmetic/UX, not a bug or a11y issue - the row hard-clips rather than
overflows, as it already did before this task (see below).

## What

Scheme B's two-segment track (`GNUS`/`MIN`) is wider than the old single-label
`_UnitToggle` it replaces (`~44px`/`~63px`). The balance row is a fixed-width tile, so the
wider track leaves less room for the animated balance number before
`_BalanceTile`'s `SingleChildScrollView` + `NeverScrollableScrollPhysics` hard-clips it
(`compute_panel.dart`, unchanged behaviour - it already clipped long balances before this
task; this task makes the clip start earlier / go further).

## Measured 2026-07-31

Real `Inter-Bold` font metrics (the font `GeniusWalletTypography.numericDisplay` actually
requests), fixture balance `987,654.32` minions - a plausible large balance, not a
pathological one.

| Panel width | Track width | Number wants | Viewport gets | Clipped by |
|---|---|---|---|---|
| 320px (realistic two-column width) | 102.24px | 178.69px | 157.76px | **~20.9px (~1 tabular digit)** |
| 290px (deliberate stress case, below production reach) | 102.24px | 178.69px | 127.76px | **~50.9px (~2-3 tabular digits)** |

The 320px figure is the one that matters - it is the width production actually reaches
(`compute_panel_height_test.dart`'s own derivation). The 290px figure is a stress case that
exists to catch line-wrap regressions, not a width the dashboard's two-column layout ever
produces.

## Why this is not fixed here

The plan that built this track (`260731-kc5-PLAN.md`) explicitly anticipated this exact
outcome and named the decision as Jakub's, not the executor's: narrowing the track's chip
padding below `space4` (8px) would break the conformance with the app's other three
`GWControlTrack` consumers that is the entire argument for adopting scheme B in the first
place, and relabeling `MIN` back to a longer form only makes the clip worse. Neither is an
acceptable silent fix.

## The two options, both already named in sketch 170

1. **Accept the clip.** It is a ~1 digit cost at the realistic width, not new behaviour in
   kind (the row already clipped, this task made the threshold slightly lower) - a
   plausible-but-uncommon balance loses its last visible digit. `test/dashboard/compute_balance_unit_track_test.dart`'s
   width-cost group already RECORDS this in a passing test (asserted range, not asserted
   away) so it cannot silently drift without someone noticing.
2. **Fall back to scheme A** (`.planning/sketches/170-balance-unit-toggle/README.md`) - a
   ~18px swap glyph beside the single unit label, instead of the two-segment track. Sketch
   170 names this as the runner-up specifically for the case where scheme B's width cost is
   rejected. This is a different plan, not a widening of `260731-kc5`.

## Guard in place meanwhile

`test/dashboard/compute_balance_unit_track_test.dart`'s `'the width cost is measured, not
estimated, at both widths'` group asserts the clip falls within the measured range above at
both widths - it is GREEN today, and it is written to fail (loudly, with the measured
numbers in the failure reason) if the clip meaningfully grows OR shrinks/resolves, so this
finding cannot be silently lost either direction.
