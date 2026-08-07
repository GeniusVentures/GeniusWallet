---
phase: quick-260807-txh
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - lib/dashboard/home/widgets/transaction_utils.dart
  - lib/dashboard/home/widgets/transaction_displays.dart
  - test/dashboard/transaction_utils_test.dart
  - test/dashboard/transaction_row_subtitle_test.dart
  - test/dashboard/transaction_receipt_copy_test.dart
autonomous: false
requirements: [QUICK-260807-TXH]

must_haves:
  truths:
    - "No transaction row prints the transaction's OWN hash on its second line. Exactly one arm does today - `process`, whose `subtitleBase` is `_addressLine(tx.hash)` - and that is the `0x9f3a...4b21` Jakub pointed at."
    - "The hash a row stops printing is still reachable: the detail drawer prints it as a copyable row labelled `Job` for a process transaction and `Hash` for every other type. Proven by a test BEFORE the row loses it, because if the drawer did not carry it this would be data loss and not decluttering."
    - "The job row's lead is the full wording `Processing job` again, which is what the freed width buys: it measures about 102 to 104px at w600 against the 113.0px line a COMPLETED job row has, where today's `Job 0x...` composes to about 127px and clips."
    - "The counterparty on a send, a receive and a swap survives. `To 0x91b2...44de`, `From ...` and `1.50 ETH` answer WHO and HOW MUCH, which is a different question from WHICH TRANSACTION, and the row is the only place a person sees them."
    - "The three non-completed job rows are the price of the full wording, and the price is stated rather than discovered: `Processing job` needs about 114 to 116px including its ellipsis against 69.7px (failed), 53.1px (pending) and 43.0px (cancelled). A ledger test measures every type-by-status pair and fails on any lead-cut case that is not on its written allowlist."
    - "No row overflows at any width the suite pumps. The subtitle line still has exactly ONE non-flex child - the status tail - which is what keeps the 320px matrix in `transaction_row_test.dart` free of RenderFlex overflow."
    - "The pending-mint verb shortfall is unchanged, not fixed and not worsened, and is recorded as still open rather than allowed to look answered."
  artifacts:
    - test/dashboard/transaction_row_subtitle_test.dart
    - test/dashboard/transaction_receipt_copy_test.dart
  key_links:
    - "`TxRowContent.subtitleLead` stays a nullable constructor field defaulting to null and `statusTail` stays a COMPUTED GETTER over `status` + `statusLabel`. `lib/banxa/banxa_helpers/order_transaction_mapping.dart` builds its own record with `subtitleLead` unset and needs zero edits; it is OFF LIMITS."
    - "The `wide` boolean gates the STATUS TAIL and nothing else. The lead and the context render in both branches. Gate more and the wide page double-prints the status or the panel loses it."
    - "This is a DERIVATION change. `transaction_displays.dart` needs no structural edit at all: the row already omits the context span when `subtitleBase` is empty. Only its stale comments move."
    - "The amount column stays exactly as it is. `.planning/todos/pending/2026-08-07-transaction-amount-column-clips-common-amounts.md` records that it already clips ordinary amounts; taking width from it was measured as strictly worse."
---

<objective>
Two linked changes to the transaction row's second line, from Jakub on device,
2026-08-07:

> "Przy transakcji to 'jobs' i 'receiving' kategorie zostaw tak, jak byly
> wczesniej. Natomiast usun ten 'transaction ID' czy cokolwiek jest po prawej
> stronie, bo to nie ma nawet sensu."

Asked to point at the element, he confirmed the hash / ID in the row's second
line (`0x9f3a...4b21`), not the fiat value under the amount and not the status
word.

1. The transaction hash leaves the row. It is reachable in the detail drawer,
   which prints it as a copyable `Job` row.
2. The job category gets its full wording back. This morning's plan shortened it
   to `Job` (25.2px at w500) instead of `Processing job` (99.0px at w500) purely
   because 99px did not fit a 113px line that also had to carry the hash and the
   status.

They are ONE task because removing the hash is what buys the width back.

Purpose: a truncated `0x9f3a...4b21` on a resting row identifies a transaction
the user has already found. It answers a question nobody asked at the moment
they are scanning a list, and it costs about 97px of a 113px line.

Output: one derivation change, two comment corrections, one new ledger test that
measures every type-by-status pair, one new drawer-reachability assertion, four
moved unit assertions, and a blocking on-device checkpoint carrying THREE
rulings Jakub has not yet been shown.
</objective>

<execution_context>
@$HOME/.claude/gsd-core/workflows/execute-plan.md
@$HOME/.claude/gsd-core/templates/summary.md
</execution_context>

<context>
@AGENTS.md
@.planning/quick/20260807-tx-row-action-leads-subtitle/PLAN.md
@lib/dashboard/home/widgets/transaction_utils.dart
@lib/dashboard/home/widgets/transaction_displays.dart
@lib/theme/genius_wallet_typography.dart
@lib/utils/wallet_utils.dart
@test/dashboard/transaction_row_subtitle_test.dart
@test/dashboard/transaction_utils_test.dart
@test/dashboard/transaction_row_test.dart
@test/dashboard/transaction_receipt_copy_test.dart
</context>

<findings>

## Baseline, measured on this tree while planning

`flutter test` is **1142 passing, 0 failing**, exit 0. Re-measure anyway before
you start: it moved several times today.

