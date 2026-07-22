---
phase: 15-transactions-tab
plan: 02
subsystem: components/feedback
tags: [empty-state, layout, anchor, shared-component, freeze-rule, tdd]
requires: ["quick 260721-e3r (the adaptive compact tier this must not break)"]
provides:
  - "GWEmptyState anchors its block within the first 480px of a bounded slot"
  - "_anchorSearchHeight (480) + a constant-only assert pinning it clear of the compact threshold"
  - "test/components/ — first test dir for shared components"
affects:
  - "transactions_slim_view.dart (both _body empty branches)"
  - "coins_screen.dart (Assets empty)"
  - "dashboard_screen.dart (Markets coins.isEmpty)"
  - "design_gallery_screen.dart (states section)"
key-files:
  modified:
    - lib/components/feedback/gw_empty_state.dart
  created:
    - test/components/gw_empty_state_anchor_test.dart
decisions:
  - "Anchor is a RULE (cap the centring search at 480), not an offset — a slot under 480 is byte-identical to the previous Center."
  - "Hoisted the existing `Center` node, not the `Padding` subtree — tree-identical to the plan's shape but leaves the children literally untouched."
  - "Did NOT run dart format on the widget: the repo predates Dart 3.11 tall style, so formatting would have added ~110 lines of unrelated churn."
  - "Plan's stated redden-mutation for test 4 is wrong; corrected in-file with the mutation that actually works."
requirements: [TT-04]
status: complete
---

# Phase 15 Plan 02: Empty-state anchor — Summary

`GWEmptyState` stopped drifting to the vertical midpoint of a tall slot. In the
~1400px `/transactions` slot the icon centre moved from **dy 652.0 to dy 192.0** —
a 460px lift, out from below the fold. Every other call site renders byte-identically.

**No commits created.** `./CLAUDE.md` holds the commit gate; nothing staged
(`git diff --cached` empty).

## The change — 4 lines of code, in one `LayoutBuilder`

```dart
static const double _anchorSearchHeight = 480;   // a literal, never a fraction

final Widget centred = Center(child: Padding(/* unchanged */));

if (!isHeightBounded) return centred;            // the gallery branch

return Align(                                    // pin the capped box to the top
  alignment: Alignment.topCenter,
  child: ConstrainedBox(                         // never search past 480 …
    constraints: const BoxConstraints(maxHeight: _anchorSearchHeight),
    child: centred,                              // … for the middle
  ),
);
```

Plus a second `assert(_anchorSearchHeight > compactHeightThreshold, …)` — constant-only
like the first, so it can never fire for a real layout, only for a future edit. It
states in code what the comment argues in prose: compact fires below 192 (256 with an
action), the cap only binds above 480, so no slot height exists at which the cap could
become the thing selecting the layout.

Semantic diff is **79 insertions / 4 deletions**, and the insertions are overwhelmingly
comment. Nothing else in the file moved: not the compact constants, the threshold
arithmetic, `hasAction`, the `Column` children, the `maxLines`/`overflow` clamps or the
`GWButton` block.

### Freeze rule (`37639d5`) — held

`grep -nE 'maxHeight *[*/+-]|maxWidth *[*/+-]|FittedBox|textScalerOf|AutoSizeText'`
returns exactly one hit, inside a comment warning against it. The two values this plan
adds are a fixed literal (480) and a bool (`isHeightBounded`) — both bounded sets, neither
derived continuously from constraints. `test/chart/compact_price_font_size_test.dart`
(the guard) passes 3/3.

## Measured geometry — before and after

Harness: 1200×1600 logical surface at dpr 3.0, 600px-wide slot, real transactions copy
(`No transactions yet` / `Your sends, receives and swaps will appear here.`). Icon centre
measured **from the slot top**.

| slot | before | after | note |
|---|---|---|---|
| 1400px bounded | **652.0** | **192.0** | the fix. Matches the plan's predicted 192.0 exactly |
| 1400px bounded + action | 620.0 | 160.0 | filtered-empty branch |
| 300px bounded | 102.0 | **102.0** | byte-identical — block gaps 66/66 above/below |
| 170px bounded | 43.0, icon glyph **24** | 43.0, icon glyph **24** | compact tier still fires |
| unbounded | height **192.0** | height **192.0** | sizes to content, does not inflate |

**The short-slot case really is byte-identical** — not "within a pixel". Same 102.0, same
66/66 gaps, same icon glyph. Below 480 the `ConstrainedBox` does not bind, so the box
fills the slot and the tree collapses to what shipped before. That is the whole argument
for a rule over an offset, and it is why Assets / Markets / the dashboard cards cannot
have moved.

