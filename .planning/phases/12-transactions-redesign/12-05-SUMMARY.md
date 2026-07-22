---
phase: 12-transactions-redesign
plan: 05
subsystem: dashboard/transactions
tags: [transactions, day-separators, empty-states, freeze-sweep, dev-fixture]
requires: ["12-02 (groupTransactionsByDay/TxDay/txDayLabel)", "12-03 (TransactionRow)", "12-04 (10-value Filters, _TransactionFilterBar)"]
provides:
  - "day-grouped transactions body (headers + within-day hairlines)"
  - "filteredEmptyTitle / filteredEmptyMessage / emptyTransactionsTitle / emptyTransactionsMessage"
  - "extended DevMockTransactions batch (11 txns, 7 types, 4 statuses, 3 calendar days)"
affects: ["transactions_stream.dart", "sgnus_transactions_screen.dart", "transactions_screen.dart (/transactions route)"]
key-files:
  modified:
    - lib/dashboard/home/widgets/transactions_slim_view.dart
    - lib/dev/dev_mock_transactions.dart
    - test/dashboard/transaction_filters_test.dart
decisions:
  - "Day labels use the 13px labelMd step, not sketch 014's 11px — the typography floor was deliberately raised from 12 to 13."
  - "Dev fixture Today bucket is minutes-from-now, not hours — narrows the midnight edge case from 4h to ~40min."
  - "Dev fixture Yesterday / 3-days-back buckets use wall-clock DateTime(y, m, d - n, h, m), not subtract(Duration(days:)) — DST-immune."
status: complete
---

# Phase 12 Plan 05: Panel assembly, two empty states, freeze sweep — Summary

Day-grouped the transactions panel, split the one shared empty state into two that
say genuinely different things, and removed the last constraint-derived text sizing
from the file — leaving `compact` (a bool) as the only layout-derived value in it.

**No commits created.** `./CLAUDE.md` holds the commit gate; nothing was staged
(`git diff --cached` empty, `HEAD` still `ea33561`).

## Task 1 — `transactions_slim_view.dart`

**Body rebuilt into three branches** in a new private `_body(context, gw, scoped, txs)`:

1. `scoped.isEmpty` → `GWEmptyState(Icons.receipt_long_outlined, …)` — the
   never-transacted state, unchanged copy, no action. The one branch allowed to be
   a dead end.
2. `scoped.isNotEmpty && txs.isEmpty` → `GWEmptyState(Icons.filter_alt_outlined, …,
   actionLabel: 'Show all', onAction: …)` — reuses the component's existing
   `actionLabel`/`onAction`; no new widget was written.
3. otherwise → the day-grouped `ListView.builder`.

**Exact empty-state copy shipped** (all four strings are now public top-level
identifiers in this file, so the test asserts the difference by identity rather
than against a duplicated literal that could drift):

| | Branch 1 — never transacted | Branch 2 — filter matched nothing |
|---|---|---|
| icon | `receipt_long_outlined` | `filter_alt_outlined` |
| title | `No transactions yet` | `No swapped transactions` (`'No ${f.label.toLowerCase()} transactions'`) |
| message | `Your sends, receives and swaps will appear here.` | `You have 8 transactions, but none match this filter.` (singular at 1) |
| action | none | **Show all** → `setState(() => selectedFilter = Filters.all)` |

The "you have N" number and the overflow-menu counts both read the single
`scopedTransactions` getter; the footer counts `txs`. One getter per meaning —
T-12-14 mitigated structurally, not by convention.

**Day-grouped list.** `groupTransactionsByDay(txs)` is called once and flattened
into a `List<Widget>` in `_body` (i.e. in the build pass, not in `itemBuilder`), so
no index arithmetic runs per visible item per frame. Per day: an uppercased
`day.label` header at `labelMd`/w600/`letterSpacing: 0.7` in `textSecondary`,
padded `fromLTRB(space6, first ? space2 : space8, space6, space2)`; then the rows,
with `Divider(height: 1, thickness: 1, color: gw.borderSubtle)` after every row
**except the last of its day** — the next header is the separator at a boundary.
`padding: EdgeInsets.zero` keeps the hairlines full-bleed.

**Header rule** — `Divider(height: 1, thickness: 1, color: gw.borderSubtle)` sits
directly under `GWSectionTitle`, before the body.
**FLAG FOR 12-06's WALK:** the Assets panel has **no** such rule. The two panels are
otherwise built to read as one system (same `GWSectionTitle`, same row geometry,
same hairline). This is the one deliberate divergence introduced here and it needs
a side-by-side judgement: either Assets gains the rule or Transactions loses it.
I could not settle that without seeing both panels together.

**Footer.** Now `'${txs.length} transaction${…}'` (was `"Transactions: N"`), plain
`Text` at a fixed `labelMd`, inside the existing `Align(centerRight)` and `space8`
gap — and now wrapped in `if (txs.isNotEmpty)`, so neither empty branch renders it.

