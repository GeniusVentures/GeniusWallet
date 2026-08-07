---
phase: quick-260807-txr
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - lib/dashboard/home/widgets/transaction_utils.dart
  - lib/dashboard/home/widgets/transaction_displays.dart
  - test/dashboard/transaction_utils_test.dart
  - test/dashboard/transaction_row_test.dart
  - test/dashboard/transaction_row_subtitle_test.dart
  - test/dashboard/transaction_filters_test.dart
  - test/dashboard/transaction_filter_rail_test.dart
  - .planning/todos/pending/2026-08-07-transaction-amount-column-clips-common-amounts.md
autonomous: false
requirements: [QUICK-260807-TXR]

must_haves:
  truths:
    - "The action word is never clipped on a completed row at any width the app reaches. Today 6 of the 8 strings _actionFor can return are clipped on every row that prints them."
    - "The status token is never clipped on the narrow presentation. Today `Minted to wallet · Pending` needs 177.6px on a 113px line, so the app clips the word `Pending` off the one row where it matters most."
    - "The `surfaceMenu` chip container is gone from the title line, which measured 1.13:1 against the row canvas and made its own label read worse (5.30 vs 6.01)."
    - "The status is stated exactly once in each presentation: a pill on the wide page, a pinned tail on the narrow panel and phone page. Never twice, never zero times."
    - "The subtitle's fixed/flexible boundary falls inside the phrase: the verb survives, the qualifier gives way."
    - "No row overflows at any width the suite pumps, including the 320px stress case under the harness's one-em-per-character fallback font."
    - "The five subtitle strings that already carried their verb (mint, escrow, escrowRelease, purchase, process) compose to byte-identical text after the change. Only transfer and swap gain their action word, because those two never stated it in the subtitle."
  artifacts:
    - test/dashboard/transaction_row_subtitle_test.dart
    - .planning/todos/pending/2026-08-07-transaction-amount-column-clips-common-amounts.md
  key_links:
    - "TxRowContent.subtitleLead defaults to null so the Buy GNUS orders rail (lib/banxa/, OFF LIMITS this task) keeps its single-piece line with no edit at all."
    - "TxRowContent.statusTail is a COMPUTED GETTER over status + statusLabel, not a constructor field, for the same reason: the Banxa record keeps its narrow status without being touched, and the tail can never drift from the pill because both read the same two fields."
    - "The `wide` boolean gates the STATUS TAIL ONLY. The lead and the context render in both branches. Gate the whole subtitle on it and the wide page double-prints the status or the panel loses it."
    - "The status tail is the row's only non-flex subtitle child, so its ConstrainedBox maxWidth is what keeps the 320px matrix in transaction_row_test.dart free of RenderFlex overflow."
---

<objective>
Sketch 179, scheme C. The transaction row's title line becomes the token alone; the
action word moves down and leads the subtitle, where it can never be capped at half a
line. The chip container is deleted.

Jakub, 2026-08-07, on his iPhone, asked two questions at once: fix the truncated tags,
and are the tags needed at all now that the badge sits on the coin logo. The sketch
answered both and he picked C: on 179, go with C.

Purpose: the action word is not surplus, its POSITION is. The badge is chosen status
first in `txRowContent`, so on any pending or failed row the badge has spent itself on
the status and the type is drawn nowhere. Deleting the word would blank exactly the rows
a user opens the page to investigate.

Output: one derivation change, one widget change, one new real-font layout test, three
moved assertions, two stale comments corrected, one follow-up todo for a defect found
while measuring, and a blocking on-device check on the five rows the current layout gets
wrong.
</objective>

<execution_context>
@$HOME/.claude/gsd-core/workflows/execute-plan.md
@$HOME/.claude/gsd-core/templates/summary.md
</execution_context>

<context>
@AGENTS.md
@.planning/sketches/179-transaction-row-action-tag/README.md
@lib/dashboard/home/widgets/transaction_utils.dart
@lib/dashboard/home/widgets/transaction_displays.dart
@lib/dashboard/home/widgets/transaction_badge.dart
@lib/theme/genius_wallet_consts.dart
@lib/theme/genius_wallet_typography.dart
@test/dashboard/transaction_row_test.dart
@test/dashboard/transaction_utils_test.dart
@test/dashboard/compute_balance_unit_track_test.dart
</context>

<findings>

## Everything below was measured on this tree, not taken from the sketch

Baseline, measured before planning: `flutter test` is **1081 tests, all passing**, exit 0.
The briefing's guess of 1081 happens to be right today. Re-measure anyway before you
start, because it moved several times yesterday.

