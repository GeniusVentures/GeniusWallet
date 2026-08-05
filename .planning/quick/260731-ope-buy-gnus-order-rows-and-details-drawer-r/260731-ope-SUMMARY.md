---
phase: quick-260731-ope
plan: 01
subsystem: banxa
status: complete
tags: [banxa, transactions, drawer, rail, tdd]
requires:
  - lib/dashboard/home/widgets/transaction_utils.dart
  - lib/dashboard/home/widgets/transaction_displays.dart
  - lib/banxa/banxa_components/order_status_style.dart
  - lib/banxa/banxa_helpers/banxa_helpers.dart
provides:
  - orderTransactionStatus / orderAsTransaction / orderRowContent / orderTransactionRows / orderNetworkRows
  - TxDetailRow (drawer detail rows as data)
  - TxRowContent.statusLabel
  - TransactionRow.contentOverride
  - showTransactionDetails(contentOverride, extraTransactionRows, extraNetworkRows, footer)
affects:
  - lib/screens/banxa_buy_screen.dart
tech-stack:
  added: []
  patterns:
    - "pre-built record as a seam: the widget renders, the caller decides"
    - "extras as DATA, rendered through the drawer's own blank-skip helpers"
key-files:
  created:
    - lib/banxa/banxa_helpers/order_transaction_mapping.dart
    - test/banxa/order_transaction_mapping_test.dart
    - test/banxa/order_rail_row_test.dart
  modified:
    - lib/dashboard/home/widgets/transaction_utils.dart
    - lib/dashboard/home/widgets/transaction_displays.dart
    - lib/screens/banxa_buy_screen.dart
    - test/banxa/fixtures.dart
    - test/banxa/orders_header_track_test.dart
decisions:
  - "The status fold goes THROUGH orderStatusTone, so there is one census of Banxa status strings and no order changes colour."
  - "An error-tone order's value line reads Not charged, not its fiat (DEVIATION, see below)."
  - "The drawer's fiat row is labelled Order amount, not Amount paid (DEVIATION, see below)."
metrics:
  duration: ~2h
  completed: 2026-07-31
  tests_added: 34
  tests_total: 968
---

# Quick task 260731-ope: Buy GNUS order rows and details drawer Summary

The Buy GNUS "Your orders" rail now renders the Transactions tab's own
`TransactionRow`, and tapping one opens the Transactions tab's own
`showTransactionDetails` carrying every Banxa field a `Transaction` has no slot
for - via four additive seams and one new banxa-owned mapping file, with
`TransactionRow` still deciding nothing.

## NOT COMMITTED

