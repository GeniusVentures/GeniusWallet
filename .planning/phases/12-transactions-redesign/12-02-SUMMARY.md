---
phase: 12-transactions-redesign
plan: 02
subsystem: dashboard/transactions
tags: [formatting, derivation, pure-functions, grouping, security]
requires:
  - TransactionBadgeKind (12-01)
  - genius_api Transaction model
  - WalletUtils.getAddressForDisplay
  - intl NumberFormat / DateFormat
  - Hive marketDataBox
  - DevMockHoldings
provides:
  - formatTxAmount
  - exactTxAmount
  - sanitizeCoinAsset
  - fiatValue
  - livePricesBySymbol
  - formatFiat
  - TxAmountTone
  - TxRowContent
  - txRowContent
  - txTimeLabel
  - txDayLabel
  - TxDay
  - groupTransactionsByDay
affects: [12-03 (row + drawer), 12-05 (panel day separators)]
tech-stack:
  added: []
  patterns:
    - "All row decisions derived in one pure function so the widget holds no switch (tx.type)"
    - "Absence over fabrication: an unknown price drops the fiat line instead of printing $0.00"
    - "Calendar-day comparison via DateTime(y, m, d - 1) rather than a Duration delta"
key-files:
  created:
    - test/dashboard/transaction_utils_test.dart
  modified:
    - lib/dashboard/home/widgets/transaction_utils.dart
decisions:
  - "formatTxAmount returns the MAGNITUDE ONLY in every branch, including the dust case — the plan's one sub-note said to sign the dust string, which would have made the caller's sign composition produce a doubled sign"
  - "The dust label is a const String, not string interpolation of the double — 0.000001.toString() is '1e-6'"
  - "formatFiat wraps a PRIVATE formatter rather than exporting a top-level `currencyFormatter`, which would collide with the same-named top-level in transaction_displays.dart and transactions_slim_view.dart"
metrics:
  duration: ~35 min
  completed: 2026-07-22
requirements: [TX-01, TX-05, TX-06, TX-08, TX-09]
status: complete
---

# Phase 12 Plan 02: Pure derivation in `transaction_utils.dart` Summary

Six of sketch 010's eight symptoms are formatting or content decisions, not layout. They now live
in pure functions with 40 unit tests that run in under a second without a pump, a Hive binding or
an asset bundle — so the diagnosis table is machine-checkable rather than eyeball-checkable.

## What was built

`lib/dashboard/home/widgets/transaction_utils.dart` grew from 42 to 499 lines in three sections.
`getExplorerUrl` and `formatAmount` are **byte-unchanged** — the diff on this file is 458
insertions and **zero deletions**.

### Formatting

| Function | Behaviour |
|---|---|
| `formatTxAmount(String)` | Unparseable/NaN/infinite → raw trimmed; `0` → `0.00`; `\|v\| >= 1000` → `#,##0.00`; `\|v\| < 0.000001` → `<0.000001`; else `#,##0.00####` (min 2, max 6 dp). Magnitude only. |
| `exactTxAmount(String)` | The raw model string when the clamp lost something, else null. Never round-trips through `double`. |
| `sanitizeCoinAsset(String)` | Lowercase, `a-z0-9` only, cap 12, `''` when nothing survives. |
| `fiatValue({symbol, amount, pricesBySymbol})` | `price * amount`, or **null** for an unknown symbol. |
| `livePricesBySymbol()` | The one impure function: `kDebugMode` mock → open Hive box → `const {}`. |
| `formatFiat(double)` | `$1,020.42` via a single module-level formatter. |

### Row content

`enum TxAmountTone { incoming, outgoing, none }`, an immutable `TxRowContent`
(`badge, title, action, subtitle, amount, tone, exactAmount, valueLine, iconSymbols, time`), and
`txRowContent(tx, {prices})` — the single function 12-03 renders. **The row widget must contain no
`switch (tx.type)` of its own**; that rule is what makes "one anatomy" true rather than
aspirational, and it is enforced by the seven-type loop in the test.

Badge: status wins over type (pending → `pending`; failed/cancelled → `failed`; else the type map,
with a null `type` treated exactly like `transfer`).

**Amount precedence** — failed/cancelled → em dash + `Not charged`; `process` → em dash + fee line;
`swap` → `+` and the TO side; everything else → sign by direction/type, `formatTxAmount` of
`recipients.first.amount`. The sign is **U+2212 REAL MINUS**, not a hyphen, so the column stays
aligned under tabular figures.

The fee is deliberately **absent** from `TxRowContent`. Its only survivor is the `process` value
line, where the fee *is* the transaction's economic content.

### Day grouping

`txTimeLabel` (24-hour `18:42`), `txDayLabel` (Today / Yesterday / `18 Jul` / `18 Jul 2025`),
`TxDay` and `groupTransactionsByDay(txs, {now})` — sorts a copy, buckets by local calendar day,
newest-first at both levels.

## The exact subtitle strings — REQUIRED READING FOR 12-06's WALK