`flutter analyze` is 0 issues repo-wide and must stay there.

## 1. The per-type question, answered rather than assumed

`subtitleBase` is not one thing. Every arm of `txRowContent`, classified:

| Type | direction | lead today | `subtitleBase` today | what it IS | ruling |
| --- | --- | --- | --- | --- | --- |
| `mint` | any | `Minted` | `to wallet` | a QUALIFIER - a place, not a value | KEEP |
| `escrow` | any | `Locked` | `in escrow` | a QUALIFIER | KEEP |
| `escrowRelease` | any | `Released` | `from escrow` | a QUALIFIER | KEEP |
| `process` | any | `Job` | `_addressLine(tx.hash)` -> `0xabcd...6789` | **THE TRANSACTION'S OWN HASH. An IDENTIFIER.** | **REMOVE** |
| `purchase` | any | `Card purchase` | `` (already empty) | nothing | n/a |
| `swap` | any | `Swapped` | `· 1.50 ETH` | a QUANTITY | KEEP |
| `transfer` | sent | `Sent` | `· _addressLine(recipients.first.toAddr)` | a COUNTERPARTY - who received it | KEEP, and PUT TO JAKUB |
| `transfer` | sent, no recipients | `Sent` | `· Unknown recipient` | a COUNTERPARTY placeholder | KEEP, and PUT TO JAKUB |
| `transfer` | received | `Received` | `· _addressLine(tx.fromAddress)` | a COUNTERPARTY - who sent it | KEEP, and PUT TO JAKUB |
| `null` | either | `Sent` / `Received` | as `transfer` | a COUNTERPARTY | KEEP, and PUT TO JAKUB |
| Banxa override | n/a | null | `Today · Card purchase` | a day plus a category | UNTOUCHED, and OFF LIMITS |

**Exactly one string on the row is a transaction identifier, and it is the
`process` arm's `_addressLine(tx.hash)`.** Named plainly: the string that
disappears from the row is the 13-character short form of `tx.hash`, e.g.
`0xabcd...6789`, and it disappears from job rows only.

**Why the counterparty is not the same thing, even though it looks identical.**
`WalletUtils.getAddressForDisplay` produces `0x` + 4 + `...` + 4 for BOTH, so a
job's hash and a send's recipient are visually indistinguishable on the row -
which is very likely why Jakub read one of them as senseless. But:

- The hash identifies the row you are already looking at. You tapped it; you
  know which transaction it is. It is pure redundancy on a resting row.
- The counterparty is the only WHO on the row. Delete it and a send to one
  person and a send to another are the same row: same token, same amount, same
  word `Sent`. That is not decluttering, it is removing the only distinguishing
  content the line carries.
- His own sentence puts "receiving" on the LEAVE-IT-ALONE side.

So: recommend keeping it, and put it to him at the checkpoint with a plain send
and a plain receive on screen, per the briefing. Do NOT decide it silently and
do NOT build a toggle for it - if he rules "remove", it is a two-line follow-up
in the `transfer` arm.

**One observation to hand him with it, not to act on.** `Received` (about 63.5
to 64.7 at w600) plus a space plus `· 0x1111...0000` (about 105.6) is roughly
173px on a 113px line, so that address ALREADY shows only about five of its
thirteen characters today. If he wants the counterparty to be useful rather than
gone, the remedy is a shorter address form on the row, which is a different task
with a different diff. Measure the real rendered prefix in Task 1 and quote it
to him rather than estimating.

## 2. The drawer carries the hash. Verify it before removing it.

`transaction_displays.dart` lines 843 to 847:

    addCopy(
      netRows,
      tx.type == TransactionType.process ? 'Job' : 'Hash',
      tx.hash,
    );

`addCopy` returns early on a blank value, and `_CopyRow` prints the chunked
short form while putting the FULL `tx.hash` on the clipboard. So the hash is
reachable and copyable in full.

**There is no test for the `Job` label case.** `transaction_receipt_copy_test.dart`
only exercises `Hash`. Task 1 adds the process case, and it is the go/no-go
gate: if the drawer does not carry it, STOP and report instead of removing
anything.

Edge case worth one sentence in the code: when `tx.hash` is blank, `addCopy`
emits no drawer row - but today's row prints `Unknown address` rather than a
hash in that case, so nothing is lost there either.

## 3. The arithmetic, and the part of Jakub's instruction that does not fit

Numbers already MEASURED in the shipped Inter on this tree (sources: this
morning's plan, and the comments in `transaction_row_subtitle_test.dart` lines
206 and 280 to 294):

| Piece | px | weight | source |
| --- | --- | --- | --- |
| the row's middle column at a 366px host | 113.0 | - | measured |
| the paragraph's box on a PENDING row | 53.1 | - | measured |
| `Minted` | 48.5 | w600 | measured |
| `Card purchase` | 101.4 | w600 | measured |
| `Pending` (the tail) | 55.9 | w400 | measured |
| `Failed` (the tail) | 39.3 | w400 | measured |
| `Cancelled` (the tail) | 66.0 | w400 | measured |
| the ellipsis glyph `…` | 12.3 | - | measured |
| `Processing job` | 99.0 | **w500** | measured before the lead went w600 |
| `Job` | 25.2 | **w500** | measured before the lead went w600 |

