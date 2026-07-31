---
phase: quick-260731-opb
plan: 01
subsystem: swap
tags: [layout, render-object, swap, geometry, regression-test]
status: complete
requires:
  - lib/squid_router/swap_field.dart
  - lib/squid_router/token_flip_button.dart
  - lib/theme/genius_wallet_consts.dart
provides:
  - SwapSeam
  - RenderSwapSeam
affects:
  - lib/squid_router/swap_screen.dart
tech-stack:
  added: []
  patterns:
    - "MultiChildRenderObjectWidget + hand-written RenderBox for a layout that must size itself from its children (second instance in this repo after _FillHeight/_RenderFillHeight)"
key-files:
  created:
    - lib/squid_router/swap_seam.dart
    - test/squid_router/swap_flip_centring_test.dart
  modified:
    - lib/squid_router/swap_screen.dart
decisions:
  - "The seam is computed as payHeight + gap/2 in a single layout pass, not centred on the pair's bounding box"
  - "Rejected the overflow-inside-Column approach: RenderBox.hitTest gates on _size.contains, which would have killed most of the 44px tap target"
  - "Rejected the measure-then-reposition approach: one frame of lag per height change, and it reintroduces a derived number into the layout"
  - "No computeDryLayout, recorded as a ponytail: comment naming IntrinsicHeight as the ceiling"
metrics:
  duration: ~50m
  completed: 2026-07-31
---

# Quick Task 260731-opb: Swap flip control vertical centring Summary

The flip control's position on the swap screen is now a computed seam
(`payHeight + gap / 2`) rather than the centre of both cards' bounding box, so it
stops drifting when the pay card grows taller than the receive card.

## What was wrong

The old layout was `Stack(alignment: Alignment.center)` wrapping a `Column` of
both cards, with the control as the Stack's second child. The Stack's height is
`payH + gap + receiveH`, so `Alignment.center` put the control at
`(payH + gap + receiveH) / 2` while the seam's real midpoint is `payH + gap / 2`.
The difference is `(receiveH - payH) / 2`, exactly half the height difference, and
a taller pay card pulls the control UP - which is what Jakub reported on the
2026-07-31 walk ("zostaje w miejscu lub przesuwa sie do gory").

The measurement confirmed the arithmetic exactly. With ETH seated on the pay side
and an amount typed: pay=141.0, receive=125.0, so the predicted drift is
`(125 - 141) / 2 = -8`, and the observed drift was **8.0px upward** (seam=285.0,
control=277.0).

## The RED gate, run in the required order

Task 1's test file was written and run BEFORE any fix landed. Real output:

```
00:00 +0: A: at rest the control is centred on the seam
00:04 +1: B: with a pay token seated and an amount typed, the control is still centred on the seam
Expected: a numeric value within <0.5> of <285.0>
  Actual: <277.0>
   Which:  differs by <8.0>
pay=141.0 receive=125.0 seam=285.0 control=277.0
00:05 +1 -1: B: ... [E]
00:07 +2 -1: Some tests failed.
```

Test A passed, Test C passed, **Test B failed with a measured 8.0px drift**. This
is the check the plan called the single most important one in the task: a Test B
that was green before the fix would have meant the fixture failed to produce an
asymmetric pay card, not that the layout worked.

After the fix, the same measurement reads **pay=141.0 receive=125.0 seam=285.0
control=285.0** - drift 0.0, with both card heights byte-identical to before,
confirming the new `BoxConstraints.tightFor(width:)` gives the cards exactly the
width the old loose constraints did.

## What was built

**`lib/squid_router/swap_seam.dart`** (new). `SwapSeam`, a
`MultiChildRenderObjectWidget` taking `gap` plus three opaque children
(`payCard`, `receiveCard`, `control`), and `RenderSwapSeam`, a hand-written
`RenderBox` that lays the two cards out first and sizes itself from them. It
imports only `flutter/rendering.dart` and `flutter/widgets.dart` - nothing from
the swap feature - which is what lets Test D drive it with plain sized boxes.