**The model carries no job id, no purchase provider and no failure reason.** Sketch 014's
`Job #4192` and `Banxa · card` are mockup dressing with no field behind them. Every string below is
either a literal or derived from a field that exists. **A walker must not report these as wrong
data — there is no data to be wrong.**

| Type | Subtitle | Where it comes from |
|---|---|---|
| `escrow` | `Locked in escrow` | Literal. No escrow party/id in the model. |
| `escrowRelease` | `Released from escrow` | Literal. |
| `process` | `Job 0xabcd...7890` | `WalletUtils.getAddressForDisplay(tx.hash)`. **Not a job id** — the truncated tx hash standing in for one, because no job id field exists. |
| `purchase` | `Card purchase` | Literal. **No provider name** — nothing in the model says Banxa or which card. |
| `mint` | `Minted to wallet` | Literal. |
| `swap` | `1.50 ETH` | `formatTxAmount(fromAmount)` + `fromSymbol`. |
| `transfer` sent | `0x5555...8888` | `recipients.first.toAddr` |
| `transfer` received | `0x1111...4444` | `fromAddress` |

Two more literals not in the plan, added as empty-input guards (see Deviation 3):
`Unknown recipient` (sent with empty `recipients`) and `Unknown address` (a blank address string).

A non-completed status appends ` · Pending` / ` · Failed` / ` · Cancelled`. A **completed** row's
subtitle contains no status token at all — that is the whole of TX-09, and it is asserted for all
eight type cases.

There is also **no failure reason**: a failed row says `—` and `Not charged` and nothing about why.
The model has no field for it.

## Deviations from Plan

**1. [Rule 1 — Bug] The dust label is a literal, not an interpolated double**
- **Found during:** Task 1, before first run.
- **Issue:** I first wrote `return '<$_amountFloor';` against the `const double _amountFloor = 0.000001`. Dart renders that double as `1e-6`, so the row would have read **`<1e-6`** — scientific notation in a wallet balance.
- **Fix:** added `const String _amountFloorLabel = '<0.000001'` alongside the double and return that. Commented in place.
- **Files modified:** `lib/dashboard/home/widgets/transaction_utils.dart`

**2. [Rule 1 — Bug / spec conflict] `formatTxAmount` returns the magnitude in *every* branch, including dust**
- **Issue:** The plan's closing sentence says "Return the magnitude WITHOUT a sign or symbol; the caller composes those", but its dust bullet says the `<0.000001` string should be "prefixed with the sign for negatives". Those contradict. Honouring the sub-note would mean `txRowContent` — which unconditionally prepends `+` or `−` — emits **`− <0.000001`** for a positive dust amount and **`− −<0.000001`** for a negative one.
- **Fix:** the general rule wins; no branch ever returns a sign. One rule, one place a sign can be produced, no double-sign bug. Pinned by a test asserting `formatTxAmount('-0.75') == '0.75'`.
- **Impact:** a negative raw amount loses its sign at this layer. That is correct for this codebase — model amounts are positive strings and the direction carries the sign — but it is a real behavioural choice, so it is stated here rather than buried.

**3. [Rule 2 — Missing critical functionality] Non-empty fallbacks for blank addresses**
- **Issue:** The plan guards `recipients` emptiness, which I did. But `getAddressForDisplay('')` returns `''`, so a malformed record with a blank `fromAddress` or `toAddr` would produce an **empty subtitle** — the row's second line would collapse, and the plan's own "subtitle is non-empty for every type" criterion would be violated by real data while still passing a fixture-based test.
- **Fix:** `_addressLine()` returns `Unknown address` when the truncator yields empty; the empty-`recipients` sent case returns `Unknown recipient`.
- **Files modified:** `lib/dashboard/home/widgets/transaction_utils.dart`

**4. [Rule 3 — Blocking] `formatFiat` wraps a private formatter instead of exporting `currencyFormatter`**
- **Issue:** The plan says "declare one module-level formatter here so those two files can drop their private duplicates later". Both `transaction_displays.dart:16` and `transactions_slim_view.dart:14` declare a **top-level** `currencyFormatter`. Exporting that same name from `transaction_utils.dart` — which both files already import — would be an ambiguous-import analyzer error the moment either dropped its local copy.
- **Fix:** the formatter is private (`_fiatFormat`); the public surface is `formatFiat(double)`. Those two files can delete their duplicates and call `formatFiat` with no name collision.

**5. [Scope] The test file was created, not extended.** The plan says "extend `test/dashboard/transaction_utils_test.dart`"; it did not exist. Created.

**6. [Scope] No commits created.** `./CLAUDE.md` holds the commit gate and the plan's `<objective>` repeats it. All work is unstaged in the working tree; no `git add`, no `git commit`. The executor's per-task atomic-commit protocol was suppressed for all three tasks.

**7. [Scope] `STATE.md` / `ROADMAP.md` were not touched.** The working tree is shared and both already carry the user's uncommitted edits; the completion instruction asked only for this SUMMARY. 12-01 likewise left its ROADMAP checkbox unticked, so this stays consistent.