The lead renders at **w600** now. The two confirmed w500-to-w600 pairs give a
ratio between 1.033 (`Card purchase` 98.2 -> 101.4) and 1.050 (`Minted` 46.2 ->
48.5). So:

- `Processing job` at w600 is **about 102 to 104px**. DERIVED. Re-measure it in
  Task 1 and use the real number everywhere.
- `Job` at w600 is **about 26.0 to 26.5px**. DERIVED. Same.

The paragraph's box, per status, is `113.0 - space2(4) - tailWidth`:

| status | tail | paragraph box |
| --- | --- | --- |
| completed | none | **113.0** |
| failed | 39.3 | **69.7** |
| pending | 55.9 | **53.1** |
| cancelled | 66.0 | **43.0** |

**Removing the hash changes what is IN the paragraph. It does not change the
paragraph's BOX.** The box is set by the tail, and the tail is untouched. That
single sentence is what the rest of this section follows from.

### The job row, before and after

Today's composed content is `Job` + a space + the 13-character hash. The hash
form is about 97px (derived: `· 0x5555...4444` measured 105.6 less a `· `
prefix of about 8.4), so the line wants about **127px**.

| status | box | today wants | today draws | after wants | after draws |
| --- | --- | --- | --- | --- | --- |
| completed | 113.0 | ~127 | `Job 0xabcd...6...` - the HASH is cut | ~103 | **`Processing job` WHOLE** |
| failed | 69.7 | ~127 | `Job 0xa...` - `Job` survives | ~103 | `Processi...` - the WORD is cut |
| pending | 53.1 | ~127 | `Job 0...` - `Job` survives | ~103 | `Proces...` - the WORD is cut |
| cancelled | 43.0 | ~127 | `Job...` - `Job` survives | ~103 | `Proc...` - the WORD is cut |

`Job` plus its ellipsis is about 38.3 to 38.8px, which clears 43.0, 53.1 and
69.7. **That is why the word survives on all four statuses today.**
`Processing job` plus its ellipsis is about 114 to 116px, which clears none of
them.

So the honest statement, which Jakub has not been shown:

> The full wording fits the job row EXACTLY where the hash used to be - about
> 103px into a 113px line, roughly 10px of margin - and only on a COMPLETED job
> row. On a pending, failed or cancelled job row the status tail takes 44 to
> 70px of the line and nothing longer than about `Job` can survive there.

### Why there is no layout trick that rescues it

Four levers exist and all four are closed. Record this in the SUMMARY so nobody
re-derives it:

1. **Shorten the word.** `Processing` alone is about 75.5px at w600, which still
   misses 69.7, 53.1 and 43.0. There is no intermediate string.
2. **Move the status tail to the title line.** The title line is the token alone
   and looks empty, but it is not: at bodySm the pending tail would leave the
   title 53.1px, and `WSTETH` is about 60px while a swap's `ETH -> GNUS` is
   about 95px. That trades a cut verb for a cut TOKEN SYMBOL, and the token is
   the headline the whole row is organised around (010-A). REJECTED, with
   numbers.
3. **Wrap the second line.** Per-row height changes make a ragged list.
   REJECTED.
4. **Take width from the amount column.** FORBIDDEN by the briefing and already
   measured as strictly worse - see the todo at
   `.planning/todos/pending/2026-08-07-transaction-amount-column-clips-common-amounts.md`,
   where ordinary amounts need 86.5 to 136.0px against the 113 they get.

### What this plan does about it

Build what Jakub asked for. `Processing job` goes back, the completed job row
becomes correct for the first time, and the three non-completed job rows lose
their word. Then make that loss LOUD rather than silent, three ways:

- a ledger test that measures every type-by-status pair and fails on any
  lead-cut case not on a written allowlist, so the three job rows are named in
  the suite and a fourth can never appear unnoticed;
- the exact rendered strings recorded in the SUMMARY;
- a blocking checkpoint that puts the trade to him with a pending job row on
  screen, because he cannot rule on `Proces...` against `Job` without seeing it.

**This is a ruling for Jakub, not for the planner or the executor.** If he
picks `Job` back, the reversal is one line in the `process` arm plus the
allowlist entries.

## 4. The pending-mint shortfall: UNCHANGED

Recomputed as the briefing asked. The answer is not "fixed" and not "improved".

`mint`'s context is `to wallet`, a qualifier that stays. Its paragraph still
wants `Minted to wallet` (about 48.5 + 3.9 + 55.6 = 108) against a 53.1px box on
a pending row, so the ellipsis still reaches the verb: `Minted` (48.5) plus the
ellipsis (12.3) is 60.8 against 53.1, a **7.7px shortfall**, and the row still
renders `Minte...`.

Removing hashes does nothing for it, because mint never printed one. The
existing recorded-shortfall expectation in `transaction_row_subtitle_test.dart`
(lines 308 to 317, `lead + ellipsis > available`, with the instruction to invert
it if it ever starts passing) stays exactly as it is and stays green.

**Do not let this look answered.** It was the question Jakub was about to be
asked, it is still open, and it goes to the checkpoint as ruling item 3.

## 5. Nothing structural changes in the widget

`transaction_displays.dart` already emits the context span only when
`subtitleBase.isNotEmpty` (line 458). An empty base yields a lead-only
paragraph, which is exactly what `purchase` already does today. So the widget
needs NO structural edit - only its stale comment at lines 436 to 445, which
cites "`Job` alone is 25.2".

