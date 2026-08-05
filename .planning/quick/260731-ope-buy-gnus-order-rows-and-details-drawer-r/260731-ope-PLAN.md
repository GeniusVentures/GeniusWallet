---
phase: quick-260731-ope
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - lib/dashboard/home/widgets/transaction_utils.dart
  - lib/dashboard/home/widgets/transaction_displays.dart
  - lib/banxa/banxa_helpers/order_transaction_mapping.dart
  - lib/screens/banxa_buy_screen.dart
  - test/banxa/fixtures.dart
  - test/banxa/order_transaction_mapping_test.dart
  - test/banxa/order_rail_row_test.dart
  - test/banxa/orders_header_track_test.dart
autonomous: true
requirements: [260731-ope]

must_haves:
  truths:
    - "A Buy GNUS Your orders row is a TransactionRow - the same widget the Transactions tab renders - with the same time column, coin identity, badge, title, action chip, subtitle and right-aligned amount column."
    - "The crypto amount is the row's amount and the FIAT PAID is the value line beneath it, taken from the order rather than from a live price lookup (D-03)."
    - "Tapping an order opens showTransactionDetails - the same drawer the Transactions tab opens - not a Banxa lookalike (D-01)."
    - "That drawer carries every Banxa detail worth showing, including the fields Transaction has no slot for: the payment method, the fiat pair, BOTH fees separately, the order id and the destination address (D-01)."
    - "A field Banxa does not provide renders as no row at all - not a dash, not Unknown, not an empty row (D-01)."
    - "A pendingPayment order's drawer offers Complete Payment, a declined order's offers Retry Order, and any other order's offers neither (D-02)."
    - "/orderDetails stays alive and unchanged as a route; only the rail's tap target moved (D-02)."
    - "TransactionRow still decides nothing: no Order parameter, no Banxa branch, no bool flag. Order-specific content arrives already built."
    - "Every change to transaction_displays.dart and transaction_utils.dart is an optional parameter or a new type that defaults to today's behaviour, so all existing call sites emit byte-identical output."
    - "_OrderRailRow is deleted, not left beside the new wiring."
    - "flutter analyze clean, full flutter test green, tool/check_brace_style.sh and tool/check_raw_colors.sh both 0, with real numbers reported."
  artifacts:
    - lib/banxa/banxa_helpers/order_transaction_mapping.dart
    - test/banxa/order_transaction_mapping_test.dart
    - test/banxa/order_rail_row_test.dart
  key_links:
    - "orderRowContent(Order) -> TransactionRow.contentOverride is the seam: it is the only place the fiat becomes the value line, and it is why the row stays pure."
    - "orderStatusTone(String) is the single existing classification of Banxa status strings; the Transaction status mapping goes THROUGH it, so no order changes colour and there is never a second census."
    - "TxDetailRow is data, not widgets, so the drawer's own add()/addCopy() blank-skip guard is what enforces D-01's absent-not-empty rule for Banxa fields too."
    - "order.status.toLowerCase() gates the footer buttons - the same literals order_details_page.dart uses - NOT the mapped TransactionStatus, which folds inProgress into pending."
---

<objective>
Make the Buy GNUS "Your orders" rows the Transactions-tab rows, and make tapping
one open the Transactions-tab drawer carrying every detail Banxa provides.

Locked decision IDs used throughout, mapped to Jakub's walk of 2026-07-31:
  - **D-01** (his "D1", the drawer): the SAME `showTransactionDetails`, showing all
    Banxa detail including the fields `Transaction` has no slot for; anything Banxa
    does not provide is simply absent.
  - **D-02** (his "D2", the actions): the drawer takes over `Complete Payment` and
    `Retry Order`, gated on the same statuses; `/orderDetails` stays alive.
  - **D-03** (his "D3", where the fiat goes): crypto amount in the right column,
    the fiat paid as the value line beneath it, because for a card purchase the
    fiat IS the value rather than an estimate.

Purpose: the rail hand-rolls a fourth row language on a screen that already has
one, and its tap target pushes a whole page for something the app renders as a
drawer everywhere else.

Output: one new banxa-owned mapping file, four additive seams in the two
transactions files, a rewritten rail body, and three test files.
</objective>

<execution_context>
@$HOME/.claude/gsd-core/workflows/execute-plan.md
@$HOME/.claude/gsd-core/templates/summary.md
</execution_context>

<context>
@.planning/STATE.md
@CLAUDE.md
@.planning/codebase/CONVENTIONS.md
@lib/dashboard/home/widgets/transaction_utils.dart
@lib/dashboard/home/widgets/transaction_displays.dart
@lib/dashboard/home/widgets/transactions_slim_view.dart
@lib/banxa/banxa_model.dart
@lib/banxa/banxa_components/order_status_style.dart
@lib/banxa/banxa_helpers/banxa_helpers.dart
@lib/screens/order_details_page.dart
@lib/screens/banxa_buy_screen.dart
@test/banxa/fixtures.dart
@test/banxa/orders_header_track_test.dart
@.planning/todos/pending/2026-07-31-banxa-orders-never-enter-the-transaction-store.md
</context>