### Freeze sweep — what is gone, what survives

Removed from this file:
- the `auto_size_text` import and the `AutoSizeText` footer;
- `MediaQuery.textScalerOf(context).scale(...)` feeding a `fontSize`;
- the dead `with WidgetsBindingObserver` mixin and its `didChangeMetrics` override
  (`addObserver` was never called, so the callback never fired — deleting it changes
  no behaviour);
- the now-unused `filteredTransactions` getter.

There is no `FittedBox` in the file and none was added. The three surviving textual
mentions of `AutoSizeText` / `textScalerOf` / `FittedBox` are all in comments that
explain why they must not come back; the code-line grep
(`grep -v '^ *//' … | grep -c AutoSizeText`) returns **0**.

**Layout-derived values that survive in this file — exactly one:**

| value | where | why it is bounded |
|---|---|---|
| `final bool compact = constraints.maxWidth < 420` | `_TransactionsSlimViewState.build`, inside the file's only `LayoutBuilder` | It is a **boolean** — a two-element set. It feeds chip padding (`space6` or `EdgeInsets.zero`) and whether the active chip shows its label. Both outcomes are fixed literals/tokens, and the `TextStyle`s on either side of the branch are identical, so no drag-resize can generate more than the two `TextStyle`s that already exist. That is the property the `37639d5` bug lacked: there, `maxHeight * 0.45` produced a *distinct* `TextStyle` per frame, so skia's fixed-size `ParagraphCache` thrashed, layout never settled and the macOS embedder blocked forever in `ResizeSynchronizer.beginResize`. |

`GWEmptyState` also runs its own `LayoutBuilder`, but it likewise derives only a
bool (`isCompact`) and selects between fixed constants — same bounded shape, and it
is not this file.

### Tests added (`test/dashboard/transaction_filters_test.dart`)

Group `empty-state copy` (4 tests, pure): the filtered title names the filter; the
message quotes the total and agrees in number (1 → `transaction`, 8 →
`transactions`); **the filtered title differs from `emptyTransactionsTitle` for
every non-`all` filter** and the message differs from `emptyTransactionsMessage`;
and neither says "buy".

Group `day-grouped body` (3 widget tests, host 900×1400 so the whole list
materialises): three one-row days → `TODAY` + `YESTERDAY` headers and **exactly one
`Divider`** (the header rule alone — no boundary dividers); two rows on Today plus
one Yesterday → **two `Divider`s** (header rule + the single within-day rule); a
one-row panel → footer reads `1 transaction`.

Plus one branch-selection widget test in the existing group: an empty wallet shows
`No transactions yet` and no `Show all`; a wallet with one *sent* transfer filtered
to *Received* shows `No received transactions` / `You have 1 transaction, but none
match this filter.` / a working `Show all` that returns to the full list.

## Task 2 — `lib/dev/dev_mock_transactions.dart`

8 → **11** transactions. Every existing transaction kept (including #8's
`123456789.123456789123456789 ETH`, untouched); icon URLs still null, so the batch
stays fully offline. `dev_tools_bubble.dart` untouched — no new call site, so
T-12-15's `kDebugMode && kShowDevTools` constant-fold still removes the whole path
from release.

The frozen `static final _base = DateTime(2026, 7, 20, 12, 0)` is gone; timestamps
are now relative to a single `DateTime.now()` taken per `batch()` call.