The subtitle line keeps exactly ONE non-flex child, the status tail. That is the
property `transaction_row_test.dart`'s 320px matrix depends on
(`takeException()` is null), and it is unchanged by this task.

## 6. What breaks in the existing suite, and what does not

Only four assertions, all in `transaction_utils_test.dart`, and each replacement
is at least as strict:

| line | today | after | strictness |
| --- | --- | --- | --- |
| 361 | `expect(content.subtitle, startsWith('Job '))` | `expect(content.subtitle, 'Processing job')` | STRICTER - exact equality replaces a prefix |
| 365 | `expect(content.subtitleLead, 'Job')` | `expect(content.subtitleLead, 'Processing job')` | equal |
| 366 | `expect(content.subtitleLead, isNot(content.action))` | `expect(content.subtitleLead, content.action)` | STRICTER - equality replaces an inequality. The lead and the drawer title are now the same string for this type, and that IS the restoration |
| 367 | `expect(content.subtitleBase, isNot(startsWith('Job')))` | `expect(content.subtitleBase, isEmpty)` plus a new hash-absence loop | STRICTER |

Everything else in that file passes unchanged, and each one is a proof:
the recompose invariant (line 563) still holds because `txRowContent` composes
`subtitle` FROM the pieces; the dedup loop (line 600) passes because
`''.startsWith(anything)` is false; the non-empty-lead loop (line 618) passes
because `Processing job` is non-empty; the "subtitle is never empty" loop (line
177) passes for the same reason; the "a completed subtitle carries no status
token" loop passes because `Processing job` contains no status word.

`transaction_row_test.dart` needs NO edit. Its 320px matrix runs under the
harness's one-em-per-character fallback font where `Processing job` measures 182
and `Job 0xabc` measures 126, but both live inside the `Expanded` paragraph and
ellipsize rather than overflow.

`transaction_filters_test.dart` and `transaction_filter_rail_test.dart` need NO
edit. Their width-sensitive fixtures use `escrow`, not `process`, and the rail's
`Jobs` label is scoped through `railText` so it cannot collide with a row's
`Processing job`. Run them anyway; report it if either reddens.

`lib/banxa/` needs NO edit: it sets `subtitleLead` to null and supplies its own
`subtitleBase`, and neither field's contract changes.

</findings>

<constraints>

- **Do NOT create any commit.** Not per task, not at the end. Leave the tree
  dirty for Jakub. This overrides the execute-plan workflow's commit steps.
- **FILE FENCE.** A parallel plan owns `lib/components/coins/view/coins_screen.dart`,
  `lib/components/cards/gw_section_title.dart`,
  `lib/components/overlay/mobile_header.dart` and
  `lib/components/overlay/responsive_overlay.dart`. Do not read from or write to
  any of them. If a task appears to need one, STOP and report the collision.
  `git status` is NOT a usable fence check - most of `lib/` is dirty today.
- Nothing under `/banxa` or `/squid_router`.
- Mobile only, iOS, dark mode first. The wide branch cannot be checked on the
  phone and is covered by widget tests instead.
- Existing `GW*` components extended additively. Nothing here hand-rolls a
  component; nothing here even changes the widget tree.
- 4-pt grid, existing tokens only. `space3` = 6 is the ONE documented exception.
  This task introduces no new dimension at all.
- No em dashes anywhere, in UI strings or code comments. Write "a - b" with a
  plain hyphen. The MIDDLE DOT (U+00B7) already on the line is fine and is not
  an em dash. `_minus` (U+2212) in `transaction_utils.dart` is a minus sign and
  is load bearing for the amount column: do not touch it.
- Only lines this task adds or rewrites must obey the hyphen rule. Do not sweep
  unrelated existing lines; that is a different task and it would bury this diff.
- **No assertion may be relaxed, deleted or skipped.** Where one moves, the
  replacement must be at least as strict and the task must say why.
- Do not touch the amount column and do not take width from it. Do not fix the
  todo at
  `.planning/todos/pending/2026-08-07-transaction-amount-column-clips-common-amounts.md`
  and do not make it worse.
- **Do not use "v1", "for now", "placeholder", "simplified" or "future
  enhancement" in any code comment or SUMMARY line.** Every deviation in this
  plan is a measured constraint with arithmetic attached, and it is written that
  way.

</constraints>

<tasks>

<task type="auto">
  <name>Task 1: measure what today draws, and prove the drawer carries the hash</name>
  <files>test/dashboard/transaction_row_subtitle_test.dart, test/dashboard/transaction_receipt_copy_test.dart</files>
  <action>
This task changes NO production code. It produces the evidence the rest of the
plan rests on, against the UNCHANGED tree.

Re-measure the baseline first and record it in the SUMMARY:
`flutter test 2>&1 | tail -3`. It was 1142 passing, 0 failing when this plan was
written.

**(a) The go/no-go gate, in `transaction_receipt_copy_test.dart`.**

That file exercises the drawer's `Hash` copy row. Add the `process` case, which
nothing covers today: open `showTransactionDetails` for a
`TransactionType.process` transaction and assert that a copy row labelled `Job`
exists, that tapping it puts the FULL untruncated `tx.hash` on the clipboard,
and that no row labelled `Hash` is emitted for that type. Follow the existing
test's `ensureVisible` and clipboard-channel plumbing exactly; do not invent a
second pattern.