<decisions>

Six calls this plan makes so the executor does not have to. Each is binding.

## A. The seam between an Order and the row's content - shape (i), a pre-built record

`TransactionRow` gains `TxRowContent? contentOverride`; when supplied it is used
verbatim and `txRowContent` is never called. `txRowContent` itself is not touched.

Why (i) and not an override threaded into `txRowContent`:
  - It keeps the widget pure. The row still renders one record and decides nothing,
    which is the property its own doc comment says makes the file work.
  - It keeps `txRowContent` free of an `Order`-shaped concept. A `valueLineOverride`
    parameter would put "sometimes the caller knows better than the price map" into
    the derivation that ~930 tests sit on, for one caller.
  - It is the only shape in which D-03 is EXPRESSED rather than patched. The order
    row's value line is not an override of a fiat estimate, it is a different fact -
    the fiat actually paid. A record built by the banxa layer says that; a parameter
    hole punched in the price path says "same thing, different source".
  - Bonus, load-bearing in tests: `??` short-circuits, so with `contentOverride`
    supplied the row never calls `livePricesBySymbol()` and therefore never touches
    Hive. The rail's widget tests need no Hive binding.

Parameter is named `contentOverride`, not `content`, in BOTH `TransactionRow` and
`showTransactionDetails`, so each keeps its existing `final content = ...` local and
exactly ONE line changes in each. Minimal diff in a file guarded by ~930 tests.

## B. What an Order maps to on the Transaction side

Census of the Banxa status strings this codebase actually handles, derived from
source, not invented:
  - `order_status_style.dart`'s `orderStatusTone`: `completed`; `pendingpayment`,
    `pending`, `inprogress`; `declined`, `cancelled`, `expired`, `failed`; plus a
    `default` arm.
  - `BanxaHelpers.getOrderStatuses()`: `""`, `pendingPayment`, `completed`,
    `declined`, `inProgress`, `expired`.
  - `order_details_page.dart`: `pendingpayment`, `declined` (lowercased compares).

**The mapping goes THROUGH `orderStatusTone`, not around it.** The two colour
ladders are already the same four paints - `txStatusColors` and `orderStatusPaint`
are a verbatim copy of one another (order_status_style.dart says so in its own doc:
"copied verbatim from the shipped `_statusPill`"). So there is an exact bijection:

| `OrderStatusTone` | `TransactionStatus` | paint |
|---|---|---|
| success | completed | statusSuccess on 14% wash |
| warning | pending | statusWarningText on statusWarning 16% |
| error | failed | statusError on 14% wash |
| neutral | cancelled | textSecondary on surfaceMenu |

`orderTransactionStatus(String status)` is therefore a four-arm switch on
`orderStatusTone(status)` - exhaustive over the enum, no `default` needed. Which
gives, for the censused set:

| Banxa status | tone | TransactionStatus |
|---|---|---|
| completed | success | completed |
| pendingPayment | warning | pending |
| pending | warning | pending |
| inProgress | warning | pending |
| declined | error | failed |
| cancelled | error | failed |
| expired | error | failed |
| failed | error | failed |
| `""` or anything unrecognised | neutral | cancelled |

Why through the tone function rather than a fresh table:
  - Not one order changes colour. `order_status_style.dart`'s own D-01 rule is
    "EXTENDS today's status coloring and never inverts it"; routing through it makes
    that structural instead of a promise.
  - There stays exactly ONE census of Banxa status strings in the repo. A second
    table is a second thing to forget when Banxa adds a status.
  - It explains the two results that look odd in isolation: `cancelled` maps to
    `failed` (because it is red today) and `expired` maps to `failed` (because it is
    red today and because the Issues chip counts it). `TransactionStatus.cancelled`
    is reached ONLY by the unrecognised fallback.

**Nothing is lost by the 8-into-4 fold, because the LABEL is never derived from the
enum.** `orderRowContent` sets `TxRowContent.statusLabel` from
`BanxaHelpers.getOrderStatusLabel(order.status)` (which already renders
`pendingPayment` as "Pending Payment" and `inProgress` as "In Progress"), falling
back to the raw string with its first letter capitalised when that helper passes it
through unchanged, and to `null` when the raw status is blank. So an expired order
reads "Expired" in the error paint, not "Failed", and an unknown future status reads
its own name in the neutral paint.

Fallback statement, explicitly: an unrecognised status maps to
`TransactionStatus.cancelled`, which paints slate - the same neutral paint
`orderStatusTone`'s `default` arm already gives it - and keeps its raw label.

**Tone and value line follow the TONE, not the mapped enum.** This is the one place
the order mapping deliberately diverges from `txRowContent`'s `isDead` rule, and the
reason is that the fold moved `cancelled`:

| tone | `TxAmountTone` | value line |
|---|---|---|
| success | incoming | the fiat paid (D-03) |
| warning | incoming | the fiat paid (D-03) |
| error | none | `Not charged` |
| neutral | none | the fiat paid (D-03) |