**Unbounded harness shape used** (15-06 needs this): the gallery's own shape, not a
substitute —

```dart
SingleChildScrollView(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: const [GWEmptyState(title: …, message: …)],
  ),
)
```

## Test coverage — five tests, every one mutation-proven

`test/components/gw_empty_state_anchor_test.dart` (new dir). All five pass; the surface is
widened to 1200×1600 in a helper with `addTearDown` on both `resetPhysicalSize` and
`resetDevicePixelRatio`, because the default 800×600 would silently collapse a
`SizedBox(height: 1400)` to 600 and make every number above a lie.

Each test was run against a deliberately broken widget to confirm it actually reddens:

| # | test | mutation applied | result |
|---|---|---|---|
| 1 | tall slot anchors near the top | revert to bare `Center` | RED — `652.0` vs `closeTo(192.0, 8)` |
| 2 | short slot byte-identical | sketch 021's rejected variant `a` (topCenter + space16) | RED — gaps `56.0` vs `76.0` |
| 3 | unbounded sizes to content | drop the `isHeightBounded` guard | RED — **exactly `480.0`** |
| 4 | compact tier still fires | feed the compact decision the capped height | RED — icon `32.0` vs `24.0` |
| 5 | action-bearing keeps its button | revert to bare `Center` | RED — `620.0` vs `< 480` |
| 5 | " | cap lowered 480 → 200 | RED — `Show all` not found at all |

**Test 3's mutation lands on 480.0 to the pixel**, which is the plan-checker's
"by construction" claim confirmed empirically: without the guard, `ConstrainedBox` under an
infinite height hands `Center` a bounded 0..480, `Center` takes the largest allowed size,
and the design gallery grows a 288px void. The guard is load-bearing.

**Test 1 was the one at risk of passing trivially** and does not: against the unmodified
widget at the corrected surface it fails at 652.0. (The plan-checker's earlier `< 300`
would indeed have passed — the uncorrected 600px surface collapses the slot.)

## Deviations from plan

1. **Hoisted the `Center`, not the `Padding` subtree.** The plan said hoist
   `Padding > Column` into `final Widget content` and return `Center(child: content)` /
   `Align(…Center(child: content))`. I hoisted one level up: `final Widget centred =
   Center(child: Padding(…))`, returning `centred` unbounded and
   `Align > ConstrainedBox > centred` bounded. **The rendered trees are identical** —
   bounded is `Align > ConstrainedBox > Center > Padding > Column` either way. The reason
   is the plan's own instruction "moved verbatim — do not retype the children": hoisting
   the `Padding` requires dedenting the entire 50-line subtree, and hoisting the `Center`
   changes exactly one line and leaves the children byte-for-byte untouched. Diff cost:
   4 deletions instead of ~50.

2. **Reverted a `dart format` pass.** I formatted the widget mid-task; it reflowed the
   whole file into Dart 3.11's tall style, turning a ~25-line change into 115 insertions /
   51 deletions. The repo does **not** conform to that style — `dart format
   --set-exit-if-changed` reports `coins_screen.dart`, `dashboard_screen.dart` and
   `gw_button.dart` as "Changed" too. So the churn was mine, not a correction. I rebuilt
   the file from `HEAD` and re-applied only the semantic edits by hand, then re-ran
   analyze, all five tests and the full mutation matrix against the rebuilt file. Also
   relevant: another session is editing this tree, and a whole-file reformat is a
   gratuitous conflict surface.
   *Residual:* the NEW test file is in tall style (I formatted it before noticing).
   Left as-is — it is a new file, so there is no diff churn, and it analyzes clean.

3. **The plan's first stated redden-mutation for test 4 is wrong, and I verified it.**
   The plan says test 4 goes red if "the `ConstrainedBox` is hoisted outside the
   `LayoutBuilder`". It does not. I built that mutation and ran it: at 170px the cap never
   binds, so the builder still sees 170 and compact still fires — **test 4 passes**. That
   mutation reddens tests **2, 3 and 5** instead, so the file still catches it; only the
   attribution was wrong. The mutation that does redden test 4 is the plan's *second*
   clause — feeding the compact decision the capped height. I corrected the comment in the
   test rather than leaving a mutation claim the test cannot honour.

4. **`ponytail:` correction made as instructed, plus one clarification.** The claim "no
   current call site renders `GWEmptyState` without a message today" was false and is now
   replaced by the named counter-example (`dashboard_screen.dart:491`, title-only, ~114px
   Markets card). I added that the card is far below 192 either way, so the compact tier
   already handles it correctly — the shape assumption is loose, not broken. Threshold
   arithmetic untouched, as instructed.

## Verification actually run