State in the test's comment WHY it exists: the row is about to stop printing the
hash, and this is the assertion that makes that decluttering rather than data
loss. If this test cannot be made to pass, STOP the plan and report it - do not
proceed to Task 2.

**(b) The ledger, a new group in `transaction_row_subtitle_test.dart`.**

That file already loads the real bundled Inter and pumps the app's real
`ThemeData` - reuse its `_loadInter`, `_host`, `_tx`, `_paragraphWith`,
`_widthOf`, `_leadWidth`, `_ellipsisWidth`, `_styleOf` and `_needleFor` helpers
verbatim. Do not duplicate them and do not weaken any assertion already in the
file.

Add ONE group that walks the full matrix at `_kPhoneWidth`: every
`TransactionType` plus null, both `TransactionDirection` values, all four
`TransactionStatus` values. For each cell record:

  - the paragraph's box width (`rp.size.width`),
  - the whole paragraph's intrinsic width,
  - the lead's own intrinsic width via `_leadWidth`,
  - the ellipsis glyph's width,
  - and a verdict: WHOLE when the paragraph fits its box, LEAD-SAFE when
    lead + ellipsis fits, LEAD-CUT otherwise.

Assert that the set of LEAD-CUT cells equals a WRITTEN ALLOWLIST declared at the
top of the group as a `Set<String>` of `type/direction/status` keys, with a
comment beside each entry giving its arithmetic. Equality, not containment: a
NEW shortfall reddens, and a FIXED one also reddens and tells the reader to
delete its entry. Put the whole measured table into the failure `reason` so a
red run says what the numbers were.

Emit the table once from a `tearDownAll` using `debugPrint` from
`package:flutter/foundation.dart` - NOT `print`, which `flutter analyze` will
reject. The executor reads those numbers into the SUMMARY, and they are the
before-and-after evidence this plan exists to produce.

Populate the allowlist from the run against TODAY's tree, not from this plan's
estimates. Run it, read the verdicts, write them down. The pending mint is
expected to be on it (the 7.7px shortfall the file already documents at lines
280 to 294). Record in the SUMMARY, per cell, exactly what today's job rows draw
and how much of the counterparty address a plain send and a plain receive
actually show - that last number goes to Jakub at the checkpoint.

Also record, for the SUMMARY and for Task 2's comments, the real w600 widths of
`Job`, `Processing job` and `Received`, measured through `_widthOf` against the
paragraph's own resolved style. This plan's 102 to 104px for `Processing job` is
DERIVED from a weight ratio and must be replaced by the measured value
everywhere it appears.
  </action>
  <verify>
    <automated>flutter test test/dashboard/transaction_row_subtitle_test.dart test/dashboard/transaction_receipt_copy_test.dart 2>&1 | tail -20</automated>
  </verify>
  <done>
Both files pass against the unchanged production tree. The drawer's `Job` copy
row is asserted to carry the full `tx.hash`. The ledger prints a table covering
every type, direction and status, its allowlist matches today's actual LEAD-CUT
set exactly, and the measured w600 widths of `Job`, `Processing job` and
`Received` plus the rendered counterparty prefix are recorded in the SUMMARY.
No production file was touched.
  </done>
</task>

<task type="auto">
  <name>Task 2: the job row drops the hash and takes its full wording back</name>
  <files>lib/dashboard/home/widgets/transaction_utils.dart, lib/dashboard/home/widgets/transaction_displays.dart, test/dashboard/transaction_utils_test.dart, test/dashboard/transaction_row_subtitle_test.dart</files>
  <action>
**`transaction_utils.dart`, the `process` arm of `txRowContent`.**

Set `subtitleLead` to `'Processing job'` and `subtitleBase` to the empty string.
That is the whole production change.

Rewrite the comment block above the subtitle switch (currently lines 431 to 444)
to state what is now true and why, using the numbers Task 1 measured rather than
this plan's derived ones:

  - The row prints no transaction hash. `process` was the only arm that did, its
    base was `_addressLine(tx.hash)`, and Jakub named it senseless on the row on
    2026-08-07. It stays reachable in the drawer as a copyable `Job` row, which
    `transaction_receipt_copy_test.dart` now asserts.
  - The lead is the full `Processing job` again and is now identical to
    `action`. Removing the hash is what made room: the composed line went from
    about 127px to the measured width of the word alone, against a 113.0px line.
  - The three non-completed job rows cannot hold it. Give the measured
    arithmetic per status - the paragraph's box is 113.0 less `space2` less the
    tail, which is 69.7 on failed, 53.1 on pending and 43.0 on cancelled - and
    say plainly that the word ellipsizes there and that `Job` did not. Name the
    four rejected alternatives in one line each (a shorter word, moving the tail
    to the title line, wrapping, taking width from the amount column) so nobody
    re-derives them.
  - `purchase` is no longer the only arm with an empty base. Update that arm's
    comment, which currently claims it is.

Do NOT touch any other arm. `mint`, `escrow`, `escrowRelease`, `swap` and both
`transfer` directions keep their strings byte-identical: those carry qualifiers,
quantities and counterparties, not identifiers. Write the classification down in
one short comment so the next reader does not "finish the job" by deleting the
recipient address.

Do NOT change `action`, `subtitle`'s composition, `subtitleLead`'s nullability,
`statusTail`'s getter shape, or `TxRowContent`'s constructor. `lib/banxa/`
depends on every one of those and is off limits.