`txRowContent` treats `failed` and `cancelled` alike as dead. Here, `error` is
exactly the set of statuses where we KNOW no money moved, so it takes the tab's own
`Not charged` treatment verbatim. `neutral` is the unrecognised bucket, where
printing `Not charged` would be a fabricated claim - so it keeps the order's own
fiat amount and drops only the green (`none`, grey), which is the honest "no claim
about settlement" ink. Badge follows the same source: warning to
`TransactionBadgeKind.pending`, error to `.failed`, success and neutral to
`.purchase`, mirroring `txRowContent`'s "status wins over type" rule.

## C. Which rows the drawer gains, in which group, and which it does not

The synthesized `Transaction` already feeds these base rows and they are NOT
duplicated as extras: Date (from `createdAt`), Status (label per B), Exact amount
(only when the clamp lost precision), Network (the coin symbol), Hash (blank when
Banxa gave no `transactionHash`, so the row and the explorer footer both vanish -
D-01's absent-not-empty, using the drawer's existing guard).

Two fields must NOT be routed through the base rows, and this is D-01(b) in
practice:
  - `tx.fees` stays BLANK. Banxa's `networkFee` and `processingFee` are fiat line
    items on a card receipt; the base Network Fee row would print them suffixed with
    the coin symbol ("1.00 BTC"), which is false. Blank skips that row.
  - `tx.fromAddress` stays BLANK, so the base counterparty row skips. Banxa provides
    no source address; the DESTINATION goes in as an extra with the right label.

INCLUDED extras:

| Group | Label | Source | Copy | Why |
|---|---|---|---|---|
| TRANSACTION | To | `walletAddress` | yes | the destination; the base counterparty row is empty for an order, and this is the one address a person eyeball-verifies |
| TRANSACTION | Address tag | `walletAddressTag` | yes | a wrong memo/destination tag loses funds on the chains that use one; null on most, blank-skipped |
| TRANSACTION | Order amount | `fiatAmount` + `fiat` | no | the figure to compare against a bank statement, and the thing the two fee rows are fees ON. Labelled "Order amount", NOT "Amount paid": for a declined order the hero already says `Not charged`, and "paid" would contradict it |
| TRANSACTION | Processing fee | `processingFee` + `fiat` | no | Banxa's own charge. `Transaction` has one `fees` slot and it is the wrong currency |
| TRANSACTION | Network fee | `networkFee` + `fiat` | no | kept next to its sibling rather than exiled to the NETWORK group: these are two components of ONE fiat charge, and splitting them across two groups makes neither readable |
| TRANSACTION | Payment method | `paymentMethodName` | no | how it was paid - the most-asked question about a purchase, and D-01's own named example |
| TRANSACTION | Order ID | `id` | yes | what Banxa support asks for. Sketch 154-D's whole premise is that this drawer is opened to get an identifier out |
| TRANSACTION | Last updated | `updatedAt`, only when it differs from `createdAt` | no | for a pending order it is the only signal that anything moved; equal to Date on a fresh order, where a second date row would be noise |
| NETWORK | Chain | `crypto.network` | no | blank in sandbox so it usually does not render; when present it disambiguates the same symbol on two chains |

EXCLUDED, with reasons - D-01 says show what Banxa provides, and an internal id soup
is not what was asked for:

| Field | Why not |
|---|---|
| `externalCustomerId` | our customer key for this user, not a property of the purchase. It tells the user nothing and printing it widens the PII surface of a screenshot |
| `paymentMethodId` | the machine key for a name already shown. Two rows for one fact, one of them unreadable |
| `externalId` | our app-side reference. `id` is the one Banxa support quotes; showing both invites the user to quote the wrong one |
| `orderStatusUrl` | a URL is not a value. It is what the Complete Payment footer already opens (D-02); a raw URL row is an unreadable duplicate of an action |
| `orderType` | constant (`CRYPTO-BUY`) for every order this screen can produce. A row that always says the same thing is chrome |
| `country` | Banxa's KYC jurisdiction for the account, not a fact about this purchase. The user knows their own country |
| `metadata` | an untyped map from an external API. Rendering unknown keys into a receipt is exactly the id soup D-01 is not asking for, and it is an unbounded attacker-influenced string reaching text layout - the 37639d5 freeze class |
| `crypto.blockchain`, `crypto.address` | `blockchain` duplicates the Network row's symbol on every observed payload; `crypto.address` is Banxa's echo of the destination, and printing two addresses invites comparing them by eye |

## D. The mechanism for extras, the status label, and the footer

`showTransactionDetails` is a top-level function, so the additive shape is optional
named parameters. Four of them, and each was checked against how the function
composes its `ResponsiveDrawer.show` call:

  1. `TxRowContent? contentOverride` - one line changes (`final content =
     contentOverride ?? txRowContent(...)`). It feeds the hero identity, the hero
     amount, the hero fiat line (D-03) and the drawer title, all of which already
     read from `content`.
  2. `List<TxDetailRow> extraTransactionRows = const []`
  3. `List<TxDetailRow> extraNetworkRows = const []`
  4. `Widget? footer` - when non-null it REPLACES the View on Explorer button.

