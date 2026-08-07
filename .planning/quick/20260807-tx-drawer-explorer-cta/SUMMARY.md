---
phase: quick-260807-exp
plan: 01
type: execute
status: complete
completed: 2026-08-07
decision: "Task 2 answered by Jakub: leave-it. Task 3 is therefore a no-op."
human_verified: 2026-08-07 by Jakub, on device, dark mode
commit: none - CLAUDE.md forbids commits, work is in the working tree
branch: redesign/navigation-260806
---

# 260807-exp - the transaction receipt drawer's explorer CTA

Jakub, 2026-08-07, on his iPhone, reported two things about one drawer: the "View on Explorer" button
was too big, and it sat too high with a large dead band beneath it. He connected the second to the
bottom-nav fix shipped earlier the same session, and he was right.

**Only one of the two turned out to be real.**

## The space complaint - real, measured, fixed

Two `SafeArea`s stack, and the outer one does not do what its name implies.
`ResponsiveDrawer.show` opens with `showModalBottomSheet(useSafeArea: true)`, which in the pinned SDK
resolves to `SafeArea(bottom: false, ...)` - it neither consumes the bottom padding nor strips it
from MediaQuery. The full 34pt passes through to the shell's own footer `SafeArea(top: false)`, which
consumes all of it **on top of** `kDrawerFooterPadding`'s 20.

Measured: **20pt above the button, 54pt below.** A 2.7:1 asymmetry, same cause as the tab bar, same
14pt recoverable.

Fixed by capping the inset from one shared `kMaxBottomSafeInset` (20) now living in
`genius_wallet_consts.dart`. `responsive_overlay.dart`'s private `_kMaxBottomInset` was **deleted**
and repointed at it - moved, not duplicated. The result is 20 above, 40 below. The symmetric variant
(a flat 20/20, recovering the full 34) is recorded in the doc comment as the named fallback.

`test/components/drawer_footer_inset_test.dart` is new, and **it genuinely fails against the old
geometry** - the old `SafeArea` footer was temporarily restored and produced `Expected: 40.0, Actual:
54.0`, the exact number the arithmetic predicted. Two harness traps are written into the file because
both silently produce a green test that proves nothing: the inset must go on `tester.view.viewPadding`
rather than a `MediaQuery` inserted via `MaterialApp.builder` (the sheet is a sibling of the home
route, not a child), and the surface size must go on `tester.view.physicalSize` rather than
`setSurfaceSize` (only the former moves `MediaQuery.sizeOf`, which picks the sheet-vs-dialog branch).

## The size complaint - the census inverted the premise

The brief assumed the `lg` button was an outlier defended by a stale comment. **It is the standard.**
Twelve drawer footers exist; **six are single-action, and six of six are `lg` + `expand: true`**. The
comment defending it is still true.

A sweep was also **not available**: three of the six sit under `lib/squid_router` and `lib/banxa`,
both out of bounds, so unifying would have split the population 3/3 - worse than either extreme. One
of those untouchable files is a structural twin of this very button. The middle option (keep `lg`,
drop `expand`) died on the same census, since all six are full-bleed.

**DECIDED 2026-08-07: `leave-it`.** Jakub walked the space fix first, said the CTA "wyglada raczej
dobrze", asked for the height comparison, then chose to leave it. The numbers he was given:

| | Height | Label | Horizontal padding |
| --- | --- | --- | --- |
| View on Explorer | 56 (`lg`) | `titleLg` | `space10` |
| Receive / Buy GNUS | 44 (`sm`) | `labelMd` | `space6` |

The 44 is the **iOS touch floor**, not a style choice - the code comment records "was 36 - touch
floor". Those two are small because they are a pair sharing one row, and they are half-width each, so
matching heights would still not have made them read as a set.

The space fix delivered **14pt** against the size change's 12pt, which supports the diagnosis: what
read as "too big" was largely the 130pt footer block, not the 56pt button. `gradientOutline` survives
untouched, so the standing CTA weight rule is unaffected.

## Verification

- `flutter analyze` - 0 issues
- `flutter test` - **1081 passing** (1077 baseline + 4 new), zero failures
- On-device walk - approved by Jakub 2026-08-07

## Two findings recorded, not acted on

1. `test/components/responsive_drawer_body_padding_test.dart` uses `setSurfaceSize(400, 800)` and its
   header comment claims it exercises the `showModalBottomSheet` branch. By the measurement above it
   does not - it runs the **desktop** branch. Its delta assertions still hold, so it is green and
   correct, just not testing the half it says it is.
2. `SafeArea` did two jobs at the footer and only one came back: descendants no longer get the bottom
   padding stripped from their MediaQuery. Nothing in the twelve footers reads it, so this is inert
   today and flagged rather than fixed.

`test/components/drawer_padding_invariant_test.dart` was deliberately **not** touched - it asserts the
call-site file set and each site's `bodyPadding`, pumps no widget and reads no footer code, so editing
it would have weakened a currently-correct gate.