**`transaction_displays.dart`, comments only.**

The `TextSpan` comment at lines 436 to 445 argues the colour-over-dot decision
using "`Job` alone is 25.2". That number is now doubly stale: the lead is w600,
and the word is `Processing job`. Correct it to the measured w600 width of
`Processing job` and note that the argument is STRONGER now, not weaker - the
line is tighter, so a separator that costs about 10px is even less affordable.
Change no widget code in this file. If you find yourself editing anything but a
comment here, stop and re-read this plan.

**`transaction_utils_test.dart`, four moved assertions plus two new invariants.**

Move exactly the four listed in finding 6, each replacement at least as strict,
and say in a comment beside line 366's replacement why an equality now stands
where an inequality did: the lead and the drawer title are the same string for
this type again, and that identity IS the restoration Jakub asked for.

ADD the invariant that makes the removal permanent: for every
`TransactionType` including null, both directions and all four statuses, assert
that neither `subtitleBase` nor `subtitle` contains
`WalletUtils.getAddressForDisplay(tx.hash)`. Before writing it, check the
fixture's `hash` is at least 6 characters and is DISTINCT from `fromAddress` and
from `recipients.first.toAddr` - otherwise the assertion either passes vacuously
or reddens on a counterparty that is legitimately there. Adjust the fixture's
hash if needed and say why in a comment.

ADD an assertion that `subtitleBase` is empty for `process`, paired with one
that it is still non-empty for `mint`, `escrow`, `escrowRelease`, `swap` and
both `transfer` directions. That pair is what stops a future edit from
"simplifying" the counterparty away along with the hash.

Keep every other assertion in the file. If one reddens, the derivation is wrong,
not the test.

**`transaction_row_subtitle_test.dart`, the ledger's allowlist.**

Re-run the ledger. Update the allowlist to the new LEAD-CUT set and give each
new entry its measured arithmetic in a comment. The expected delta is exactly
three new entries - `process` at pending, failed and cancelled - and zero
removals, because nothing this task touches changes any other row's box or
content. If the delta is anything else, STOP and report it before adjusting the
allowlist: an unexpected change means a row moved that this plan did not intend
to move.

Leave the pending-mint shortfall expectation at lines 308 to 317 exactly as it
is. It is still red-in-spirit, still green as an assertion, and still the
correct record of an open defect.
  </action>
  <verify>
    <automated>flutter test test/dashboard/ test/banxa/ test/components/ 2>&1 | tail -20</automated>
  </verify>
  <done>
`test/dashboard/`, `test/banxa/` and `test/components/` are green. No row's
`subtitle` or `subtitleBase` contains the transaction hash, proven by a loop
over every type, direction and status. The job row's lead is `Processing job`
and equals `action`. Every other arm's strings are byte-identical to what
shipped before this task. `transaction_displays.dart`'s diff is comments only.
No file under `lib/banxa/`, `lib/squid_router/` or the four fenced component
files was modified.
  </done>
</task>

<task type="auto">
  <name>Task 3: the gates, and the three things Jakub has to be told</name>
  <files>.planning/quick/20260807-tx-row-drop-hash-restore-wording/SUMMARY.md</files>
  <action>
Run all three gates and record every result verbatim in the SUMMARY.

`flutter analyze` must end at **0 issues**. Not "0 errors with warnings", zero.

`flutter test` must end green at or above the baseline you measured in Task 1
plus the tests you added. Report both counts. If ANY test that passed at
baseline now fails, stop and report it. Do not weaken it, do not delete it, do
not add a skip.

Sweep the diff for em dashes on ADDED lines only, writing the character as a
byte escape so it never appears literally:

    git diff -U0 -- lib test | grep '^+' | grep -c $'\xe2\x80\x94'

The count must be 0. Middle dots and the U+2212 minus are expected and are not
em dashes.

Confirm the fence held:

    git status --short | grep -E 'coins_screen|gw_section_title|mobile_header|responsive_overlay|banxa|squid_router'

Any hit that this task authored is a violation. Report it rather than reverting
silently - a parallel plan may legitimately own the dirty state.

Then write the SUMMARY. It must carry, in this order:

1. The before and after `flutter test` counts and the `flutter analyze` result.
2. **The per-type ruling table** from finding 1, with the actual string named for
   each type, and which single string was removed.
3. **The job row's before-and-after table**, all four statuses, with the MEASURED
   numbers from the ledger, not this plan's derived ones. State in one sentence
   that the full wording fits only the completed job row and that `Job` fitted
   all four.
4. **The pending mint, stated plainly: UNCHANGED.** Not fixed, not improved, not
   worsened. Give the 7.7px shortfall and say the question Jakub was going to be
   asked is still open and is going to him at the checkpoint.
5. The four rejected layout alternatives with one line of arithmetic each, so
   nobody re-derives them.
6. How much of the counterparty address a plain send and a plain receive actually
   render today, measured.
7. The four moved assertions and why each replacement is at least as strict.
8. That no commit was created.

Create no commit. Leave the tree dirty.
  </action>
  <verify>
    <automated>flutter analyze 2>&1 | tail -3 && flutter test 2>&1 | tail -3 && git diff -U0 -- lib test | grep '^+' | grep -c $'\xe2\x80\x94'</automated>
  </verify>
  <done>