`TxDetailRow` is DATA, not widgets: a small immutable `(String label, String value,
{bool copy = false})` declared in `transaction_utils.dart`. Three reasons this beats
`List<Widget>`:
  - `_buildRow` and `_CopyRow` are private to `transaction_displays.dart`, so a
    caller in `lib/banxa/` physically cannot build the right widgets.
  - Rendering the extras through the drawer's own `add()` / `addCopy()` gives
    D-01(c) for free: those helpers already return early on a blank value, which is
    precisely the "not a dash, not Unknown, not an empty row" mechanism the decision
    names. No null-guards get written in the banxa layer.
  - It keeps the banxa mapping file free of any Flutter widget import.

Placement inside the two groups:
  - TRANSACTION extras are APPENDED after the base rows (Date, Status, Exact amount,
    counterparty).
  - NETWORK extras are INSERTED between the base Network/Network Fee rows and the
    Hash row - the hash is the group's terminal identifier and the explorer footer's
    subject. This moves the existing `addCopy(netRows, ... , tx.hash)` call below the
    extras loop; with the default empty list the emitted row order is byte-identical
    to today, so no existing call site changes.

Status label rides on `TxRowContent` as a new optional field `String? statusLabel`,
not as a fifth drawer parameter. `TxRowContent`'s constructor gains `this.statusLabel`
with no `required` and no default other than null; `txRowContent()` does not set it,
so every existing construction (there is exactly one, inside `transaction_utils.dart`
- no test constructs the record directly) is unchanged. Two consumers read it, both
falling back to today's value when null: the Status detail row
(`content.statusLabel ?? _capitalizeStatus(status)`) and `_statusPill`, which gains
an optional `String? label`. Putting it on the record rather than on the function
also means the WIDE row's pill gets it for free if that branch is ever reached.

Footer replacement rather than stacking: a pendingPayment order has no settled hash,
so there is no explorer URL to lose, and two full-width `lg` buttons in a drawer
footer is not a pattern this app has anywhere. A completed order passes `null` and
keeps today's behaviour - the explorer button when the chain is in `explorerMap`,
nothing when it is not (GNUS and BTC are not, so in practice a completed GNUS order
shows no footer, which is honest).

Footer construction (D-02), and the trap in it: the buttons must pop the drawer
BEFORE acting, because `showCheckoutOptionsSheet` opens a modal sheet and Retry
pushes a route - either would land underneath an open drawer. The pop context must
come from a `Builder` placed INSIDE the footer, so `Navigator.of(ctx)` resolves to
the navigator hosting the drawer route. Do NOT copy `buy_success_drawer.dart:25`'s
use of the outer `context`: under a GoRouter shell that resolves to the shell
navigator and would pop the screen instead of the drawer.

Button gating uses the RAW status string lowercased - `pendingpayment` and
`declined`, exactly the literals `order_details_page.dart:65-99` compares - and NOT
the mapped `TransactionStatus`, which folds `inProgress` into `pending` and would
offer Complete Payment on an order that cannot be paid. `Complete Payment` also
requires a non-empty `orderStatusUrl` and a non-empty `id`, mirroring
`_effectiveCheckoutUrl`'s fallback arm.

Button weight: `Complete Payment` is `GWButtonVariant.gradient` (a commitment - it
takes you to pay), `Retry Order` is `GWButtonVariant.gradientOutline` (it opens a
form and commits to nothing - the same reasoning that made the explorer button
hollow). Both `size: GWButtonSize.lg, expand: true`, the drawer-footer convention.
This deliberately differs from `order_details_page.dart`'s `secondary` Retry button;
that page keeps its own, unchanged (D-02).

## E. Rail chrome - dividers yes, day headers no

**Dividers: YES.** `Divider(height: 1, thickness: 1, color: context.gw.borderSubtle)`
between rows, none after the last, exactly as `transactions_slim_view.dart:512`
draws them. "Same layout" is a claim about the list, not only about one row, and
`TransactionRow`'s own space6/space4 padding is calibrated for a hairline neighbour
rather than a card gap. Accepted cost, stated so nobody tries to fix it: inside
`GWCard` the hairline is inset by the card's padding instead of running full-bleed
like the tab's. Do not negative-margin it out.

**Day headers: NO.** Arguing both ways honestly:
  - FOR: the tab groups by day, and grouping is where the tab states a DATE at all.
  - AGAINST: the rail renders at most four rows (`visible.take(4)`), and orders are
    created one at a time on different days, so the common case is one header per
    row - eight elements for four facts, in a card with a bounded slot. The tab
    groups because it renders an unbounded history where the date would otherwise be
    lost; that condition does not hold here.