`CustomMultiChildLayout` and `Flow` were not usable: both call
`delegate.getSize(constraints)` BEFORE laying any child out, and under the
screen's `SingleChildScrollView` the incoming height constraint is infinite, so
`getSize` would have had to return a hardcoded height - the exact magic number the
task exists to remove.

`paint` and `hitTestChildren` are overridden to `defaultPaint` /
`defaultHitTestChildren` and both are load-bearing, with a comment naming what
breaks without them: the first restores the control painting on top of the cards
it overlaps by 14px per side, the second restores its priority for the tap over
the pay card's `TextField`.

**`lib/squid_router/swap_screen.dart`**. The `Stack` and its inner `Column` are
replaced by `SwapSeam`, with both `SwapField` calls moved across verbatim (labels,
controllers, `onChanged`, `tokensForSide` calls, `pickerEmptyTitle`/
`pickerEmptyMessage`, the D-09 `emptyPlaceholder`) and
`TokenFlipButton(onFlip: _flipTokens)` unchanged. The separating `SizedBox` is
deleted; its `GeniusWalletConsts.space8` now lives in `gap`, so the visual gap is
unchanged and is not doubled. The comment above the block is replaced - the old
one asserted the false premise that near-equal card heights put the Stack's centre
on the seam.

`token_flip_button.dart` is untouched (`git status` reports it clean).

## Tests

Four tests in `test/squid_router/swap_flip_centring_test.dart`, all green:

| Test | State | Before fix | After fix |
|------|-------|-----------|-----------|
| A | Both cards empty | pass | pass |
| B | Pay token seated + amount typed | **FAIL, 8.0px drift** | pass |
| C | Tap 2px inside top and bottom edges | pass | pass |
| D | Synthetic 40px vs 400px pair | n/a (added in Task 2) | pass |

Test C is a regression guard, not a bug repro - it passed before the fix too, and
it exists because two of the three approaches considered would have silently made
those two points untappable.

## Gates - real numbers, run this session

| Gate | Result |
|------|--------|
| `dart format` (3 files) | 1 changed (`swap_seam.dart`); re-run reports 0 changed |
| `flutter analyze` | **No issues found!** (0) |
| `flutter analyze lib/squid_router test/squid_router` | **No issues found!** (0) |
| `flutter test` (full suite) | **968 passing, 0 failing, "All tests passed!"** |
| `bash tool/check_brace_style.sh` | exit 0, no output |
| `bash tool/check_raw_colors.sh` | exit 0, no output |

`lib/squid_router` **is** inside `check_raw_colors.sh`'s `COVERED_DIRS` (line
100), so that 0 is genuine coverage of the new file, not a gap.

**Two caveats on the numbers, stated rather than rounded off.** A concurrent agent
was working in the same tree throughout (`lib/banxa/`, `lib/screens/banxa_buy_screen.dart`,
`lib/dashboard/home/widgets/transaction_*.dart`), which I did not touch:

1. An earlier `flutter analyze` in this session reported **41 issues, every one of
   them in `test/banxa/order_transaction_mapping_test.dart`** - an untracked file
   from that agent, with zero references to squid_router. They fixed it mid-session
   and the final analyze is clean. My files contributed 0 at both readings.
2. The full suite read **959** on the first run and **968** on the last, because
   that agent was adding test files during the session. **The delta from the ~930
   baseline therefore cannot be attributed cleanly to my four tests**, and I am not
   going to pretend otherwise. What I can state exactly: my file contributes 4
   tests, `flutter test test/squid_router/` reports 82 passing, and the whole suite
   is green with 0 failures.

## Deviations from Plan

**1. [Rule 3 - Blocking] `WalletType.ethereum` does not exist**
- **Found during:** Task 1, first compile
- **Issue:** The seeded-wallet fixture used `WalletType.ethereum`; the enum is
  `{tracking, privateKey, mnemonic, keystore, sgnus}`