Per Jakub's standing rule on this project, nothing was committed, staged or
pushed. Every change sits unstaged in the working tree on
`redesign/jakub-260730`. `ROADMAP.md` and `STATE.md` were deliberately left
untouched: quick tasks are separate from planned phases, and a second agent was
active in `lib/squid_router/` during this run (AGENTS.md's "a file is the unit
of conflict" rule).

## Gates - real numbers

| Gate | Result |
|---|---|
| `flutter analyze` (root) | **No issues found** (23.4s) |
| `flutter analyze` (`packages/genius_api`) | **No issues found** (2.7s) |
| `flutter test` (full suite) | **+968, All tests passed** - 0 failures |
| `tool/check_brace_style.sh --count` | **0** |
| `tool/check_raw_colors.sh --count` | **0** |
| `dart format` (8 touched files) | clean (re-run reports 0 changed) |

**Test count reconciliation.** Baseline measured at session start: **930
passing, all green** (run finished 18:06). Now **968**.

- +25 `test/banxa/order_transaction_mapping_test.dart` (new, pure unit)
- +9 `test/banxa/order_rail_row_test.dart` (new, widget)
- +4 **not mine**: `test/squid_router/swap_flip_centring_test.dart`, an
  untracked file written at 18:13 today by the concurrent squid_router agent.
  Outside this task's scope and untouched by it.

930 + 34 + 4 = 968. **Zero pre-existing tests newly failing.**

## What shipped

**One new file, `lib/banxa/banxa_helpers/order_transaction_mapping.dart`** -
five pure functions, no Flutter widget import, no `livePricesBySymbol()` call
and therefore no Hive box and no binding needed to test any of it:

- `orderTransactionStatus(String)` - a four-arm switch on `orderStatusTone()`
  with **no default arm**, so a future tone is a compile error. Routing through
  the existing tone function is what makes "not one order changes colour"
  structural rather than a promise, and keeps exactly ONE census of Banxa status
  strings in the repo. `cancelled` and `expired` land on `failed` because they
  are red today; `TransactionStatus.cancelled` is reached only by the
  unrecognised-status fallback.
- `orderRowContent(Order, {DateTime? now})` - the record the row renders. The
  crypto amount is the amount; the **fiat actually paid** is the value line
  (D-03). Nothing is lost by the 8-into-4 status fold because the LABEL never
  comes from the enum: an expired order reads "Expired" in the error paint, and
  an unknown future status reads its own name capitalised in the neutral paint.
- `orderAsTransaction(Order)` - `fees` and `fromAddress` deliberately BLANK,
  each with a one-line comment saying why (fiat fees would print as "1.00 BTC";
  Banxa gives no source address). The drawer's blank-skip guard drops both rows.
- `orderTransactionRows` / `orderNetworkRows` - `TxDetailRow` data, not widgets.

**Four additive seams**, every one an optional parameter or an optional field,
so all existing call sites emit byte-identical output (proven by `test/dashboard/`
staying green with no edits - 432 tests across `test/banxa/` + `test/dashboard/`):

1. `TxRowContent.statusLabel` (optional field, null = today's behaviour).
2. `TxDetailRow` (new type) in `transaction_utils.dart`.
3. `TransactionRow.contentOverride` - one line changed in `build`.
4. `showTransactionDetails(contentOverride, extraTransactionRows,
   extraNetworkRows, footer)` - extras rendered through the function's own
   `add`/`addCopy` closures; the NETWORK hash row moved below the extras loop so
   the hash stays terminal.

`transaction_displays.dart` imports nothing from `lib/banxa/` (the only match
for "banxa" in that file is a doc-comment pointer). `TransactionRow` gained no
`Order`, no bool flag and no Banxa branch.

**The rail.** `_OrderRailRow` is deleted, not left beside the new wiring; the
orphaned `intl` import went with it. Rows are `TransactionRow` +
`Divider(height: 1, thickness: 1, color: borderSubtle)` between them, none after
the last. No day headers (the day rides in each row's subtitle instead), no
chevron. `/orderDetails`, `order_details_page.dart`,
`banxa_orders_history.dart`, `checkout_qr.dart` and
`BanxaHelpers.buildOrderDetailsExtra` are untouched - only the rail's tap target
moved.

**The footer (D-02)** is gated on the RAW lowercased status (`pendingpayment`,
`declined`) - the same literals `order_details_page.dart` compares - not on the
mapped enum, which folds `inProgress` into `pending`. Both buttons pop the
drawer with a context from a `Builder` INSIDE the footer before acting.

## Deviations from the plan

### Deliberate design deviations - FOR JAKUB TO OVERRULE ON THE WALK

Both were called by the plan rather than by his literal answer on the walk of
2026-07-31. Both are implemented as planned. Both are one-line changes to undo.

**1. An error-tone order's value line reads `Not charged`, not the fiat amount.**
His answer put the fiat paid beneath the crypto amount, full stop. The plan
carved out the error bucket (`declined`, `cancelled`, `expired`, `failed`) and
gave it the Transactions tab's own dead-row treatment verbatim, because those
are exactly the statuses where we know no money moved and `444.44 USD` under a
declined order reads as money that left. The neutral (unrecognised) bucket
deliberately does NOT get this - printing `Not charged` there would be a
fabricated claim - so it keeps the fiat and drops only the green.
*To overrule:* `orderRowContent`'s `valueLine` ternary,
`order_transaction_mapping.dart`. One test asserts it
(`a declined order reads Not charged, never its fiat`).

**2. The drawer's fiat row is labelled `Order amount`, not `Amount paid`.**
Same reason, one level down: for a declined order the hero already says
`Not charged`, and a row saying "Amount paid" directly beneath it would
contradict it. "Order amount" is true in every status.
*To overrule:* one string literal in `orderTransactionRows`, plus the assertion
in `order_transaction_mapping_test.dart` and `order_rail_row_test.dart`.

### Mechanical deviations (no design content)

- **`test/banxa/fixtures.dart` gained optional params** on `testOrder()`:
  `network`, `processingFee`, `networkFee`, `transactionHash`,
  `walletAddressTag`, `country`, `metadata`. All default to today's values, so
  every existing caller is unchanged. Needed to test the absent-field and
  excluded-field rules at all.
- **`SeededOrdersCubit` promoted to `fixtures.dart`** as the plan specified, and
  a small `seededOrdersState(List<Order>)` helper went with it (the plan named
  only the cubit; both test files needed the state shape too). The private copy
  in `orders_header_track_test.dart` is deleted, not duplicated.
- **`orderNetworkRows` returns `const []`** for a blank chain, while the
  `Address tag` row uses the blank-value form and rides the drawer's blank-skip
  guard. Two shapes for the same rule, each as the plan's own behaviour list
  described it - the tag row keeps decision D's "no null-guards in the banxa
  layer", the network group avoids handing the drawer a list of one blank row.
- **`orderAsTransaction` is hoisted to one call per row**, shared by the row and
  the drawer it opens, so the two cannot disagree about a single order.

### The expected `orders_header_track_test.dart` fallout - repaired as specified

Its `_rowFor` finder keyed on a `Text.rich` containing the order's `fiatAmount`.
That broke **by construction**: the fiat is now a plain `Text` value line, and
for the declined fixture the row says `Not charged` instead, so the amount is
not on that row at all. Repaired exactly as the plan specified - the four seeded
orders got distinct `cryptoAmount` values (0.0011 / 0.0022 / 0.0033 / 0.0044,
each formatting to itself), and `_rowFor` now matches the amount line
`+ <cryptoAmount> <symbol>`.

**The assertion was NOT loosened.** The finder still identifies a specific
ROW BY ITS CONTENT - a different order's row cannot satisfy it - so the filter
tests still prove that selecting Issues keeps the declined order and drops the
completed one. Every other assertion in that file keeps its original meaning.

## Security

The threat register's five mitigations are all in place: every raw Banxa number
goes through `formatTxAmount` (the 37639d5 freeze guard), `crypto.id` is
sanitised in the mapper before it can reach an asset path (asserted by a test
that feeds it `../../etc/passwd`), and `externalCustomerId`, `paymentMethodId`,
`externalId`, `orderStatusUrl`, `orderType`, `country` and `metadata` are all
excluded - asserted by a test that seeds a country and a metadata map and greps
the whole rendered row set for them.

## Human walk checklist

1. Open **Buy GNUS**. The "Your orders" rows should read as Transactions-tab
   rows: time on the left, coin art with a badge, `BTC` + a `Purchased` chip, a
   `<day> · Card purchase` subtitle, and on the right the crypto amount with the
   **fiat paid** beneath it. Hairline dividers between rows, no chevrons, no day
   headers.
2. A declined order should show `Not charged` where the fiat would be, in grey,
   with a `· Declined` suffix on its subtitle. **This is deviation 1** - say so
   if you want the fiat there instead.
3. Tap a **pending** order: the drawer's footer should offer **Complete
   Payment** (filled gradient) and nothing else. It should pop the drawer and
   open the checkout sheet on top of the screen, not underneath it.
4. Tap a **declined** order: the footer should offer **Retry Order**
   (gradientOutline) and nothing else, prefilled from the order.
5. Tap a **completed** order: **no footer at all** (GNUS and BTC are not in
   `explorerMap`, so there is honestly nothing to open).
6. In any of those drawers, confirm the TRANSACTION group carries **Payment
   method**, **Order amount** (deviation 2 - the label), **Processing fee** and
   **Network fee** as two separate fiat rows, **Order ID** (copyable) and **To**
   (copyable), and that no row shows a dash or "Unknown" for something Banxa did
   not send - such a row should simply not be there.

## Self-Check: PASSED

- `lib/banxa/banxa_helpers/order_transaction_mapping.dart` - FOUND
- `test/banxa/order_transaction_mapping_test.dart` - FOUND (25 tests, green)
- `test/banxa/order_rail_row_test.dart` - FOUND (9 tests, green)
- `_OrderRailRow` in a non-comment line of `banxa_buy_screen.dart` - 0 matches
- `showTransactionDetails` in `banxa_buy_screen.dart` - 1 match
- Commits: none, by instruction. Working tree left dirty on
  `redesign/jakub-260730`.