AGAINST wins, but it leaves a real hole: `TxRowContent.time` is `HH:mm` only, so
without a header a three-week-old order would read "09:14". So the day label goes
into the row's own context line instead: `subtitleBase` is
`"<txDayLabel(createdAt, now)> · Card purchase"`, using the same `·` separator and
the same `txDayLabel` the tab's headers use, and the status suffix appends after it
for a non-completed order ("3 Jul · Card purchase · Declined"). Nothing is lost and
the rail stays four rows tall.

The subtitle keeps the literal "Card purchase" rather than `paymentMethodName`.
Reason: it is `txRowContent`'s own purchase-arm string, so the row is the tab's
anatomy verbatim, which is what was asked; the payment method is a detail and it
gets a dedicated drawer row where nothing is lost. If the walk disagrees this is a
one-line change in `orderRowContent`.

Also gone with the old row and NOT reinstated: the trailing `Icons.chevron_right`.
The tab's rows carry no chevron; `GWHoverRow` inside `TransactionRow` is the
affordance, and it is the same one the tab uses.

## F. Where the mapping lives

`lib/banxa/banxa_helpers/order_transaction_mapping.dart` - a new file beside
`banxa_helpers.dart`, exporting `orderTransactionStatus`, `orderAsTransaction`,
`orderRowContent`, `orderTransactionRows` and `orderNetworkRows`.

Why there and not in the screen, and not in the transactions files:
  - The banxa layer owns banxa knowledge. Every fact this file encodes is a Banxa
    fact: which status strings exist, that the fees are denominated in fiat, that
    `externalId` is ours and `id` is theirs, that `transactionHash` may be absent.
    None of it belongs in `transaction_utils.dart`, which must stay ignorant of
    orders (hard constraint 1 at the file level, not only the widget level).
  - Not the screen file: it is a pure function set with no widgets, so it is unit
    testable with no pump, no binding and no Hive - and `banxa_buy_screen.dart` is
    already 999 lines.
  - Not inside `banxa_helpers.dart`: that file is under a standing "stays
    byte-for-byte" instruction from Phase 9 (09-CONTEXT.md D-06). It is READ here
    (`getOrderStatusLabel`) and not modified.
  - It makes no `livePricesBySymbol()` call - by D-03 there is no price lookup in an
    order's value line - so it needs no Hive box and no `TestWidgetsFlutterBinding`.

</decisions>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: The four additive seams and the banxa mapping, with pure unit tests</name>
  <files>lib/dashboard/home/widgets/transaction_utils.dart, lib/dashboard/home/widgets/transaction_displays.dart, lib/banxa/banxa_helpers/order_transaction_mapping.dart, test/banxa/order_transaction_mapping_test.dart</files>
  <behavior>
    - `orderTransactionStatus` returns completed for `completed`; pending for `pendingPayment`, `pending`, `inProgress`; failed for `declined`, `cancelled`, `expired`, `failed`; cancelled for `""` and for an unrecognised string. Case-insensitive on all of them (it delegates to `orderStatusTone`, which lowercases).
    - `orderRowContent` on a completed order: amount `+ 0.0025 BTC`, tone incoming, value line `100.00 USD`, action `Purchased`, title `BTC`, subtitle starting with the day label and containing `Card purchase`, statusLabel `Completed`, badge purchase.
    - `orderRowContent` on a declined order: value line `Not charged`, tone none, badge failed, statusLabel `Declined`, subtitle carrying the ` · Declined` suffix.
    - `orderRowContent` on a pendingPayment order: value line still the fiat, badge pending, statusLabel `Pending Payment`.
    - `orderRowContent` on an unrecognised status: value line still the fiat, tone none, statusLabel the raw string capitalised, and NOT the string `Not charged`.
    - `orderRowContent` value line uses the order's own fiat and never a price map: an order whose fiat is `EUR` renders `100.00 EUR`, with no currency symbol prefix.
    - `orderAsTransaction` leaves `fees` blank and `fromAddress` blank, sets `hash` to the order's `transactionHash` or blank when null, sets direction received, type purchase, coinSymbol `crypto.id`, timeStamp `createdAt`, and one recipient carrying `walletAddress` and `cryptoAmount`.
    - `orderTransactionRows` contains a `Payment method` row, an `Order amount` row reading `100.00 USD`, separate `Processing fee` and `Network fee` rows, an `Order ID` copy row, a `To` copy row, and NO row whose label or value mentions the external customer id, the payment method id, the external order id, the status URL, the order type, the country or the metadata.
    - `orderTransactionRows` on an order whose `walletAddressTag` is null emits no tag row at all (the list simply does not contain it, or contains it with a blank value that the drawer will skip).
    - `orderNetworkRows` emits a `Chain` row only when `crypto.network` is non-blank.
  </behavior>
  <action>
Write the failing tests in `test/banxa/order_transaction_mapping_test.dart` FIRST, from the behaviour list above, using `testOrder()` from `test/banxa/fixtures.dart`. This file needs no `TestWidgetsFlutterBinding`, no pump and no Hive: everything under test is a pure function. Run it and see it fail before writing any lib code.

