---
quick_id: 261010-jzg
status: complete
requirements: [JZG-01, JZG-02, JZG-03]
key-files:
  modified: [lib/components/overlay/responsive_overlay.dart]
  created: [test/components/mobile_overlay_dock_gap_test.dart]
commits: [59df37c5]
actuals: {tokens: 6000, tasks: 2, commits: 1}
completed: 2026-10-10
---

# Quick 261010-jzg: phone pages run under the Swap dock

The phone body runs to the bar's painted top edge (y=764 at 390x844), not the top of the bar's box (738). The Swap dock now overlaps the page and there's no grey band.

## What changed
- `MobileOverlay`'s Scaffold sets `extendBody: true`, and its body is a new `_MobileShellBody`. That widget pads by Scaffold's injected bottom padding minus `_kDockOverhang`, then removes the padding so pages' SafeArea stays at 0.
- `_MobileTabBar`, the constants and the inset cap are unchanged. The single-child Stack stays, with its comment shortened and the plan id removed.

## Verification
- RED on the old code: the body bottom was 738 (expected 764) and the strip tap count was 0 (expected 1). Both were checked separately.
- GREEN: one test checks the body bottom (764), the strip tap reaching the page, the keyboard case (544, no band) and the dock tap opening /swap.
- `flutter analyze`: "No issues found!" and exit 0. Brace and raw-colour checks: exit 0. Both files are i/lf.
- Full suite: `00:49 +2549 ~6: All tests passed!`

## Deviations
None.

## Walk note
Android 1080x2400: check /dashboard, /swap and /send for no grey band above the bar, and that no button label sits under the dock.

## Self-Check: PASSED
