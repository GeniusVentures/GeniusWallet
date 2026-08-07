# Every GWControlTrack consumer's unselected label fails WCAG AA on surfaceSunken in light mode

**Found:** 2026-07-31, during `260731-kc5` (the Compute panel balance unit two-segment
control track), while writing `test/theme/compute_contrast_test.dart`'s new "balance unit
track segments" group - the first test in the repo to measure this pairing.
**Status:** open. Pre-existing - NOT introduced by `260731-kc5`.
**Severity:** accessibility. AGENTS.md lists accessibility as something this repo is
explicitly not lazy about; the user's own standing WCAG-contrast rule requires AA in both
themes and every state.

## What

`GWControlTrack` (`lib/components/gw_control_track.dart`) fills its container with
`gw.surfaceSunken`. Every consumer paints its UNSELECTED chip label in `gw.textSecondary`
directly on that fill (selected chips are unaffected - they sit on a different, opaque
background: a brand gradient, `surfaceMenu`, or similar):

- `_TimeframeTab` (`lib/components/gw_timeframe_segment.dart:75`)
- `_FilterChip` (`lib/dashboard/home/widgets/transactions_slim_view.dart:799`)
- `_UnitSegment` (`lib/dashboard/compute/compute_panel.dart`, new in `260731-kc5`)
- (check `_OrderToneChip`/Buy GNUS orders track too if `260731-jx5` built it the same way)

`gw.textSecondary`'s light-mode value (`0xFF5A606E`) was tuned against the app's page and
card canvases - it clears 6.3:1 there (`gw_colors.dart`'s own "AA fix" comment) - not
against `surfaceSunken` (`0xFFCFD4DB`, the darkest gray step). Nobody had painted BODY TEXT
directly on `surfaceSunken` before these tracks existed. `gw_colors.dart:192-195` already
documents the identical ceiling for a different token (`brandPrimaryOnSurface`, measured
4.23:1 on the same surface): "clears the 3:1 non-text floor but not 4.5:1 body text...
Ceiling: no current consumer paints body text on surfaceSunken." That ceiling is now
crossed, silently, by every control-track chip's unselected label.

## Measured 2026-07-31

`contrastRatio(gw.textSecondary, gw.surfaceSunken)`. Threshold is **4.5:1** - the chip
label is 12px `w600`, and WCAG large text starts at 18.66px bold, so 12px bold does not
qualify for the 3:1 allowance.

| Mode | Ratio |
|---|---|
| dark | 6.20 - passes |
| light | **4.23** - fails |

## Why it is not fixed here

`260731-kc5`'s own argument for adopting `GWControlTrack` is conformance - the balance
unit track is supposed to look and behave identically to the timeframe segment and the
transaction filter bar. Picking a different, one-off foreground token for only the new
segment would break exactly that conformance (three tracks would read one way in light
mode, the balance unit a different way) while leaving the other two/three consumers
unfixed. The real fix touches `gw_colors.dart` (a darker light-mode `textSecondary`, or a
new `surfaceSunken`-specific muted-text token) and moves every consumer that reads it at
once - out of `260731-kc5`'s fenced files (`compute_panel.dart` / `wallet_overview.dart`
only). It is also light-mode-only (dark clears 6.2:1) - this project's standing policy is
dark mode first, light deferred to its own pass, not stalled on here.

## Upgrade path

Mirror the `statusWarningText` precedent
(`.planning/todos/pending/2026-07-29-status-pill-success-error-fail-aa-in-light-mode.md`):
add a `surfaceSunken`-calibrated muted-text token to `GWColors` (or darken light-mode
`textSecondary` if an app-wide audit shows no regression elsewhere it is used), repoint
`_TimeframeTab`, `_FilterChip`, `_UnitSegment` and any other `GWControlTrack` consumer's
unselected label to it, then tighten
`test/theme/compute_contrast_test.dart`'s light-mode assertion from the current measured
floor (4.2) back up to 4.5 and delete this todo.

## Guard in place meanwhile

`compute_contrast_test.dart`'s new group asserts dark mode at the real 4.5:1 AA floor and
light mode at the measured 4.2 floor (not weakened further, not silently dropped) - visible
in the test's own comment rather than hidden. No test covered this pairing for
`_TimeframeTab` or `_FilterChip` before this todo; this file is the first.

---

**CLOSED 2026-08-07**, verified against the tree at `e1d66b2`, not against the 2026-08-05 triage.
Fixed by `defe3b4` (merged in PR #221): a dedicated `textMutedOnSunken` token replaced
`textSecondary` on control-track labels, pinned by `test/theme/control_track_contrast_test.dart`
in both modes. The Markets hero inherited it when `260807-bxs` folded its private segment onto
the shared component.