`flutter analyze` reports 0 issues. `flutter test` is green at or above the
baseline plus the added tests, with both counts recorded. Zero em dashes on
added lines. The fence held. The SUMMARY carries all eight items, with measured
numbers throughout. No commit was created.
  </done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>
The transaction hash is off the row. Exactly one row printed it - the job row,
whose second line was `Job 0xabcd...6789` - and that 13-character string is the
`0x9f3a...4b21` you pointed at. It is still in the detail drawer as a copyable
`Job` row carrying the full hash, and there is now a test that proves it, added
BEFORE the row lost it.

The job category has its full wording back: `Processing job`, not `Job`.

**Three rulings for you. All three are things you have not been shown.**

**1. The full wording only fits a COMPLETED job row.**

Removing the hash bought the line back exactly - `Processing job` measures about
103px into the 113px the row has, where `Job 0xabcd...6789` wanted about 127 and
was clipping the hash on every job row.

But a pending, failed or cancelled job row also carries the status word pinned
at the right, and that takes 44 to 70px of the same 113. The paragraph is left
with 69.7px (failed), 53.1px (pending) or 43.0px (cancelled), and `Processing
job` needs about 115px including its ellipsis. So on those three rows it now
draws `Processi...`, `Proces...` and `Proc...`.

The word `Job` fitted all four, which is why this morning chose it. So the trade
is: the full wording on completed job rows, or an unbroken word on all of them.

