---
status: complete
task: 260808-k2l
title: Sketch 186 scheme A + lead L2 on the transaction row
date: 2026-08-08
---

# Quick Task 260808-k2l: Sketch 186 scheme A + lead L2 - Summary

Applied Jakub's 2026-08-08 device approval of sketch 186 scheme A (neutral amount colour, always-on
value-line slot) plus lead L2 (`textPrimary70`) to `TransactionRow` - the one component shared by the
dashboard panel, the `/transactions` page, and the Buy GNUS orders rail.

## Files changed

- `lib/dashboard/home/widgets/transaction_displays.dart` - the 4 code changes (tone, value-line gate,
  value-line colour, status-tail colour) plus lead L2, and the doc comments the plan flagged as
  becoming stale.
- `lib/dashboard/home/widgets/transaction_utils.dart` - updated the dead-status override's own
  reasoning comment (unchanged logic).
- `test/dashboard/transaction_row_test.dart` - reconciled one existing assertion, added the 4
  requested pins plus one supporting pin (cancelled-tail-stays-neutral).
- `test/banxa/order_rail_row_test.dart` - added 2 pins covering the drawer/rail's shared consumption
  of the new colours, including a divergence case the plan's exact spec would have gotten wrong (see
  "A finding worth flagging" below).

No commits were made, per instruction - the tree stays dirty for device review.

## The 5 changes, before -> after

### 1. `_toneColor` - two-way, no more green