## Verification actually run

| Check | Command | Real output |
|---|---|---|
| Baseline, before any edit | `flutter test` | `00:04 +54 -1: Some tests failed.` — matches the stated baseline exactly |
| Plan verification 1 | `flutter test test/dashboard/transaction_utils_test.dart` | `00:00 +40: All tests passed!` |
| Plan verification 2 | `flutter analyze lib/dashboard/home/widgets/transaction_utils.dart lib/reown/swap_result_drawer.dart` | `No issues found! (ran in 3.3s)` — `formatAmount`'s second consumer is intact |
| Analyze incl. the test file | `flutter analyze <both lib files> test/dashboard/transaction_utils_test.dart` | `No issues found! (ran in 4.2s)` |
| No regression | `flutter test` | `00:03 +94 -1: Some tests failed.` — **54 + 40 = 94**, exactly this plan's new tests |
| Sole failure unchanged | `flutter test 2>&1 \| grep -E "\[E\]"` | `Failed to load ".../test/local_wallet_storage_test.dart": Missing definition of 'main' method.` — the pre-existing, fully-commented-out file. Still the only red. |
| `formatAmount` untouched | `git diff lib/.../transaction_utils.dart \| grep "^-"` | zero `-` lines; `git diff --stat` shows `458 ++++` and no deletions |
| No widget code in the test | `grep -nE "pumpWidget\|WidgetTester\|testWidgets"` | one hit, and it is the doc comment saying there is none |
| Nothing staged | `git status --short` | `M lib/dashboard/home/widgets/transaction_utils.dart`, `?? test/dashboard/`; the pre-existing `cmake/*` modifications are in the same state I found them |

### One test expectation was wrong on the first run — the code was right

`a swap carries both symbols and both icons` initially asserted `$1,020.43` for `1200.5 * 0.85`.
Real output: `$1,020.42`. The exact decimal is `1020.425`, a half-way case; as an IEEE754 double it
is `1020.42499…`, so it rounds down. **My arithmetic was wrong, not the implementation** — the
expectation was corrected to `$1,020.42` with the reason recorded in the test. Deterministic across
platforms.

## Threat mitigations delivered

| Threat ID | Delivered | Test that enforces it |
|---|---|---|
| T-12-01 (asset path tampering) | `sanitizeCoinAsset`, called inside `txRowContent` so the widget never sees a raw symbol | `'../../etc/passwd'` → `'etcpasswd'`; `'..%2F..%2Feth'` → `'2f2feth'`; and `coinSymbol: '../../etc/passwd'` → `iconSymbols == ['etcpasswd']` |
| T-12-02 (unbounded amount → layout starvation) | Early return on unparseable/NaN/infinite; hard 2-dp clamp ≥1000; hard 6-dp cap below | `'NaN'`, `'Infinity'`, `'-Infinity'`, `'not-a-number'`, `''` all pass through; the 9-decimal whale clamps |
| T-12-04 (a failed spend reading as successful) | Status appended only when `!= completed` | A loop over all eight type cases asserting a completed subtitle contains none of Completed/Pending/Failed/Cancelled; plus `'Pending'` appearing **exactly once** on a pending row |
| T-12-09 (spoofed symbol → wrong fiat) | Accepted as planned: unknown symbol → **no** line | `coinSymbol: 'NOPE'` → `valueLine` is null; the priced control returns `$2,400.00` |

## Not verified

- **Nothing has been rendered.** No app run, no pump, no golden. `txRowContent` has no caller yet —
  12-03 is its first. Whether `+ 123,456,789.12 ETH` actually fits the narrow panel is a layout
  question this plan cannot answer; it only guarantees the string is bounded.
- **`livePricesBySymbol()` was never executed.** It is the one impure function and it is
  deliberately untested — exercising it needs a Hive binding, which the plan's "no Hive binding in
  the test file" constraint forbids. Its `isBoxOpen` guard and the box's `CoinGeckoMarketData`
  typing were read from `lib/hive/init.dart:19`, not run. **First real exercise is 12-03.**
- **The em dash / real minus at render size.** U+2014 and U+2212 are asserted as strings; whether
  they read correctly in the app's font at the row's size is a 12-06 eyeball.
- **Light mode** — nothing in this plan is appearance-dependent, so there is nothing to defer.

## Success criteria

- [x] All seven `TransactionType` values plus a null type produce a complete row record (loop test, both directions)
- [x] `123456789.123456789123456789` → `123,456,789.12` with the exact value retrievable
- [x] A failed transaction produces exactly one status statement and zero currency zeros
- [x] Transactions group into calendar days with Today / Yesterday / date labels
- [x] `formatAmount` and its second consumer untouched — zero deletions in the diff
- [x] No commit created

## Self-Check: PASSED

- `lib/dashboard/home/widgets/transaction_utils.dart` — FOUND (499 lines, modified)
- `test/dashboard/transaction_utils_test.dart` — FOUND (530 lines, created)
- Commits — intentionally none (CLAUDE.md gate); nothing staged.