There are **no golden `.png` files anywhere under `test/`** (`find test -name '*.png'`
returns nothing). The sketch's audit line about "the row's golden" describes a golden
this repo does not have. No golden regeneration is required or permitted by this task.

### 1. The reported defect, confirmed by rendering the real widget

`TransactionRow` pumped at four host widths with the real bundled Inter loaded. The
middle column is the first `Expanded`; the chip is the `Text` inside the `surfaceMenu`
container.

| Host width | Middle column | Chip `Minted` rendered / intrinsic | Clipped |
| --- | --- | --- | --- |
| 320 | 90.0 | 33.0 / 44.4 | yes |
| 366 (a 390pt phone's `/transactions` content box) | 113.0 | 44.4 / 44.4 | no |
| 390 | 125.0 | 44.4 / 44.4 | no |
| 430 | 145.0 | 44.4 / 44.4 | no |

The 113.0 confirms the sketch's arithmetic exactly. The chip's own box is
`(113 - space4) / 2 - 2 * space2` = **44.5px**, which is why only `Sent` (30.5) and
`Minted` (46.2, and it only just misses) are close to fitting and the other six are cut.

### 2. The unreported defect, confirmed and now measured

Today the narrow subtitle is ONE `Text(content.subtitle)` with `maxLines: 1` and an
ellipsis. For a pending mint that string is `Minted to wallet · Pending`, whose intrinsic
width measured **177.6px in the widget against a 113.0px line**. The row clips the word
`Pending` off the row where the status is the whole point. It belongs in this plan as its
own success criterion: nobody reported it, and 1081 green tests permit it.

### 3. The amount column CANNOT be reclaimed, and the sketch's estimate for it is wrong

The sketch offers a toggle that reserves the amount column at 96px on the grounds that it
"claims 113px for content that needs about 90". Measured with real Inter at
`numericBody` 16 / w600:

| Amount string | px |
| --- | --- |
| `+ 0.42 ETH` | 86.5 |
| `+ 100 USDC` | 95.5 |
| `− 250 GNUS` / `+ 500 GNUS` | 96.3 |
| `− 12.5 GNUS` | 100.6 |
| `− 0.0021 ETH` | 107.2 |
| `+ 476.18 USDC` | 120.5 |
| `− 1.25 WSTETH` | 123.6 |
| `+ 2,400.75 GNUS` | 136.0 |

There is no slack. The column is already 7 to 23px SHORT for ordinary amounts, so it is
ellipsising real amounts today at 390pt. Reserving it at 96 would clip most rows, and
narrowing it at all buys the subtitle a few pixels by damaging the one string on the row
that must never be wrong. **Decision: the amount column stays `Expanded`, untouched.** The
sketch's 23px of waste does not exist. Task 3 files this as a separate todo rather than
fixing it here, because it is a different defect with a different remedy.

### 4. Two places where a literal scheme C does not survive Flutter, with the numbers

Real Inter, `bodySm` 14/20, no letter spacing (the app's own `textTheme` supplies
`bodySm` as the ambient body style, so nothing adds tracking on device).

| Piece | px |
| --- | --- |
| leads: `Sent` 30.5, `Job` 25.2, `Minted` 46.2, `Locked` 48.8, `Released` 61.4, `Received` 61.6, `Swapped` 62.8, `Card purchase` 98.2, `Processing job` 99.0 |
| tails with the dot: `· Failed` 47.3, `· Pending` 62.1, `· Cancelled` 74.0 |
| tails without the dot: `Failed` 39.3, `Pending` 54.1, `Cancelled` 66.0 |
| contexts: `to wallet` 55.6, `in escrow` 63.8, `from escrow` 83.0, `· 1.50 ETH` 66.4, `· 0x5555…4444` 105.6 |
| the ellipsis glyph at this size | about 4.4 |

**(a) The status tail cannot carry the sketch's leading middle dot.** On the flagship row,
a pending mint at 113px: lead 46.2 plus a 4px gutter plus `· Pending` 62.1 leaves 46.9px
for the paragraph, and `Minted` plus its ellipsis needs 50.6. The verb would render
`Minte…`, which is the exact defect this task exists to remove. Dropping the dot leaves
54.9px against 50.6 needed, a **4.3px margin**, and the verb survives whole. The dot's job
is separating two runs inside one flow; under C the tail is no longer in that flow. It is
a separate element, right pinned, with its own gutter, and unreachable by the ellipsis.
The middle dot stays where it still does work, inside the context: `Sent · 0x7a3f…9c21`.
Use `space2` (4) for that gutter, not `space4` (8): at `space4` the margin collapses to
0.3px.

**(b) Two fixed children can overflow, and the suite proves it.** Under the test harness's
fallback font every glyph is exactly one em wide (verified: 14.0px at fontSize 14), so at
the 320px case `transaction_row_test.dart` already pumps, the middle column is 90px while
`· Cancelled` alone measures 154 and `Processing job` measures 196. A `Row` throws a
`RenderFlex` overflow when its NON-FLEX children exceed the line, and that test asserts
`tester.takeException()` is null. So the literal CSS translation, two `flex: 0 0 auto`
children around an `Expanded`, fails the existing suite - and it fails on a real 320pt
iPhone SE too, where a pending mint's two fixed pieces need 105 of a 90px line.

The resolution keeps every one of C's guarantees and adds a defined degradation order:

- **The lead and the context are ONE paragraph** (`Text.rich`, two spans, the lead at
  w500). An end ellipsis eats the qualifier first and only reaches the verb when the
  qualifier is gone. That IS "the boundary falls inside the phrase", expressed in the
  mechanism Flutter actually has, and it can never overflow because the paragraph is the
  `Expanded`.
- **The status tail is the only non-flex child**, capped by a constant `ConstrainedBox`.
  It is never clipped in practice (widest real value `Cancelled` at 66.0 against a 76 cap)
  and it cannot overflow (76 + 4 = 80 against the 90px worst case the suite pumps).

Verified against every row this produces at 113px: on all eight completed types the verb
survives whole and the qualifier gives way, which reproduces the sketch's "0 red" readout.
On non-happy-path rows the verb also survives except for two long-lead pairs, a cancelled
`Card purchase` and a cancelled `Locked`, where the paragraph runs out. That is
arithmetic, not a design failure: no layout shows a 98px word and a 66px status inside
113px. Today, by comparison, 6 of 8 action words are clipped on EVERY row.

### 5. The process row's lead is `Job`, not `Processing job`, and this is a deviation

The sketch's fixture says `cLead: 'Processing job'`. Measured, that is 99.0px of a 113px
line, so every pending or failed job row would clip its verb - the rows the word exists
for. `Job` is 25.2px, it is the app's OWN existing word for that row
(`subtitle = 'Job ${hash}'` today), and it makes the composed string byte-identical to
what ships. Take `Job`. `content.action` stays `Processing job` for the drawer title, so
nothing is lost. Flag it at the checkpoint.

### 6. What the five "deduplicated" strings actually are

The dedup is achieved by DELETING THE CHIP, not by rewriting those five strings. Split at
the space they already contain and every one of them composes back to today's text:

| Type | lead (fixed) | context (flexible) | composed `subtitle` | vs today |
| --- | --- | --- | --- | --- |
| mint | `Minted` | `to wallet` | `Minted to wallet` | identical |
| escrow | `Locked` | `in escrow` | `Locked in escrow` | identical |
| escrowRelease | `Released` | `from escrow` | `Released from escrow` | identical |
| purchase | `Card purchase` | (empty) | `Card purchase` | identical |
| process | `Job` | `0x44ab…10ff` | `Job 0x44ab…10ff` | identical |
| transfer sent | `Sent` | `· <addr>` | `Sent · <addr>` | GAINS the verb |
| transfer received | `Received` | `· <addr>` | `Received · <addr>` | GAINS the verb |
| swap | `Swapped` | `· <from> <sym>` | `Swapped · 1.50 ETH` | GAINS the verb |

Only transfer and swap change, because those two never carried their verb in the
subtitle. This is why only three unit assertions move rather than a dozen.

### 7. The wide and narrow split, stated for both branches

`transaction_displays.dart` renders the dashboard panel AND the wide `/transactions` page
from one widget, split by `constraints.maxWidth >= 720`. Phase 25-01 moved the filter bar
off the panel onto the page and capped the panel at 5 rows; neither touches this row.

| | NARROW (panel, and the phone `/transactions` route) | WIDE (>= 720) |
| --- | --- | --- |
| title line | token alone | token alone |
| subtitle piece 1, the lead | rendered | rendered |
| subtitle piece 2, the context | rendered, `Expanded`, ellipsises | rendered, `Expanded`, ellipsises |
| subtitle piece 3, the status tail | rendered, pinned right, capped | **absent** |
| status pill | absent | rendered, unchanged |
| amount column | `Expanded`, unchanged | fixed 184, unchanged |

The `wide` boolean gates piece 3 and nothing else. The wide page keeps `subtitleBase` as
the field it reads for the context, exactly as the sketch says. What the wide page LOSES
is the duplicate chip, which is the intended dedup and is worth saying out loud: wide is
structurally unchanged, not byte-identical.

### 8. Nothing here touches the parallel plan's files

This task does not read from or write to `lib/components/coins/view/coins_screen.dart`,
`lib/components/cards/gw_section_title.dart` or `lib/components/cards/gw_view_all_link.dart`.
If a task appears to need one of them, STOP and report the collision instead of editing.

`lib/banxa/` and `lib/squid_router/` are off limits by constraint, and the field design
below is shaped so that neither needs an edit.

</findings>

<constraints>

- **Do NOT create any commit.** Not per task, not at the end. Leave the tree dirty for
  Jakub. This overrides the execute-plan workflow's commit steps.
- Mobile only, iOS, dark mode first. The wide branch cannot be checked on the phone, so it
  is covered by widget tests instead.
- Existing `GW*` components extended additively. Nothing here hand-rolls a component; the
  row is assembled from `Text`, `Text.rich`, `Row` and `ConstrainedBox`.
- 4-pt grid, existing tokens only. `space3` = 6 is the ONE documented exception. The single
  new literal in this task is the status tail's max width, and it carries a written
  derivation.
- No em dashes anywhere, including UI strings and code comments. Write "a - b" with a plain
  hyphen. The subtitle separator is a MIDDLE DOT (U+00B7) and is fine; it is not an em
  dash. `_minus` (U+2212) in `transaction_utils.dart` is a minus sign and is load bearing
  for the amount column: do not touch it.
- Only lines this task adds or rewrites must obey the hyphen rule. Do not sweep unrelated
  existing lines; that is a different task and it would bury this diff.
- Nothing under `/banxa` or `/squidrouter`.
- No assertion may be relaxed to accommodate the change. Where an assertion moves, the
  replacement must be at least as strict, and the task says why.

</constraints>

<tasks>

<task type="auto">
  <name>Task 1: the derivation gains a lead and a status tail, and five strings gain a split point</name>
  <files>lib/dashboard/home/widgets/transaction_utils.dart, test/dashboard/transaction_utils_test.dart</files>
  <action>
Re-measure the baseline first and record it in the SUMMARY: run `flutter test 2>&1 | tail -3`
and note the count. It was 1081 passing when this plan was written.

In `transaction_utils.dart`, on `TxRowContent`:

ADD one constructor field, `subtitleLead`, an optional nullable `String` defaulting to
null. It is the piece of the second line that leads and does not give way. Null means "no
lead", which is what keeps the Buy GNUS orders rail rendering exactly as it does today
without an edit to a file this task may not touch. Document that.

ADD one COMPUTED GETTER, `statusTail`, returning null when `status` is
`TransactionStatus.completed` and otherwise `statusLabel` or the capitalised enum name
(reuse the existing `_statusLabel` helper). Deliberately a getter and not a constructor
field: a caller that builds its own record keeps the narrow row's status without opting
in, and the tail and the pill read the same two fields so they cannot drift. Do not
duplicate the capitalisation rule; `transaction_displays.dart` has its own
`_capitalizeStatus` for the pill and that stays where it is.

Note in the getter's doc that the value carries NO leading middle dot. The row pins it to
the right edge as a separate element with its own gutter, so a separator between two
separated elements is redundant, and the 8px the dot costs is what keeps `Minted` whole
on a pending mint at 113px (see findings 4a).

REWRITE `subtitleBase`'s doc comment. Its meaning narrows from "the whole context line" to
"the part of the context that MAY shrink". Say that `subtitleLead` plus `subtitleBase` is
what the row lays out, that the wide page renders both and suppresses only the tail, and
keep the existing sentence about the status being stated exactly once per presentation.

KEEP `action` and `subtitle` exactly as they are as FIELDS. `action` is the drawer title
(`showTransactionDetails` passes `content.action` to `ResponsiveDrawer.show`) and the Buy
GNUS rail sets it; three of the eight leads deliberately differ from it. `subtitle` is no
longer read by the row, and that is not a reason to delete it: it is the composed whole
line, it is the field the orders rail supplies, and Task 1's invariant test binds the three
pieces to it so they can never drift. Write that down so nobody "simplifies" it away.

In `txRowContent`, set `subtitleLead` per type and split the five self-describing arms.
The table in finding 6 is the specification; do not re-derive it. `process` takes `Job`,
NOT the sketch's `Processing job`, for the measured reason in finding 5, and the arm's
composed string is byte-identical to today's `'Job ${_addressLine(tx.hash)}'`. Compose
`subtitle` from the pieces rather than assigning it directly: join the non-empty lead and
context with a single space, then append the existing `' $_middot ${_statusLabel(status)}'`
suffix under the existing `status != completed` condition. The five arms must come out
byte-identical to what ships today; transfer and swap gain their verb.

`subtitleBase` may now be empty (purchase). That is safe because the lead is what keeps the
second line from collapsing, but say so in the doc comment, because the old contract said
it never was.

In `transaction_utils_test.dart`:

MOVE the three assertions the composition changes, and make each replacement stricter
rather than looser:
  - the swap test asserting `content.subtitle` equals `'1.50 ETH'` becomes an assertion on
    the pieces: lead is `Swapped`, base is `'· 1.50 ETH'`, and the composed subtitle is
    `'Swapped · 1.50 ETH'`.
  - the empty-recipients test asserting `'Unknown recipient'` becomes `'Sent · Unknown
    recipient'` on the composed value plus the base alone on the piece.
  - the process test asserting `content.subtitle` starts with `'Job '` STAYS AS IT IS. It
    passes unchanged and it is the proof that the arm did not drift. Add the two piece
    assertions beside it.
Leave `expect(content.action, 'Processing job')` untouched: the drawer title does not change.

ADD the invariant test, which is the one that makes the split unbreakable. For every
`TransactionType` including null, both directions and all four statuses, assert that
joining the non-empty `subtitleLead` and `subtitleBase` with a space, then appending
` · <statusTail>` when `statusTail` is non-null, reproduces `subtitle` exactly.

ADD a dedup test: for every type, assert `subtitleBase` does not begin with `subtitleLead`,
so nobody can reintroduce the doubling the chip caused.

ADD a test that `subtitleLead` is non-empty for every type, and a test that `statusTail` is
null for `completed` and non-null for the other three.

Keep every existing assertion in the file, including the "subtitle is never empty" loop, the
"a completed subtitle carries no status token" loop and both "stated exactly once" counts.
They all still pass; if one does not, the composition is wrong, not the test.
  </action>
  <verify>
    <automated>flutter test test/dashboard/transaction_utils_test.dart test/banxa/ 2>&1 | tail -3</automated>
  </verify>
  <done>
`transaction_utils_test.dart` and every test under `test/banxa/` pass. `TxRowContent` has
`subtitleLead` (nullable, defaults to null) and a computed `statusTail`. No file under
`lib/banxa/` was edited. The five self-describing arms compose to byte-identical strings.
  </done>
</task>

<task type="auto">
  <name>Task 2: the row drops the chip and lays the subtitle out in three pieces</name>
  <files>lib/dashboard/home/widgets/transaction_displays.dart, test/dashboard/transaction_row_subtitle_test.dart, test/dashboard/transaction_row_test.dart, test/dashboard/transaction_filters_test.dart, test/dashboard/transaction_filter_rail_test.dart</files>
  <action>
Write the new test file FIRST, run it, and record in the SUMMARY that it is red and which
numbers it reports. Those numbers are the evidence for the unreported truncation.

`test/dashboard/transaction_row_subtitle_test.dart`, new. It must load the real bundled
Inter, because the fallback font is one em per character and every width assertion under it
would be fiction. Copy the `FontLoader` pattern documented in
`test/dashboard/compute_balance_unit_track_test.dart`, loading `Inter-Regular.ttf`,
`Inter-Medium.ttf` and `Inter-SemiBold.ttf` from `assets/fonts/` into the family `Inter`.
Pump with the app's REAL `ThemeData` including `GeniusWalletTypography.textTheme`, not a
bare `ThemeData(extensions: [gw])`: Material's default body style carries 0.25 letter
spacing that the app's own text theme does not, which inflates a 26-character line by
6.5px and would make every measurement here wrong by more than the margins it is checking.

Host the real `TransactionRow` in a `SizedBox` at width 366, which is a 390pt phone's
`/transactions` content box and gives the row's middle column exactly 113.0px. Assert:

  1. THE REPORTED DEFECT. For every `TransactionType` including null and both directions,
     on a completed row, the action lead is drawn in full. Measure it by taking the
     subtitle paragraph's `RenderParagraph`, laying out a `TextPainter` over its own
     `text` and `textScaler` with no ellipsis to get the intrinsic width, and asserting the
     rendered width is at least the lead's own intrinsic width plus the ellipsis glyph.
     Report both numbers in the failure message.
  2. THE UNREPORTED DEFECT. On a PENDING MINT at 366, the status tail exists as its own
     `Text` and its rendered width equals its intrinsic width to within half a pixel, so
     not one glyph of it is lost. Also assert the lead survives whole on that same row,
     since it is the tightest pair that must still work (4.3px of margin, finding 4a).
  3. THE ORDER. On that same row, the context is what gave way: the paragraph's rendered
     width is strictly less than its intrinsic width while the tail's is not.
  4. THE CAP HOLDS. For all four `TransactionStatus` values, the tail's intrinsic width is
     below the constant introduced below. This is the guard that fails loudly if a longer
     status word is ever added.
  5. THE WIDE BRANCH. At width 900 the tail is absent and the pill is present, and the
     lead and context are both still drawn.

`transaction_displays.dart`:

DELETE the title line's `Row`, the `SizedBox(width: space4)`, the `surfaceMenu` `Container`
and both `Flexible` wrappers. The title becomes a bare `Text(content.title)` with
`maxLines: 1` and an ellipsis, sitting directly in the `Column`. It gets loose constraints
there and ellipsises on its own, so nothing can overflow. Keep the `titleMd` w600
`textPrimary` style exactly. Replace the "the action a quiet chip beside it" comment with
what is now true, and keep the 010-A token-first note: that decision is unchanged and this
change strengthens it.

REPLACE the subtitle `Text` with a `Row` of two children:

  - `Expanded(child: Text.rich(...))` carrying the lead and the context as two spans of one
    paragraph, `maxLines: 1`, `TextOverflow.ellipsis`, base style
    `GeniusWalletTypography.bodySm.copyWith(color: gw.textSecondary)`, the lead's span at
    `FontWeight.w500`, the context's span prefixed with a single space when a lead is
    present. Emit the lead span only when `subtitleLead` is non-null and the context span
    only when `subtitleBase` is non-empty.
  - the status tail, emitted only when `!wide && content.statusTail != null`: a
    `SizedBox(width: GeniusWalletConsts.space2)` then a `ConstrainedBox` with a constant
    `maxWidth` around a `Text(content.statusTail!)`, `maxLines: 1`, `softWrap: false`,
    ellipsis, same `bodySm` / `textSecondary` ink the suffix has today.

Declare the constant beside `_wideAmountWidth`, which is its precedent, as
`_narrowStatusMaxWidth = 76`. Its doc must carry the derivation: `Cancelled` is the widest
word the status can print and measures 66.0px in the shipped Inter at `bodySm`, so 76
clears it by 10 and never clips in practice; and it must stay under the narrowest middle
column the suite pumps (90px at the 320px case) minus the `space2` gutter, which leaves 10px
of slack there too. Say that it is the row's ONLY non-flex subtitle child and therefore the
one thing that could overflow, which is why it is capped at all. 76 is on the 4-pt grid.

Write the ONE paragraph rule down where the next reader will need it: the lead is protected
by being FIRST in the paragraph, not by a flex fit. Flutter's `Row` gives a loose flex child
only its share of free space and never hands back a narrower sibling's remainder, which is
the precise mechanism that capped the chip at 44.5px; two fixed children would instead throw
a `RenderFlex` overflow at 320. An end ellipsis on one paragraph gives the qualifier-first
order for free and cannot overflow.

`transaction_row_test.dart`: the wide/narrow pill group. The wide case passes unchanged.
The narrow case asserted the suffix through `find.textContaining('· Failed')` and the
absence of a bare `Failed`; both invert now that the tail is its own dotless `Text`. Replace
them with an assertion that is STRICTER than what it replaces: find the single `Failed`
`Text` in each branch and pin WHICH presentation it is by its ink, `gw.textSecondary` for
the narrow tail and `gw.statusError` for the wide pill. That still proves the status is
stated exactly once in each branch and now also proves it is the right element. Rewrite the
group's comment to match. Change nothing else in this file: the 320 and 900 matrix must keep
its pessimistic fallback font and must keep passing untouched.

`transaction_filters_test.dart` and `transaction_filter_rail_test.dart`: comments only. Both
justify their escrow fixture with "it prints Escrow locked (the action chip) and Locked in
escrow (the subtitle)". After this change the escrow row prints `Locked` and `in escrow`,
which still collides with no rail label. Correct both comments. Do not touch a single
assertion in either file.
  </action>
  <verify>
    <automated>flutter test test/dashboard/ test/banxa/ test/components/ 2>&1 | tail -3</automated>
  </verify>
  <done>
The new subtitle test file passes and was red before the widget change, with its numbers
recorded. `test/dashboard/`, `test/banxa/` and `test/components/` are green. No `surfaceMenu`
container remains on the title line. The `wide` boolean gates the status tail and nothing
else.
  </done>
</task>

<task type="auto">
  <name>Task 3: the gates, and the defect found while measuring</name>
  <files>.planning/todos/pending/2026-08-07-transaction-amount-column-clips-common-amounts.md</files>
  <action>
Run the two gates and record both results verbatim in the SUMMARY.

`flutter analyze` must end at **0 issues**. Not "0 errors with warnings", zero.

`flutter test` must end green with a count at least equal to the baseline you measured in
Task 1 plus the tests you added. Report the exact numbers, before and after. If ANY test
that passed at baseline now fails, stop and report it. Do not weaken it, do not delete it,
do not add a skip.

Sweep the diff for em dashes on ADDED lines only, writing the character as an escape so it
never appears literally in a comment or in this plan:

    git diff -U0 -- lib test | grep '^+' | grep -c $'\xe2\x80\x94'

The count must be 0. Middle dots and the U+2212 minus are expected and are not em dashes.

Then file the todo for the defect finding 3 uncovered, at the path in this task's files
list, following the format of the other files in `.planning/todos/pending/`: front matter
with `created`, `title`, `area: ui` and the `files` it concerns, then the problem. State
that the narrow amount column is an `Expanded` receiving 113px at 390pt while ordinary
amounts measure 86.5 to 136.0px in the shipped Inter, that `+ 476.18 USDC` (120.5) and
`− 1.25 WSTETH` (123.6) therefore ellipsise on a phone today, and that sketch 179's
suggestion to RESERVE that column at 96px would make it worse rather than better. Record
that this task deliberately left the column alone because taking width from the amount to
give it to the subtitle damages the one string on the row that must never be wrong. Note
that no test covers it, which is why it is invisible.

Create no commit. Leave the tree dirty.
  </action>
  <verify>
    <automated>flutter analyze 2>&1 | tail -3 && flutter test 2>&1 | tail -3 && git diff -U0 -- lib test | grep '^+' | grep -c $'\xe2\x80\x94'</automated>
  </verify>
  <done>
`flutter analyze` reports 0 issues. `flutter test` is green at or above the baseline plus
the new tests, with both counts recorded. Zero em dashes on added lines. The todo exists.
No commit was created.
  </done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>
The transaction row's title line is now the token alone. The action word moved down to lead
the subtitle where it cannot be capped at half a line, the `surfaceMenu` chip container is
gone, and on the narrow presentation the status is pinned to the right edge of the subtitle
line so it can no longer be clipped off the row. The wide `/transactions` page keeps its
status pill and simply does not draw the tail.

Two deviations from sketch 179 were forced by measurement and need your call:

  1. The status tail carries NO leading middle dot. With the dot, a pending mint at 390pt
     renders `Minte…` instead of `Minted`, which is the exact defect this task removes.
  2. The processing job row's lead is `Job`, not the sketch's `Processing job`. At 99px of a
     113px line the sketch's word would clip on every pending or failed job row, which are
     the rows the word exists for. `Job` is the app's own existing word there and the row's
     text is byte-identical to what ships today. The drawer title is still `Processing job`.

Also settled by measurement, no action needed unless you disagree: the amount column was NOT
reclaimed. The sketch estimated it wastes 23px; measured, ordinary amounts need 86.5 to
136.0px against the 113 it gets, so it has no slack to give and is already clipping. That is
now a separate todo.
  </what-built>
  <how-to-verify>
Run the app on your iPhone in DARK mode and open the Transactions page, then the dashboard
Transactions panel. Look at these five rows specifically. They are the cases the old layout
got wrong and a happy-path walk would miss all of them.

  1. **A PENDING MINT.** The single most important row. `Minted` must be complete, not
     `Minte…`, and `Pending` must be complete at the right edge, not cut off. Before this
     change the app clipped `Pending` off this row entirely. The qualifier `to wallet` is
     expected to be reduced to an ellipsis; that is the design, the line is 113px wide.
  2. **A FAILED SWAP.** `Swapped` complete on the left, `Failed` complete on the right, the
     from-amount in between giving way. The badge on this row is a red cross, so the word
     `Swapped` is the only thing on the row saying what was attempted.
  3. **AN ESCROW RELEASE.** `Released from escrow`, with `Released` never truncating. This
     type has no badge of its own at all, so the word is the only signal.
  4. **A LONG TOKEN NAME.** The title line is now the token alone with the whole width to
     itself, so a long symbol should read further than it used to before ellipsising, and
     the row below it must be unaffected.
  5. **A `Processing job` ROW.** It now reads `Job 0x…`. Confirm that reads right to you, or
     say so if you want `Processing job` back and would rather it clip.

Then check the whole list at a glance: no chip boxes anywhere on the title lines, no text
touching the amount column, and the status words on any pending or failed rows all landing
on one vertical line at the right of the subtitle column.

Use the dev tools bubble's mock transactions if your wallet has no pending or failed rows:
the app must be launched with `--dart-define=GW_DEV_TOOLS=true`.

The wide `/transactions` page cannot be checked on the phone. It is covered by the widget
tests at 900px instead, which assert the pill is present and the tail is absent there.
  </how-to-verify>
  <resume-signal>Type "approved", or name the row that is wrong and what it shows.</resume-signal>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
| --- | --- |
| transaction model to row text | `tx.hash`, addresses and `coinSymbol` are RPC or API supplied and reach text layout |
| caller-built record to row layout | `TxRowContent.statusLabel` is supplied by a caller (the Buy GNUS orders rail) and now reaches a non-flex row child |

## STRIDE Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation Plan |
| --- | --- | --- | --- | --- | --- |
| T-txr-01 | Denial of Service | the status tail, the row's only non-flex child | medium | mitigate | `ConstrainedBox(maxWidth: _narrowStatusMaxWidth)` bounds an unbounded caller-supplied `statusLabel`, so no string can force a `RenderFlex` overflow or an unbounded layout pass. Task 2 asserts the cap holds for every enum value. |
| T-txr-02 | Denial of Service | the subtitle paragraph | low | mitigate | The lead and context share one `Expanded` paragraph with `maxLines: 1` and an ellipsis, so an unbounded address or hash cannot grow the row. This is the 37639d5 freeze guard applied to the new element, and no dimension in this task is derived from constraints: the only new size is a constant. |
| T-txr-03 | Information disclosure | the deduplicated subtitle strings | low | accept | The split changes only which words are drawn and never widens what is drawn. `_addressLine` still truncates through `WalletUtils.getAddressForDisplay` and the full value stays in the drawer's copy row. |
| T-txr-SC | Tampering | package installs | low | accept | This task installs nothing. No `pubspec.yaml` change, no new dependency, no package manager runs. |
</threat_model>

<verification>
- `flutter analyze` reports 0 issues.
- `flutter test` is green at or above the measured baseline plus the added tests, with both
  counts recorded in the SUMMARY.
- No assertion anywhere was deleted, skipped or weakened. The three that moved are recorded
  in the SUMMARY with the reason each replacement is at least as strict.
- The 320px and 900px matrix in `transaction_row_test.dart` still runs under the fallback
  font and still passes with no `RenderFlex` overflow.
- No file under `lib/banxa/`, `lib/squid_router/`, `lib/components/coins/view/coins_screen.dart`,
  `lib/components/cards/gw_section_title.dart` or `lib/components/cards/gw_view_all_link.dart`
  was modified. Check with `git status --short`.
- Zero em dashes on added lines.
- No commit was created.
</verification>

<success_criteria>
1. On a completed row of every `TransactionType`, the action word renders in full at a 366px
   host width. Today 6 of the 8 possible strings are clipped in a 44.5px box.
2. On a pending mint at that width, the word `Pending` renders in full. Today that row needs
   177.6px on a 113.0px line and the status is clipped off it. This is the defect nobody
   reported and it has its own test.
3. The context is the piece that gives way, proven by a test that asserts the paragraph is
   truncated while the tail is not.
4. The status appears exactly once per presentation: the pill on wide, the pinned tail on
   narrow, pinned by ink and not merely by presence.
5. The `surfaceMenu` chip container no longer exists on the title line, taking with it a
   1.13:1 fill and improving its own former label from 5.30:1 to 6.01:1.
6. The five self-describing subtitle arms compose to byte-identical strings, verified by an
   invariant test that binds `subtitleLead`, `subtitleBase` and `statusTail` to `subtitle`.
7. `lib/banxa/` is untouched and the orders rail still renders, proven by `test/banxa/`.
8. Jakub has looked at all five named rows on his iPhone in dark mode and approved, or named
   what is wrong.
</success_criteria>

<output>
Create `.planning/quick/20260807-tx-row-action-leads-subtitle/SUMMARY.md` when done,
recording: the before and after test counts, the numbers the new test reported while it was
red, the two copy deviations from sketch 179 and Jakub's ruling on them at the checkpoint,
and the fact that no commit was created.
</output>