- **Fix:** `WalletType.mnemonic`. The screen never reads this field
- **Files modified:** `test/squid_router/swap_flip_centring_test.dart`

**2. [Rule 1 - Correctness] Test C re-measures the control rect before the second tap**
- **Issue:** The plan's literal text implied reusing the rect captured before the
  first tap. The first flip moves the token to the receive side, which under the
  OLD layout also moved the control, so the stale rect's `bottomCenter` could land
  off the button and the test would have failed for a reason unrelated to the tap
  target
- **Fix:** Re-read the rect after the first flip, with a comment saying why. The
  test is now correct under both the old and new layouts, which is what a
  regression guard has to be

**3. [Rule 1 - Correctness] Test D keys all three children**
- **Issue:** The plan specified a keyed control only, but the control is itself a
  `SizedBox`, and `MaterialApp`/`Scaffold` contain their own, so
  `find.byType(SizedBox).at(0)` would have been ambiguous
- **Fix:** All three children carry keys

**4. [AGENTS.md] Removed a one-field holder class from Test C**
- A `SquidTokenInfoSide` wrapper was written and then deleted in favour of a local
  `symbolOn(int)` closure, per AGENTS.md's "no abstractions that weren't explicitly
  requested". Self-caught before the first run

## Notes

- One em dash remains in `swap_screen.dart`: `emptyPlaceholder: routeError ? '—' : null`.
  That is the pre-existing D-09 route-error placeholder, and the plan required the
  `SwapField` arguments be moved across verbatim. It was not introduced here. No em
  dashes appear in any comment or code I wrote.
- `RenderSwapSeam` has no `computeDryLayout`. Recorded as a `ponytail:` comment
  naming the ceiling (it must not sit under `IntrinsicHeight`, which will throw
  rather than mis-measure) and the upgrade path (`ChildLayoutHelper.dryLayoutChild`
  for both cards, same sum).

## Git state

**Nothing committed, nothing staged, nothing pushed**, per the standing rule.

```
$ git diff --cached --name-only
(empty)
$ git status --porcelain lib/squid_router test/squid_router
 M lib/squid_router/swap_screen.dart
?? lib/squid_router/swap_seam.dart
?? test/squid_router/swap_flip_centring_test.dart
$ git branch --show-current
redesign/jakub-260730
```

`HEAD` is `2a4ef884`, unchanged by this task - the reflog shows the last HEAD move
was a `reset`/`checkout` from a prior session, and `git show --stat` confirms no
squid file is in that commit.

## The visual walk (the one thing automation cannot settle)

```
flutter run -d macos --dart-define=GW_DEV_TOOLS=true
```

Open Swap, then:

1. **Both cards empty** - the control sits on the seam. This looked right before
   the fix too; it is the control case.
2. **Pick a pay token** - this is the state that used to break. The pay card grows
   by the token pill's 32x32 logo and the MAX chip. The control must not move off
   the seam.
3. **Type an amount** - the card height should not change at all (the `TextField`
   is single-line and scrolls horizontally). If it does move, that is new.
4. **Pick a receive token as well** - both cards grow, the control stays put.
5. **Tap the control at its very top edge, then at its very bottom edge** - both
   must flip. This is the property the overlap approach would have destroyed.

**How large a drift you are looking for the absence of:** in the state at step 2-3
the cards measure **pay=141px, receive=125px**, which under the old layout put the
control **8px above** the seam. That is a small but visible misalignment against a
16px gap - the control's centre was halfway to the pay card's bottom edge rather
than on the line between them.

## Self-Check: PASSED

- `lib/squid_router/swap_seam.dart` - FOUND
- `test/squid_router/swap_flip_centring_test.dart` - FOUND
- `lib/squid_router/swap_screen.dart` - FOUND, modified, `grep -c 'SwapSeam'` = 2
  (import + call site)
- `lib/squid_router/token_flip_button.dart` - clean, untouched
- No commits made (by instruction), so no commit hashes to verify