Then make three additive edits, in this order.

**`transaction_utils.dart`.** Add an optional field `statusLabel` to `TxRowContent`: a `final String?` with a doc line saying it is the display label when the enum's own name is not the truthful one (a Banxa order's `Expired` folds onto `TransactionStatus.failed`), and null meaning "use the enum name". Add it to the constructor WITHOUT `required` and as the last parameter, so the single existing construction inside `txRowContent()` compiles unchanged and keeps emitting null. Do not touch `txRowContent`'s body. Then add a new immutable class `TxDetailRow` with positional `label` and `value` and a named `bool copy` defaulting to false, documented as the DATA form of a drawer detail row - the drawer renders it through its own blank-skip helpers, which is what keeps a field Banxa did not provide from becoming an empty row (per D-01).

**`transaction_displays.dart`.** Four changes, each one line or one block, no reflow of anything else. (a) `TransactionRow` gains `this.contentOverride` (a `TxRowContent?`) and its `final content = txRowContent(...)` line becomes `contentOverride ?? txRowContent(...)`; document that a caller supplying it owns the whole record and that the row still decides nothing. (b) `_statusPill` gains an optional `String? label` and renders `label ?? _capitalizeStatus(status)`; update the row's wide-branch call to pass `content.statusLabel` and the drawer hero's call likewise. (c) `showTransactionDetails` gains the four optional parameters from decision D, with `contentOverride` resolved on the same one-line pattern, and the Status row's value becoming `content.statusLabel ?? _capitalizeStatus(status)`. (d) render the extras: after the TRANSACTION group's existing rows, loop the transaction extras through the existing `add`/`addCopy` closures by the row's `copy` flag; for NETWORK, move the existing hash `addCopy` call to AFTER the network extras loop so the hash stays terminal. Add a comment stating that with the default empty lists the emitted rows are identical to today's, which is why every existing call site (`transactions_slim_view.dart`, `swap_screen.dart`, `bridge_screen.dart`, `dev_tools_bubble.dart`) is unaffected. Do NOT add an `Order` import, an `Order?` parameter or any Banxa concept to this file.