**File:** `transaction_displays.dart`, was `:168-172` (matches the README's citation exactly).

Before:
```dart
Color _toneColor(TxAmountTone tone, GWColors gw) => switch (tone) {
  TxAmountTone.incoming => gw.statusSuccess,
  TxAmountTone.outgoing => gw.textPrimary,
  TxAmountTone.none => gw.textSecondary,
};
```

After:
```dart
Color _toneColor(TxAmountTone tone, GWColors gw) => switch (tone) {
  TxAmountTone.none => gw.textSecondary,
  TxAmountTone.incoming || TxAmountTone.outgoing => gw.textPrimary,
};
```

Also rewrote the doc comment above it to carry the new reasoning (1.86:1 measurement, the "fourth
statement of a fact stated three times" argument, the honest cost) instead of leaving the old
12-02-tone comment silently wrong about what `incoming` does.

### 2. `amountColumn` - the value-line slot is never empty

**File:** `transaction_displays.dart`, was `:342-356` (README bundled this with `amountText` as
"316-356"; the gate itself is 342-356, matching within a few lines).

Before:
```dart
if (content.valueLine != null) ...[
  const SizedBox(height: GeniusWalletConsts.space2),
  Text(
    content.valueLine!,
    ...
    style: GeniusWalletTypography.bodySm.copyWith(
      color: gw.textSecondary,
    ),
  ),
],
```

After (gate dropped, `?? 'No price'`, plus the colour rule from item 3):
```dart
const SizedBox(height: GeniusWalletConsts.space2),
Text(
  content.valueLine ?? 'No price',
  ...
  style: GeniusWalletTypography.bodySm.copyWith(
    color: content.valueLine == 'Not charged'
        ? gw.statusError
        : gw.textSecondary,
  ),
),
```

### 3. Value-line colour - `Not charged` -> `statusError`, otherwise `textSecondary`

Folded into the same edit as #2 above. **Deviation from the README's literal wording** - see "A
finding worth flagging" below for why I did not write `content.status.isDead ? gw.statusError :
gw.textSecondary` verbatim.

### 4. Status tail - `txStatusColors(content.status, gw).fg`

**File:** `transaction_displays.dart`, was `:625-629` in the narrow-row status tail block (the
README's citation didn't give a line number for this one specifically; located by content).

Before:
```dart
style: GeniusWalletTypography.bodySm.copyWith(
  color: gw.textSecondary,
),
```

After:
```dart
style: GeniusWalletTypography.bodySm.copyWith(
  color: txStatusColors(content.status, gw).fg,
),
```

One expression, as the plan promised - `txStatusColors` already existed and is already correct for
all four statuses. `Completed` never reaches this Text (`statusTail` returns null for it).
`Cancelled` is unchanged visually (`textSecondary` either way). `Pending`/`Failed` now read in their
status colour on the narrow panel too, matching the wide page's pill.

### 5. Lead L2 - `textPrimary` -> `textPrimary70`

**File:** `transaction_displays.dart`, was `:548-551` in the pre-edit file - **matches the README's
citation exactly**, no drift.

Before:
```dart
style: TextStyle(
  fontWeight: FontWeight.w600,
  color: gw.textPrimary,
),
```

After:
```dart
style: TextStyle(
  fontWeight: FontWeight.w600,
  color: gw.textPrimary70,
),
```

Also rewrote the trailing sentence of the surrounding comment (it used to say "Named fallback if
white reads too hot... white at 70%, still well clear of AA" - true when L1 was shipping, false now
that L2 is the shipped choice) and appended the sketch 186 / 2026-08-08 reasoning: the `git show
0cd2889b` finding that the lead had collapsed onto the ticker (1.00:1), and what L2 buys back
(9.60:1 on-canvas, 2.01:1 vs the ticker, 1.61:1 vs the qualifier). Left the pre-existing
geometry-derivation paragraph (`114.0px`, `Processing job` fit numbers) untouched - the README itself
flags those numbers as already stale from the row-rhythm rollout, but fixing them is explicitly "not
this sketch's decision to make," so I restored it verbatim after an initial pass over-deleted it
(caught and corrected before finalizing - see `git diff` if you want to see the churn).

## Line-number drift vs the README

**Verified against the current file; drift was minimal.** The row-rhythm rollout's changes (icon
size 40->38, padding tokens, the new SEPARATOR RHYTHM comment block, `compact ?` removals) landed in
regions of the file adjacent to but not overlapping the 5 targeted expressions:

| README citation | Actual location (pre-edit) | Drift |
|---|---|---|
| `_toneColor` `:166-171` (files_to_read) / function itself | `:168-172` | ~2 lines, matches |
| `amountText`/`amountColumn` `:316-356` (bundled) | `amountText` `:315-327`, gate `:342-356` | negligible |
| subtitle lead `:548-551` | `:548-551` | **exact match** |
| `txStatusColors` `:76-99` | `:76-99` | **exact match** |
| `transaction_utils.dart` dead-status override `:625-650` | `:625-650` | **exact match** |

All 5 changes were located by content (the exact surrounding expressions the README quoted), not by
blindly trusting line numbers, per instruction - the numbers above are reported for the record, not
because I relied on them.

## A finding worth flagging: `content.status.isDead` doesn't exist, and a literal port would have
introduced a regression

The README's exact wording for item 3 is `content.status.isDead ? gw.statusError :
gw.textSecondary`. There is no `isDead` property on `TransactionStatus` or `TxRowContent` anywhere
in the codebase - `isDead` is a local variable inside `txRowContent` (`transaction_utils.dart:406`),
computed as `status == failed || status == cancelled`.

Reimplementing that check inline in the widget (`content.status == TransactionStatus.failed ||
content.status == TransactionStatus.cancelled`) looked like the obvious literal translation, but I
traced every `TxRowContent` producer before writing it and found it would have been wrong for one of
them:

- `lib/banxa/banxa_helpers/order_transaction_mapping.dart`'s `orderRowContent` (the Buy GNUS orders
  rail's `contentOverride`) explicitly documents that it **diverges from `txRowContent`'s `isDead`
  rule on purpose**: an order's `neutral` tone (an unrecognised Banxa status) also folds to
  `TransactionStatus.cancelled` - the same enum value a genuinely dead `txRowContent` row uses - but
  it keeps the order's real fiat value line rather than printing `Not charged`, because "we do not
  know that no money moved." Its own doc says it "drops only the green," i.e. it should read quiet,
  not alarming.
- A status-based `isDead` check cannot see that distinction: both the genuine-error case and the
  unrecognised-status case land on `status == cancelled` after the fold in one arm
  (`orderTransactionStatus`), while only the error case sets `valueLine = 'Not charged'`.
  Implementing the README's literal wording would have repainted a Banxa order's honest fiat
  number (e.g. `77.00 USD`) in `statusError` red on an unrecognised status - a new, false claim of
  failure the `orderRowContent` file was explicitly written to avoid.

**What I did instead:** keyed the colour off `content.valueLine == 'Not charged'` - the same sentinel
string `txRowContent`'s dead-status override and `orderRowContent`'s error branch both already use,
and the exact string the codebase's own comments call "load-bearing." This is behaviourally identical
to the README's intent for every `txRowContent`-derived row (where `isDead` and `valueLine == 'Not
charged'` are provably equivalent - the override is the only place either is set), and it is
additionally correct for the Banxa consumer, where the literal port would not have been.

I added a pin for exactly this in `test/banxa/order_rail_row_test.dart` (see below) so this doesn't
drift back.

## Confirmation: one component, three consumers, unchanged

Verified `TransactionRow` is still the single definition serving all three surfaces Jakub named:

- `lib/dashboard/home/widgets/transactions_slim_view.dart:695` - the dashboard panel AND the
  `/transactions` page (`lib/dashboard/transactions/transactions_screen.dart` and
  `sgnus_transactions_screen.dart` both route through this same view).
- `lib/screens/banxa_buy_screen.dart:1380` - the Buy GNUS orders rail, via `contentOverride`.

Both consumers render through the same `_toneColor`, `amountColumn`, and status-tail code paths I
edited, so scheme A and lead L2 are live everywhere in one edit. No consumer bypasses the component
or overrides these colours locally - the only thing that diverges is `orderRowContent`'s *data*
(what `valueLine`/`tone`/`status` it hands in), not the row's *rendering*, and that divergence is
handled correctly by the `'Not charged'`-string rule above.

**Not touched, and out of scope:** `showTransactionDetails`'s drawer (the same file, `:970-988`)
also calls `_toneColor` for its headline amount, so it automatically inherits the no-more-green
change for free. Its own value-line rendering (a separate `if (content.valueLine != null)` block)
was left untouched - it still hides the line entirely for an unpriced coin rather than reading "No
price." This is a real, minor inconsistency between the row and the drawer for the unpriced case
specifically. The README's exact-diff list and the "one component" requirement both name only
`TransactionRow`'s three list consumers (panel, page, orders rail), not the drawer, so I left it
alone and am reporting it here rather than expanding scope.

## Test reconciliation

**One existing assertion required reconciliation** (not weakened - re-stated for the new, correct
behaviour):

- `test/dashboard/transaction_row_test.dart`, group `wide-page Status pill (030-A2) and narrow tail
  (179-C)`, test `narrow (320): the status is the subtitle tail, and only that`. It used to assert
  the tail was `gw.textSecondary` and explicitly `isNot(gw.statusError)` - true before this change,
  now false by design (the tail's colour is `txStatusColors`, same as the pill, so a Failed row's
  tail is `statusError` on both wide and narrow). I flipped the colour assertion to the new correct
  value and, since colour can no longer distinguish "this is the tail, not a leaked pill," added a
  `fontSize` assertion (`bodySm` 14 vs the pill's `labelMd` 13) as the new structural check, plus a
  new sibling test confirming a **cancelled** row's tail stays `textSecondary` (the one status this
  change does not redden). Updated the group's doc comment to explain the new distinguishing
  mechanism. Ran this test before and after to confirm it failed pre-fix and passes post-fix.

**Added pins**, exactly the four requested plus two more that follow directly from the divergence
finding above:

In `test/dashboard/transaction_row_test.dart`, new group `sketch 186 scheme A (amount tone,
always-on value line) + lead L2`:
1. the amount is `textPrimary` for both an incoming and an outgoing row, and explicitly `isNot(
   gw.statusSuccess)` for the incoming case - the asymmetry cannot return silently.
2. a row whose price is unknown still renders `No price` as its second line, in `textSecondary`.
3. a failed row still reads `Not charged`, and its value line is `statusError`.
4. the subtitle lead is `textPrimary70` (read from the `TextSpan`'s own literal style, not a merged
   render-object style), and explicitly `isNot(gw.textPrimary)`.

In `test/banxa/order_rail_row_test.dart`:
5. the existing declined-order test gained a colour assertion (`Not charged` -> `statusError`).
6. new test: an unrecognised-status order keeps its real fiat in `textSecondary`, explicitly `isNot(
   gw.statusError)` - the regression the `isDead` finding above would have introduced if not caught.

All assertions read tokens (`gw.textPrimary`, `gw.statusError`, etc.) or existing typography tokens
(`GeniusWalletTypography.bodySm.fontSize`), never literal colour values.

## Verification

`flutter test test/dashboard/`:
```
00:20 +389: All tests passed!
```

`flutter test` (whole repo):
```
01:28 +1190 ~3: All tests passed!
```
Baseline was 1184 passed, 3 skipped, 0 failed. This run is 1190 passed, 3 skipped, 0 failed - the
baseline held, plus the 6 new pins (4 in `transaction_row_test.dart`, 2 in `order_rail_row_test.dart`
- one of the two "new" assertions in `order_rail_row_test.dart` was added to an *existing* test, so
it doesn't add to the count; the 6 new count is 4 + 2 genuinely-new `testWidgets` blocks). Two
pre-existing `RenderFlex overflow` warnings printed during the run come from
`lib/tokens/token_info_screen.dart` and `GWDetailGrid`, both unrelated to any file this task touched,
and did not fail the run.

`flutter analyze`:
```
Analyzing GeniusWallet...
No issues found! (ran in 7.5s)
```

`dart format` was run on every file this task touched; all were already correctly formatted (0
changes on the final pass).

## Deviations from Plan

### Auto-fixed / corrected issues

**1. [Rule 1 - Bug avoidance] `content.status.isDead` reimplemented as a `valueLine == 'Not charged'`
check instead of a status comparison.** See "A finding worth flagging" above. Files: `transaction_
displays.dart`. Not committed (per instruction).

**2. [Self-correction, no user-visible defect] Restored a stale-but-out-of-scope geometry comment
paragraph I had initially deleted while rewriting the lead L2 comment block.** The paragraph (114.0px
/ `Processing job` fit numbers) is flagged by the README itself as already inaccurate post-row-rhythm-
rollout, but fixing it is explicitly out of scope for this task ("not this sketch's decision to
make"). I deleted it in an intermediate edit, caught it on review, and restored it verbatim before
finalizing. Net diff for that region is only the two things asked for: the "Named fallback" sentence
correction and the colour token.

Nothing else deviated. All 5 changes match the plan's exact-diff description; the two items above are
the "verify against the current file, report drift/decisions" work the task explicitly asked for,
not scope creep.

## Known Stubs

None. This task wires real, existing tokens and functions (`gw.textPrimary70`, `txStatusColors`) -
nothing is placeholder.

## Threat Flags

None. Pure UI colour/behaviour change in a presentation-layer widget; no new network surface, auth
path, file access, or schema/trust-boundary change.

## Self-Check

- `lib/dashboard/home/widgets/transaction_displays.dart` - FOUND, modified.
- `lib/dashboard/home/widgets/transaction_utils.dart` - FOUND, modified.
- `test/dashboard/transaction_row_test.dart` - FOUND, modified, 58/58 tests pass.
- `test/banxa/order_rail_row_test.dart` - FOUND, modified, 10/10 tests pass.
- Full suite: 1190 passed, 3 skipped, 0 failed (baseline 1184/3/0 held).
- `flutter analyze`: 0 issues.
- No commits created (verified: `git log -1` unchanged from session start).

## Self-Check: PASSED