**Composition (what 12-06's walk can name):**

| # | day bucket | type | status | direction | note |
|---|---|---|---|---|---|
| 9 | Today, −3 min | `process` | completed | sent | GNUS, **`fees: '0.42'`**, 25 GNUS recipient — the "Completed job" row; fee is its only economic content |
| 1 | Today, −12 min | `transfer` | completed | sent | 0.75 ETH |
| 2 | Today, −25 min | `transfer` | completed | received | 0.0042 BTC |
| 10 | Today, −40 min | `purchase` | **completed** | received | 500 GNUS — the success branch, never seen before |
| 3 | Yesterday 09:15 | `mint` | completed | received | 1200 GNUS |
| 4 | Yesterday 13:40 | `escrow` | **pending** | sent | 500 GNUS |
| 5 | Yesterday 17:05 | `escrowRelease` | completed | received | 500 GNUS |
| 6 | Yesterday 21:30 | `purchase` | **failed** | sent | 100 ETH |
| 7 | 3 days back 10:20 | `swap` | completed | sent | ETH → USDC, 1.0 → 3200 |
| 8 | 3 days back 15:45 | `transfer` | completed | sent | the whale amount, unchanged |
| 11 | 3 days back 19:10 | `transfer` | **cancelled** | sent | 3.5 ETH — makes the cancelled badge and "Failed spans cancelled" walkable |

All 7 `TransactionType` values, all 4 `TransactionStatus` values, both directions,
three calendar-day groups (`TODAY` / `YESTERDAY` / a dated header).

## Deviations from plan

1. **Day labels at 13px `labelMd`, not sketch 014's 11px.** Anticipated by the plan
   and recorded here: `genius_wallet_typography.dart` documents the floor being
   deliberately raised from 12 to 13 because 12px read too small on a touchscreen.
   Same call 12-03 made.
2. **Dev fixture: Today bucket uses minutes-from-now, not `subtract(Duration(hours:))`.**
   The plan suggested hours. Minutes is strictly better for the plan's own stated
   goal (three distinct calendar days): an hours-back offset folds into Yesterday
   for the first ~4 hours after local midnight, minutes-back only for the first ~40
   minutes. That residual window is named in a `ponytail:` comment with its upgrade
   path (clamp to local midnight) rather than coded around — it is a dev button.
3. **Yesterday / 3-days-back use `DateTime(y, m, d - n, h, m)`, not
   `subtract(Duration(days: n))`.** Wall-clock arithmetic is DST-immune; a
   `Duration` can land a row on the wrong calendar day on a 23/25-hour day, which
   would silently break the very separators this plan exists to add. Same reasoning
   `txDayLabel` already carries.
4. **Three extra widget tests beyond the plan's `(f)`.** `(f)` asked only for the
   pure copy helpers. The flatten loop's boundary rule (no divider at a day change)
   is the non-trivial logic in this plan and had nothing behind it; per `CLAUDE.md`
   that leaves it unfinished. Three cheap `Divider`-count assertions cover it.
5. **`filteredTransactions` getter deleted.** Not called for in the plan, but it
   became dead once `build` computed `txs` from `scoped` — deletion over addition.

## Verification actually run

```
$ flutter analyze lib/dashboard/home/widgets lib/dev/dev_mock_transactions.dart
Analyzing 2 items...
No issues found! (ran in 2.3s)

$ grep -v '^ *//' lib/dashboard/home/widgets/transactions_slim_view.dart | grep -c AutoSizeText
0
$ grep -v '^ *//' … | grep -cE 'FittedBox|textScalerOf|auto_size_text'
0                      # the 3 textual hits in the file are all comments
$ grep -c 'TransactionType.process' lib/dev/dev_mock_transactions.dart
1

$ flutter test test/dashboard/transaction_filters_test.dart
00:01 +41: All tests passed!            # was 33 before this plan

$ flutter test
00:04 +185 -1: Some tests failed.       # baseline was +177 -1

$ flutter build macos --debug
✓ Built build/macos/Build/Products/Debug/Genius Wallet.app
```

**The one red is the pre-existing one and only that one:**
`test/local_wallet_storage_test.dart` — `Failed to load … Missing definition of
'main' method` (the file is fully commented out). It fails at *load*, so the `-1`
is carried through every subsequent line of the run output; no individual test
reports a failure. Not introduced here, not fixed here.

Test count 177 → **185** (+8: 4 copy, 3 day-group, 1 branch-selection).

**Was anything rendered?** Yes, but only headlessly. The seven new widget tests
pump the real `TransactionsSlimView` in both appearances and assert on rendered
text and `Divider` counts, and `flutter build macos --debug` links the real app
successfully. I did **not** launch the interactive macOS app — that is 12-06's walk,
and a foreground `flutter run` is not something this executor can hold open. So
nothing here is a claim about how it *looks*: the header-rule-vs-Assets question,
day-header contrast in light mode, and whether the action-bearing filtered empty
state fits the short dashboard panel are all unjudged.

## Outstanding for 12-06

1. **Header rule vs the Assets panel** (above) — the deliberate divergence to judge.
2. **Filtered empty state in the SHORT dashboard panel.** `GWEmptyState` needs
   roughly 212px even in compact when it carries an action button, and it has no
   third button-shrinking tier (its own `ponytail:` names this ceiling). The
   dashboard panel may be shorter than that. Walk it at the real dashboard height,
   not just on `/transactions`.
3. **Day-header contrast in light mode.** `textSecondary` at 13px/w600 with
   `letterSpacing: 0.7` — not contrast-measured here; no test asserts it.
4. **Three mount points** compile and are unaffected by any API change (the
   `TransactionsSlimView` constructor is unchanged): `transactions_stream.dart`,
   `sgnus_transactions_screen.dart`, and `transactions_screen.dart` → the full-page
   `/transactions` route via `TransactionsStream`. Confirmed by the whole-`lib`
   analyze and the macOS build; **not confirmed visually.**

## Self-Check: PASSED

- `lib/dashboard/home/widgets/transactions_slim_view.dart` — FOUND (563 lines)
- `lib/dev/dev_mock_transactions.dart` — FOUND (229 lines)
- `test/dashboard/transaction_filters_test.dart` — FOUND (465 lines)
- Commits: **none, by design.** `HEAD` is still `ea33561`, staging area empty.
