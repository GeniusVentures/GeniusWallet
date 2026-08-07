# Two shipped GWControlTrack consumers are not keyboard-operable (WCAG 2.1.1 Level A)

**Found:** 2026-07-31, during `260731-kc5` (the Compute panel balance unit two-segment
control track).
**Status:** open. Pre-existing - NOT introduced by `260731-kc5`.
**Severity:** accessibility, Level A. AGENTS.md lists accessibility as something this repo
is explicitly not lazy about.

## The finding

- `_TimeframeTab` (`lib/components/gw_timeframe_segment.dart:118`) wraps a bare
  `GestureDetector`.
- `_FilterChip` (`lib/dashboard/home/widgets/transactions_slim_view.dart:801`) wraps a bare
  `GestureDetector`.

A `GestureDetector` is not focusable and does not respond to Enter or Space. Neither the
chart's timeframe segment nor the dashboard's transaction filter can be operated from a
keyboard at all. Check `_OrderToneChip` in `lib/screens/banxa_buy_screen.dart` too - if
`260731-jx5` built it the same way, it is a third instance and belongs in this same list.

## How it was found

`260731-kc5`'s own balance unit control (`_UnitSegment` in `compute_panel.dart`) uses
`InkWell` inside a transparent `Material` specifically for this reason - the `_UnitToggle`
it replaces already documented this in its own doc comment. Converging the balance unit
onto the shared `GWControlTrack` container meant deciding whether to also match the other
tracks' INPUT HANDLING, not just their geometry. The answer was no: matching would have
traded away a Level A property (keyboard operability) for a consistency CONVENTIONS.md
never asked for outside geometry. That decision is what surfaced this gap as worth filing
rather than silently accepting.

## The fix, so it is a short job

Swap each `GestureDetector` for `InkWell` inside `Material(type: MaterialType.transparency)`,
with `hoverColor: Colors.transparent` (because `GWHoverable` already owns the hover paint)
and `focusColor` left at its default so the keyboard focus indicator stays visible (WCAG
2.4.7). The pattern to copy is `_UnitSegment` in `compute_panel.dart`. Geometry does not
change, so `GWControlTrack` itself is untouched and no visual review is needed beyond
confirming the focus ring shows up in both themes.

## Why it is not urgent but is not nothing

It is Level A, it affects two of the dashboard's most-used controls (the chart's timeframe
selector and the transaction list's filter bar), and the fix is mechanical - but it is a
cross-file change to files a same-day quick task (`260731-jx5`) had just rewritten, so it
wants its own run rather than a rider on `260731-kc5`.

---

**CLOSED 2026-08-07**, verified against the tree at `e1d66b2`, not against the 2026-08-05 triage.
Fixed by `defe3b4` (merged in PR #221): `_TimeframeTab` and `_FilterChip` are now
`Semantics` + `InkWell`, so both take focus and respond to Enter/Space. `_PresetChip` and
`_modeChip` already used `InkWell`. Quick `260807-bxs` then deleted the Markets hero's own
private copy of the segment, so that surface inherits the fix instead of needing its own.