There is no third option. I checked four: a shorter word (`Processing` alone is
still about 75px and misses all three), moving the status up to the token line
(it would then cut `WSTETH` and badly cut a swap's `ETH -> GNUS`), wrapping to
two lines (ragged row heights), and taking width from the amount column (already
measured as strictly worse - that column clips ordinary amounts today).

Reverting to `Job` is a one-line change if you want it.

**2. I kept the address on send and receive rows. Confirm that is what you
meant.**

`To 0x91b2...44de` and `From 0x...` look exactly like the hash - same
`0x` + 4 + `...` + 4 shape - so this is very likely the same thing you were
looking at. I kept them because they answer WHO, and the hash answered WHICH
TRANSACTION, which the row you already tapped does not need to tell you. Delete
the address and a send to one person and a send to another become the same row.

Separate observation, not something I changed: that address already shows only
about five of its thirteen characters at your phone's width. If you want it
useful rather than gone, the fix is a shorter address form on the row, which is
its own task.

**3. The pending mint is UNCHANGED by this, and the question you were going to
be asked is still open.**

A pending mint still draws `Minte...` instead of `Minted`. Removing hashes did
nothing for it, because the mint row never printed one - its second line is
`Minted to wallet`, and `to wallet` is a qualifier, not an ID. The verb plus its
ellipsis needs 60.8px against the 53.1px the line keeps once `Pending` takes its
share: a 7.7px shortfall, and 113px cannot hold 48.5 + 12.3 + 4 + 55.9 = 120.7.
  </what-built>
  <how-to-verify>
Run the app on your iPhone in DARK mode. Open the Transactions page, then the
dashboard Transactions panel. Use the dev tools bubble's mock transactions if
your wallet has no pending or failed rows - the app must be launched with
`--dart-define=GW_DEV_TOOLS=true`.

Look at these rows specifically. They are the ones this change touches or gets
wrong, and a happy-path walk would miss every one of them.

  1. **A COMPLETED JOB ROW.** It should read `Processing job` with nothing after
     it, and the word should be whole. This is the row the change was for.
  2. **A PENDING JOB ROW.** This is ruling 1. It will read something like
     `Proces...` with `Pending` complete at the right. Tell me whether you want
     the full word on completed job rows at this price, or `Job` back on all
     four.
  3. **A PLAIN SEND and A PLAIN RECEIVE.** This is ruling 2. Both still show the
     counterparty - `Sent · 0x...` and `Received · 0x...`. Say whether that
     `0x...` was also what you wanted gone, or whether it stays.
  4. **A PENDING MINT.** This is ruling 3. `Minted` is still cut to `Minte...`.
     `Pending` at the right should be complete. Nothing about this row changed
     today - confirm you have seen it and say whether it is worth its own task.
  5. **A FAILED SWAP.** `Swapped` complete on the left, `Failed` complete on the
     right, `1.50 ETH` in between giving way. Unchanged by this task, but the
     badge on this row is a red cross, so the word is the only thing saying what
     was attempted.
  6. **AN ESCROW RELEASE.** `Released from escrow`, with `Released` never
     truncating. This type has no badge of its own, so the word is the only
     signal. Unchanged by this task.
  7. **A LONG TOKEN NAME.** WSTETH, or a swap with two long symbols. The token
     line is unchanged, but confirm nothing below it moved.

Then check the whole list at a glance: no `0x` string anywhere on a job row, the
status words on any pending or failed rows all landing on one vertical line at
the right of the middle column, and no text touching the amount column.

Open any job row's detail drawer and confirm the `Job` row is there under
Network with the hash, and that tapping it copies.

The wide `/transactions` page cannot be checked on the phone. It is covered by
the widget tests at 900px, which assert the pill is present, the tail is absent,
and the subtitle still carries both its pieces.
  </how-to-verify>
  <resume-signal>Type "approved", or answer the three rulings: job wording (full on completed / `Job` on all), the send and receive address (keep / remove), and the pending mint verb (leave / own task).</resume-signal>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
| --- | --- |
| transaction model to row text | `tx.hash`, addresses and `coinSymbol` are RPC or API supplied and reach text layout |
| caller-built record to row layout | `TxRowContent.statusLabel` is supplied by a caller (the Buy GNUS orders rail) and reaches the row's only non-flex child |
| model to clipboard | the drawer's `Job` copy row now carries the full untrusted `tx.hash` into the clipboard, and this task adds the test that pins it |

## STRIDE Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation Plan |
| --- | --- | --- | --- | --- | --- |
| T-txh-01 | Denial of Service | the job row's subtitle paragraph | low | mitigate | This task REMOVES an untrusted, unbounded-in-principle `tx.hash` from the row's text-layout path entirely. `_addressLine` bounded it to 13 characters and the `Expanded` paragraph bounded it again; the arm now carries a compile-time constant. Strictly fewer untrusted values reach layout than before (the 37639d5 freeze rule). |
| T-txh-02 | Denial of Service | the status tail, still the row's only non-flex child | medium | mitigate | Unchanged and deliberately so: `ConstrainedBox(maxWidth: _narrowStatusMaxWidth)` still bounds the caller-supplied `statusLabel`, and `transaction_row_subtitle_test.dart` still asserts every status word fits under the cap. This task adds no second non-flex child, which is what keeps the 320px matrix free of RenderFlex overflow. |
| T-txh-03 | Information disclosure | the hash leaving the resting row | low | accept | A transaction hash is a public chain identifier and its short form was already on screen; moving it behind a tap reduces incidental shoulder-surfing exposure rather than increasing it. Nothing is newly revealed. |
| T-txh-04 | Repudiation | the hash's reachability after removal | medium | mitigate | Removing an identifier from the row without proving the drawer carries it would make a transaction unverifiable against a block explorer. Task 1 adds the assertion that the drawer emits a copyable `Job` row carrying the FULL `tx.hash`, and it runs BEFORE the row loses it - it is an explicit go/no-go gate on the rest of the plan. |
| T-txh-SC | Tampering | package installs | low | accept | This task installs nothing. No `pubspec.yaml` change, no new dependency, no package manager runs. |
</threat_model>

<verification>
- `flutter analyze` reports 0 issues.
- `flutter test` is green at or above the 1142-passing baseline plus the added
  tests, with both counts recorded in the SUMMARY.
- No row's `subtitle` or `subtitleBase` contains
  `WalletUtils.getAddressForDisplay(tx.hash)`, for every type, both directions
  and all four statuses.
- The drawer emits a copyable `Job` row carrying the full `tx.hash` for a
  `process` transaction, asserted before the row stops printing it.
- The ledger's LEAD-CUT allowlist changed by exactly three entries - `process`
  at pending, failed and cancelled - and nothing else moved.
- The 320px and 900px matrix in `transaction_row_test.dart` still runs under the
  fallback font and still passes with no RenderFlex overflow and no edit.
- `transaction_displays.dart`'s diff contains no widget code, only comments.
- No assertion anywhere was deleted, skipped or weakened. The four that moved are
  recorded in the SUMMARY with the reason each replacement is at least as strict.
- No file under `lib/banxa/`, `lib/squid_router/`,
  `lib/components/coins/view/coins_screen.dart`,
  `lib/components/cards/gw_section_title.dart`,
  `lib/components/overlay/mobile_header.dart` or
  `lib/components/overlay/responsive_overlay.dart` was modified by this task.
- The amount column is untouched and the todo at
  `.planning/todos/pending/2026-08-07-transaction-amount-column-clips-common-amounts.md`
  is neither fixed nor made worse.
- Zero em dashes on added lines.
- No commit was created.
</verification>

<success_criteria>
1. The job row prints no transaction hash. It was the only arm that did, and the
   string removed is the 13-character short form of `tx.hash`.
2. That hash is still reachable and copyable in full from the detail drawer's
   `Job` row, proven by a test written before the removal.
3. The job row's lead is `Processing job` and is identical to `action` again.
   On a completed job row it renders whole in about 103px of the 113px line -
   the width the hash vacated.
4. Every other type's second line is byte-identical to what shipped before this
   task. Qualifiers (`to wallet`, `in escrow`, `from escrow`), the swap's
   quantity and both transfer directions' counterparties all survive, because
   none of them is a transaction identifier.
5. The three non-completed job rows cannot hold the full wording, and that is
   recorded three ways rather than discovered later: a ledger test whose
   allowlist names each one with its arithmetic, the SUMMARY's before-and-after
   table, and ruling 1 at the checkpoint.
6. The pending-mint verb shortfall is stated as UNCHANGED, with its 7.7px
   arithmetic, and goes to Jakub as an open question rather than looking
   answered.
7. Nothing overflows at any width the suite pumps; the subtitle line still has
   exactly one non-flex child.
8. Jakub has looked at all seven named rows on his iPhone in dark mode and has
   ruled on the job wording, the send and receive counterparty, and the pending
   mint verb.
</success_criteria>

<output>
Create `.planning/quick/20260807-tx-row-drop-hash-restore-wording/SUMMARY.md`
when done, carrying the eight items Task 3 lists, with MEASURED numbers
throughout rather than this plan's derived estimates, and Jakub's three rulings
recorded verbatim once the checkpoint resolves.
</output>