```
$ flutter analyze lib/components/feedback test/components
No issues found! (ran in 4.2s)

$ flutter test test/components/gw_empty_state_anchor_test.dart
00:06 +5: All tests passed!

$ flutter test test/components/ test/chart/ test/dashboard/
08:16 +173: All tests passed!        # every consumer test + the freeze guard

$ flutter test
00:20 +205 -1: Some tests failed.    # the 1 is the pre-existing load failure
```

`grep -n 'isHeightBounded' lib/components/feedback/gw_empty_state.dart` → 5 hits, of which
two are code: line 115 computes it, line 125 feeds the compact decision, line 219 feeds the
anchor branch. One source of truth for "is this slot real", as the plan required.

### Test-count reconciliation — read this before comparing numbers

The brief stated a baseline of **187 passing / 1 failing**. Measured at the start of this
session it was **193 / 1**. The extra 6 are `test/boot_sequence_test.dart`, a file owned by
the concurrent session and explicitly off-limits to me; 193 − 6 = 187 reconciles exactly.

Final: **205 passing / 1 failing.** Of the +12 over the session-start baseline, **5 are
mine**; the other 7 arrived from the concurrent session (`transaction_utils_test.dart`
40 → 45, plus 2 elsewhere) while this plan ran.

The single red is the pre-existing one and only that one: `test/local_wallet_storage_test.dart`,
`Missing definition of 'main'` — the file is entirely commented out, so it fails at *load*
and the `-1` is carried through the whole run. Not introduced here, not fixed here.

### Two transient full-suite reds, proven not mine

Intermediate runs showed 4 failures in `transaction_utils_test.dart` and 1 in
`transaction_filters_test.dart`. Both were the concurrent session writing mid-run
(`transaction_utils.dart` mtime landed inside my test run). A/B'd each by reverting
`gw_empty_state.dart` to `HEAD` and re-running the file in isolation: **45/45 pass with my
change and 45/45 without it**. Neither is a regression from this plan. Final runs were taken
in a quiet window (no `.dart` write for 45s) and are clean.

## Tree-state notes for whoever picks this up

1. **The branch changed under me mid-execution.** This session started on
   `redesign/homepage-chrome-260721` (`73a09a4`); the working tree is now on
   `ui-redesign-port` (`ea33561`). My changes are unstaged in the working tree and were
   rebuilt against `ea33561`'s widget, which is the compact-tier version the plan
   describes and the one I tested throughout. Verified: `git diff -w` against `ea33561`
   shows only the four intended edits, and the compact tier is intact (19 references).
2. **The plan's transactions line numbers have drifted.** `transactions_slim_view.dart`
   is under active edit by the other session; the two `GWEmptyState` branches moved
   **247/258 → 264/282** during this plan. My test file now names call sites by *branch*
   rather than by line for that file. `dashboard_screen.dart:491`,
   `coins_screen.dart:214` and `design_gallery_screen.dart:757` have not moved and are
   still cited by line.

## Known ceilings (pre-existing, not introduced)

A **150px** bounded slot still overflows by exactly 6.0px — `_compactLayoutHeight` is 156
and there is no third, button-shrinking tier. Measured identically before and after this
change, so the anchor neither causes nor cures it. It is the ceiling the widget's existing
`ponytail:` already names, and it is why test 4 uses 170px rather than 150.

## Outstanding for 15-06

- **Covered by test, not by eye:** all three constraint shapes — tall bounded
  (transactions), short bounded (Markets card geometry), unbounded (design gallery) — plus
  the compact tier and the action-bearing branch.
- **Still needs a live look:** nothing here is a claim about how it *looks*. 15-06's
  Checkpoint B should still spot-check **Assets** and **Markets** on screen, since a
  600px-wide headless harness in the Ahem test font is not the real panel width or the
  real font. The specific thing to look at is the tall `/transactions` slot: the block now
  sits at 192px from the top of the slot, and whether that reads as "anchored" or as
  "floating slightly low" is a judgement no assertion here makes.
- No interactive app was launched; `flutter run` is not something this executor can hold
  open.

## Self-Check: PASSED

- `lib/components/feedback/gw_empty_state.dart` — FOUND (259 lines, modified, analyzes clean)
- `test/components/gw_empty_state_anchor_test.dart` — FOUND (205 lines, new, 5/5 pass)
- Scratch measurement file `test/components/gw_measure_scratch_test.dart` — created for
  measurement, **deleted**; confirmed absent.
- Commits: **none, by design.** `HEAD` is `ea33561`, staging area empty.
- Files outside this plan's scope: untouched. No changes to `boot_sequence*`,
  `.planning/phases/13-*`, `14-*`, `sketches/015-018`, `spikes/`, or `cmake/*.cmake`.