**`lib/banxa/banxa_helpers/order_transaction_mapping.dart`.** New file, no Flutter widget imports (it may import `package:flutter/foundation.dart` for `@immutable` only if needed). Implement the five functions per decisions B, C and E. `orderTransactionStatus` is a four-arm switch on `orderStatusTone(status)` with no default arm, so a future tone forces a compile error rather than a silent fallback. `orderRowContent` builds the record with: badge and tone and value line from the tone table in decision B; title `order.crypto.id`; action `Purchased`; `subtitleBase` composed as the day label from `txDayLabel(order.createdAt, DateTime.now())`, then the middle dot separator, then `Card purchase`; `subtitle` equal to `subtitleBase` for a completed order and `subtitleBase` plus the separator plus the status label otherwise; `amount` as a plus sign, a space, `formatTxAmount(order.cryptoAmount)` and the symbol; `exactAmount` from `exactTxAmount(order.cryptoAmount)`; `iconSymbols` as a single `sanitizeCoinAsset(order.crypto.id)`; `time` from `txTimeLabel(order.createdAt)`; `statusLabel` per decision B. The value line is `formatTxAmount(order.fiatAmount)` followed by a space and `order.fiat` - use `formatTxAmount` (it carries the 37639d5 unbounded-string guard) and never `formatFiat`, whose dollar prefix would be wrong for any non-USD order. Accept an injectable `DateTime? now` on `orderRowContent` so the day label is testable without wall-clock dependence, defaulting to `DateTime.now()`. `orderAsTransaction` and the two row builders follow decision C's tables exactly, including the deliberately blank `fees` and `fromAddress`, each with a one-line comment saying WHY it is blank.
  </action>
  <verify>
    <automated>flutter test test/banxa/order_transaction_mapping_test.dart test/dashboard/ && flutter analyze lib/banxa/banxa_helpers/order_transaction_mapping.dart lib/dashboard/home/widgets/</automated>
  </verify>
  <done>The new test file passes; every pre-existing test under test/dashboard/ still passes unchanged; analyze is clean on the three touched lib paths; transaction_displays.dart contains no reference to Order and TransactionRow has gained no bool flag.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: Rewire the rail onto TransactionRow and the shared drawer</name>
  <files>lib/screens/banxa_buy_screen.dart, test/banxa/fixtures.dart, test/banxa/order_rail_row_test.dart, test/banxa/orders_header_track_test.dart</files>
  <behavior>
    - An order in the rail renders a `TransactionRow`, and the rendered text includes the fiat value line (`111.11 USD`) and the crypto amount line (`+ 0.0011 BTC`) - asserted on text, not on the widget type alone (D-03).
    - Tapping an order row opens the shared drawer: both the `Transaction` and `Network` kickers are present, and the payment method value renders INSIDE a `GWDetailGrid`, which proves it is the same drawer carrying a Banxa-only field rather than a lookalike (D-01).
    - A drawer opened on an order whose `transactionHash` is null shows no Hash row and no View on Explorer button (D-01's absent-not-empty).
    - A `pendingPayment` order's drawer offers `Complete Payment` and NOT `Retry Order`.
    - A `declined` order's drawer offers `Retry Order` and NOT `Complete Payment`.
    - A `completed` order's drawer offers NEITHER.
    - Rows are separated by a `Divider` and there is no day-header kicker between them.
  </behavior>
  <action>
Write the failing widget tests in `test/banxa/order_rail_row_test.dart` FIRST. Seed real orders exactly the way `orders_header_track_test.dart` already does - a test-only `OrdersCubit` subclass overriding `fetchOrders` to emit a fixed `OrdersState` - but promote that subclass to `test/banxa/fixtures.dart` as a public `SeededOrdersCubit` and have BOTH test files use it, deleting the private copy from `orders_header_track_test.dart`; the second consumer arrives in this same task and fixtures.dart is already the shared fixture home. Pump through the real public `BanxaBuyScreen` inside `gwHost`, use `tester.binding.setSurfaceSize` at 1600 by 1200 (tall enough that the drawer's detail grids are built rather than off-viewport), and pump in fixed steps rather than `pumpAndSettle`, matching the rest of `test/banxa/`. Assert button PRESENCE only - do not tap `Retry Order`, which calls `context.push` and would throw outside a GoRouter host.

Then rewrite the rail body in `lib/screens/banxa_buy_screen.dart`.

Delete the `_OrderRailRow` class entirely. Its doc comment argued against reusing `OrderCard` because that widget carries up to three action buttons; that argument was about `OrderCard` and is now obsolete. Replace it with a short comment on the new row builder recording what the rail renders now and why, so nothing stale contradicts the wiring.

In `_OrdersRail.build`, replace the `for (final order in recent) _OrderRailRow(...)` loop with an interleave that produces, for each order: a `TransactionRow` carrying `tx: orderAsTransaction(order)`, `contentOverride: orderRowContent(order)` and an `onTap`, followed by a `Divider(height: 1, thickness: 1, color: context.gw.borderSubtle)` for every order except the last (decision E). Build the row list before the `GWCard`'s `Column` children rather than computing it inline in the widget tree.

The `onTap` calls `showTransactionDetails(context, tx)` with `contentOverride`, `extraTransactionRows: orderTransactionRows(order)`, `extraNetworkRows: orderNetworkRows(order)` and a footer built by a new private helper. That helper returns null unless the lowercased raw status is `pendingpayment` (and `orderStatusUrl` and `id` are both non-empty) or `declined`; the two live cases return a `GWButton` wrapped in a `Builder` so the press can pop the drawer with a context inside the drawer route, then act - `showCheckoutOptionsSheet` with the order's `orderStatusUrl`, its `id` and `BanxaApiService.redirectUrl` for the first, `context.push` to the create-order route with the same prefilled extra map `order_details_page.dart:86-95` builds for the second. Weight and size per decision D. Capture the SCREEN-level context in the closure for the action itself, and pop before acting; the file already carries a file-level ignore for the synchronous-context lint.

Leave `/orderDetails`, `order_details_page.dart`, `banxa_orders_history.dart`, `checkout_qr.dart` and `BanxaHelpers.buildOrderDetailsExtra` untouched - the route stays reachable from its other two callers and from post-payment redirects (D-02). Only the rail's tap target moved. Then remove whatever imports the deletion orphaned (the analyzer will name them) without removing anything still in use by the header, the form or the filter chips.

Finally, repair the fallout in `orders_header_track_test.dart`, which is expected and is not a design change: its `_rowFor` finder keys on a `Text.rich` whose plain text contains the order's `fiatAmount`, and the new row renders the fiat as a plain `Text` value line - and for the declined fixture it renders the not-charged string instead, so `fiatAmount` is not on that row at all. Give the four seeded orders distinct `cryptoAmount` values that format to themselves (0.0011, 0.0022, 0.0033, 0.0044) and rewrite `_rowFor` to find the amount line text: a plus sign, a space, the order's `cryptoAmount`, a space, and `crypto.id`. Every existing assertion in that file must keep its original meaning - the filter and count tests are not this task's subject.
  </action>
  <verify>
    <automated>flutter test test/banxa/ && grep -vE '^\s*(//|///)' lib/screens/banxa_buy_screen.dart | grep -c 'OrderRailRow' | grep -qx 0 && grep -c 'showTransactionDetails' lib/screens/banxa_buy_screen.dart</automated>
  </verify>
  <done>The new rail test file passes all seven behaviours; the whole test/banxa/ directory is green; no non-comment line of banxa_buy_screen.dart mentions the deleted row widget; the screen calls showTransactionDetails.</done>
</task>

<task type="auto">
  <name>Task 3: Full gate sweep, with real numbers, and no commit</name>
  <files>(no source changes expected; fix-forward only if a gate fails)</files>
  <action>
Run all four gates from the repo root and report the REAL numbers in the summary, not adjectives: `flutter analyze` (root, and `packages/genius_api` if the root run does not cover it), the FULL `flutter test` suite, `tool/check_brace_style.sh` and `tool/check_raw_colors.sh`. Baseline to compare against is roughly 930 passing tests with both shell gates at 0; the expected new total is the baseline plus the tests added in Tasks 1 and 2, with zero pre-existing tests newly failing. Also run `dart format` on the touched files and report it clean.

If a gate fails, fix forward within the decisions above - do not relax a decision to make a gate pass, and do not delete or weaken an assertion to make a test green. If a failure implicates a decision, stop and report it rather than improvising a different design.

**Do NOT commit and do NOT push.** This overrides the GSD atomic-commit default: it is Jakub's standing rule on this project. He reviews locally on `redesign/jakub-260730` and opens the PR into `ui-redesign-port` himself. Leave the tree dirty.

Write the summary with: the four gate numbers, the before/after test counts, the row and drawer decisions actually shipped, and a short human walk checklist - open Buy GNUS, confirm the rows read as Transactions-tab rows with the fiat beneath the crypto amount, tap each of a pending, a declined and a completed order and confirm the drawer's footer in each case, and confirm the payment method and both fee rows are present in the drawer.
  </action>
  <verify>
    <automated>flutter analyze && flutter test && tool/check_brace_style.sh && tool/check_raw_colors.sh</automated>
  </verify>
  <done>All four gates reported with real numbers; test count is at or above baseline plus the new tests with no new failures; nothing committed and nothing pushed.</done>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| Banxa API to app | every `Order` field is attacker-influenceable third-party JSON, and this change routes it into text layout, an asset path and the clipboard for the first time |
| drawer to OS | the copy rows put order identifiers and a wallet address on the system clipboard |

## STRIDE Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation Plan |
|-----------|----------|-----------|----------|-------------|-----------------|
| T-ope-01 | Denial of Service | `orderRowContent` amount and value line | medium | mitigate | every raw Banxa number goes through `formatTxAmount`, whose unparseable/NaN/infinite early return is the 37639d5 freeze guard; no unbounded string reaches layout unclamped |
| T-ope-02 | Tampering | `crypto.id` reaching `assets/images/crypto/<symbol>.png` | medium | mitigate | `sanitizeCoinAsset` is applied in the mapper, so the widget never sees the raw symbol - the same rule `txRowContent` already follows |
| T-ope-03 | Information Disclosure | drawer detail rows | low | mitigate | `externalCustomerId`, `paymentMethodId` and raw `metadata` are excluded by decision C, so no internal key and no untyped external map is rendered |
| T-ope-04 | Denial of Service | drawer rows built from Banxa strings | low | mitigate | `_buildRow` already clamps to `maxLines: 1` with ellipsis, and `_CopyRow` chunks and truncates; extras render through those same two helpers rather than new widgets |
| T-ope-05 | Spoofing | status label rendered verbatim from the API | low | accept | the label is drawn as plain text in a labelled Status row inside the app's own pill, cannot alter the paint (which comes from the four-tone ladder), and preserving it is exactly what D-01 asks for |
</threat_model>

<verification>
- `TransactionRow`'s constructor has no `Order`, no bool flag and no Banxa branch; `transaction_displays.dart` imports nothing from `lib/banxa/`.
- Every edit to `transaction_displays.dart` and `transaction_utils.dart` is an optional parameter, an optional field or a new type; the four existing `showTransactionDetails` call sites and the one existing `TransactionRow` call site compile and behave unchanged, proven by `test/dashboard/` staying green without edits.
- `_OrderRailRow` is gone from the tree and no stale comment claims a bespoke row.
- The rail's tap target is `showTransactionDetails`; `/orderDetails` is still routed and still pushed by `checkout_qr.dart` and `banxa_orders_history.dart`.
- The drawer's footer is present exactly on `pendingpayment` and `declined`, absent otherwise.
- No em dash appears in any file this plan touches.
</verification>

<success_criteria>
- Buy GNUS "Your orders" rows are `TransactionRow`s, divider-separated, with the crypto amount in the right column and the real fiat paid as the value line beneath it (D-03).
- Tapping one opens `showTransactionDetails` carrying the payment method, the order amount, both fees separately, the order id and the destination address, with absent Banxa fields rendering as no row at all (D-01).
- `Complete Payment` and `Retry Order` live in that drawer, gated on the same raw status strings `/orderDetails` uses, and `/orderDetails` is otherwise untouched (D-02).
- `flutter analyze` clean, full `flutter test` green at baseline plus the new tests, `tool/check_brace_style.sh` and `tool/check_raw_colors.sh` both 0, all reported as real numbers.
- Nothing committed, nothing pushed.
</success_criteria>

<output>
Create `.planning/quick/260731-ope-buy-gnus-order-rows-and-details-drawer-r/260731-ope-SUMMARY.md` when done.
</output>
