---
quick_id: 260807-wbu
phase: quick-260807-wbu
plan: 01
type: execute
wave: 1
depends_on: []
autonomous: false
requirements: [WBU-01, WBU-02, WBU-03, WBU-04, WBU-05]
files_modified:
  - lib/components/cards/gw_row_rhythm.dart
  - lib/components/coins/view/coin_card_row.dart
  - lib/components/coins/view/coins_screen.dart
  - lib/chart/crypto_simple_chart.dart
  - lib/dashboard/chart/dashboard_markets.dart
  - lib/components/cards/gw_token_row.dart
  - lib/dashboard/home/widgets/transaction_displays.dart
  - test/components/gw_row_rhythm_test.dart
  - test/components/gw_section_title_rhythm_test.dart
  - test/components/assets_header_scheme_a_test.dart

must_haves:
  truths:
    - "On a 390pt phone, an Assets row and a Markets row put their first painted pixel 8 from the card content edge, exactly like a Transactions row."
    - "On a 390pt phone, the leading glyph in Assets, Markets and Transactions measures 38, and the text column starts at x=54 in all three."
    - "The ink-to-rule gap above and the rule-to-ink gap below measure 12 and 12 in Assets, Markets and Transactions."
    - "R1 stays 12 and R2 stays 26 at every GWSectionTitle call site; the Markets panel improves from 26.75 to exactly 26."
    - "A test measures painted ink, not source padding, and goes red if any of the above drifts."
  artifacts:
    - lib/components/cards/gw_row_rhythm.dart
    - test/components/gw_row_rhythm_test.dart
  key_links:
    - "crypto_simple_chart.dart row padding <-> dashboard_markets.dart contentTopInset (they MUST move together or R2 breaks)"
    - "coin_card_row.dart row padding <-> the two ROW INSET cases in gw_section_title_rhythm_test.dart"
    - "gw_row_rhythm.dart constants <-> all three row widgets (the single place the numbers live)"
---

<objective>
Roll the Transactions row rhythm across the app on mobile: from the card content
edge 8, leading glyph 38, glyph to text 8, text to the right content edge 8, and
12 / 1 / 12 around every rule between two list rows.

Purpose: Jakub walked the Transactions pilot on his iPhone on 2026-08-07 and
asked for it everywhere. Today Assets renders 15.63 / 20.00 around its rule and
Markets renders 13.25 / 16.75, and neither number is declared anywhere in this
repo - both come from Material's default two-line `ListTile` height. This makes
them owned decisions.

Output: one shared constants file, three rows rewritten to the reference shape,
one section-title declaration corrected, and a test that measures painted ink so
this cannot drift back.

**NO COMMITS.** Jakub reviews on device. The app is already running on the iPhone
"Sidney" with hot reload - do not relaunch it, do not rebuild it.
</objective>

<context>
@.planning/quick/260807-v6m-dashboard-panel-bottom-inset-mirrors-the/SEPARATOR-RHYTHM-MEASURED.md
@AGENTS.md
@lib/dashboard/home/widgets/transaction_displays.dart
@lib/components/cards/gw_section_title.dart
@test/components/gw_section_title_rhythm_test.dart
</context>

---

## The decision: (b), with the numbers extracted

The brief asked for a choice between (a) taming the `ListTile`, (b) replacing it
with the reference's `Padding` + `Row`, and (c) extracting a shared row
component. **The pick is (b), with the (c) benefit bought separately and
cheaply: the four numbers move into one file that all three rows import.**

**Why not (a).** `ListTile` snaps to a default tile height (72 for a two-line
tile) and centres its content inside it. `contentPadding` is charged *inside*
that snap, so it cannot subtract from it - the Assets row already declares
`vertical: 4` and still renders 15.63 / 20.00. Hitting 12 / 12 would mean
driving `minVerticalPadding`, `visualDensity`, `dense`, `minLeadingWidth` and
`horizontalTitleGap` simultaneously until the *rendered* number lands, which is
five knobs producing one number that no reader can predict from source. That is
the exact property the measurement report identified as the root cause: the
numbers are invisible in source. (a) preserves the root cause.

**Why not (c), today.** Three costs, one of which is a project rule:
- AGENTS.md: *"If the shared version needs a boolean flag to serve both callers,
  or you can't name it clearly, don't extract it."* The three anatomies are
  genuinely different - `TransactionRow` carries an optional desktop time
  column, a badge that overhangs its glyph slot by 2px, a `contentOverride`
  path and a `compact` branch; `CoinCardRow` has a two-widget subtitle Row with
  a percentage chip; `CryptoSparkLineChart` has a fixed 72x32 `LineChart` in an
  RTL trailing Row. A component serving all three needs leading, title,
  subtitle, trailing, plus flags - which is `ListTile` again, hand-rolled.
- Blast radius. (c) rewrites three shipping lists in one pass, with the app live
  on Jakub's phone, no commits to roll back to, and 384 green tests.
- Parallelism. (c) puts every task behind one shared file. (b) gives three
  disjoint files, which is what Jakub asked for today.

**Upgrade path to (c), stated so it is not lost.** `gw_row_rhythm.dart` is the
seed. When a fourth list row appears, or when `TransactionRow`'s desktop time
column is dropped (it is already dropped on the phone), promote the shared shape
into `GWListRow` in that same directory, give it `leading` / `title` /
`subtitle` / `trailing` slots, and migrate the three rows one at a time - the
pinning test written here is what makes each migration verifiable. Do not
attempt it while the rows still disagree on their trailing flex model (see
Task 2 and Task 3, which differ deliberately and say why).

---

## Findings that change what the executors write

**F1. The rhythm test CANNOT stay green unedited. That is unavoidable and it is
not a regression.**

`test/components/gw_section_title_rhythm_test.dart` has two cases,
`ROW INSET - CoinCardRow (Assets)` (line 562) and
`ROW INSET - CryptoSparkLineChart (Markets panel)` (line 603), each of which
asserts `expect(c, greaterThan(kMaxAbsorbableInset))` where
`kMaxAbsorbableInset` is 16. Those assertions exist *because* the `ListTile`
snap exists. This task deletes the snap and puts `c` at 12, so both go red by
construction. They are characterization of a Material default, not a
requirement.

What does NOT move, and must be left byte-identical: the `CONTRACT` loop, the
`OVERSHOOT` loop, the `COMPUTE` loop and the `TRANSACTIONS` case. **R1 stays 12
and R2 stays 26 at every site.** The Markets panel actually improves - its C
goes 16.75 -> 12, its derived bottom pad goes 0 -> 4 (`space2`, on the grid),
and R2 goes 26.75 -> exactly 26. C = 12 is *already* an iteration of the
`CONTRACT` loop (line 401, `GeniusWalletConsts.space6`), so the property is
already pinned and needs no new case.

**F2. `assets_header_scheme_a_test.dart`'s 94 does NOT move.** Line 552 measures
`CoinCardRow` layout-box top minus `GWSectionTitle` layout-box top. Internal row
padding changes the row's height, not its box top. The 94 stands; only its
`reason` prose ("the row brings its own ~20px ListTile snap and that IS the
gap") becomes false. **Change the prose, do not touch the number.** If an
executor finds themselves adjusting 94, they have changed something else.

**F3. `compute_panel_height_test.dart` is unaffected.** It mounts `ComputePanel`
only, which contains none of these rows. It was listed as a risk; it is not one.

**F4. `dashboard_section_caps_test.dart` is unaffected.** Every assertion in it
is a row COUNT, a symbol ORDER, or the relative ordering
`labelTop > lastRowBottom`. None reads an absolute height.

**F5. The premise about `settings_screen.dart:338` and
`submit_logs_screen.dart:603` is wrong.** Both DO pin their colour:
`Divider(color: gw.borderSubtle)` at `settings_screen.dart:338` and
`Divider(color: gw.borderSubtle, height: 1)` at `submit_logs_screen.dart:603`.
There is no colour bug at either site. The `dividerTheme` fill-colour problem is
real but reaches exactly three call sites, all bare `Divider()` and all on the
debug Network page (`network_page.dart:130`, `:155`, `:181`), plus
`order_card.dart:79` (`Divider(height: 20)`, no colour). `theme.dart:380`'s own
comment claiming *"settings_screen.dart (and 6 other files) call bare
Divider()"* is stale. **Out of scope here - it is a colour bug, not a rhythm
bug. File it as a todo, do not fix it in this pass.**

**F6. `transaction_displays.dart:267` is now a lie.** Its class doc says
*"Geometry matches `GWTokenRow` (40px icon slot, space6/space4 padding, radiusMd
InkWell)"*. The row ships 38 / space4-space6 since this morning, and `GWTokenRow`
still ships 40 / space6-space4. The reference cites the stale widget as its
authority. Task 4 fixes both ends.

**F7. `GWTokenRow` has exactly one call site and it is the dev gallery**
(`design_gallery_screen.dart:713`, `:721`). No production surface renders it.
Cost to align it is four token swaps and it removes F6's lie, so it is IN.

**F8. `banxa_buy_screen.dart:1373` inherits for free - confirmed by reading.** It
builds a `ListView.separated` whose `itemBuilder` returns the same
`TransactionRow` and whose `separatorBuilder` returns
`Divider(height: 1, thickness: 1, color: gw.borderSubtle)` with no padding
around it. Verify at the walk, edit nothing.

**F9. The `/assets` page full-bleed question resolves to "no decision needed".**
Report finding 7 flagged it as needing a decision *if* the rollout touched
walls. The Assets wall is already 8 and stays 8, so the row's relationship to
the bezel does not change. What DOES change on that page: the kicker-to-first-row
ink gap tightens from 8 + 20 = 28 to 8 + 12 = 20, because
`assets_screen.dart:389` puts a `space4` spacer above rows that used to bring 20
of their own. **Do not pre-emptively change that spacer.** Show Jakub the 20 on
device; if he reads it tight, `space4` -> `space6` is a one-token follow-up.

**F10. Same class of change under the Assets total band.**
`coins_screen.dart:429-435` documents "NO spacer between the band and the first
`CoinCardRow`" on the grounds that the row's own ~20px snap IS the gap. After
this change that gap is 12. Sketch 178 drew 14 there, so 12 lands closer to the
sketch than 20 did - but it is an 8px tightening Jakub has not seen. Flag it at
the walk; the comment must be corrected in the same task that causes it.

---

## Scope: every separator site, IN or OUT

### IN - edited

| Site | Why |
|---|---|
| `coin_card_row.dart` | The Assets row. Jakub named it. `ListTile` -> reference shape. |
| `crypto_simple_chart.dart` | The Markets row. Jakub named it. `ListTile` -> reference shape. |
| `dashboard_markets.dart:127` | `contentTopInset: 16.75` becomes a lie the moment the row changes. Coupled, same task. |
| `coins_screen.dart:429-435` | Comment asserts a 20px gap this change makes 12. Comment only. |
| `gw_token_row.dart` | F7. The geometry the reference row *cites*. Four token swaps. |
| `transaction_displays.dart:267` | F6. Comment only. No code. |
| `gw_row_rhythm.dart` (new) | The one place the four numbers live. |
| `gw_row_rhythm_test.dart` (new) | Pins the rhythm in painted ink. |
| `gw_section_title_rhythm_test.dart` | F1. Two characterization cases + the doc table. |
| `assets_header_scheme_a_test.dart` | F2. Prose only. |

### IN - verified, not edited

`banxa_buy_screen.dart:1373` (F8) - same `TransactionRow`, zero-padding
separator. `route_details_card.dart:104` and `markets_table.dart:181` / `:228`
already ship symmetric 12 / 12 from an explicit `vertical: space6` with no
`ListTile` in the path. Task 5 re-reads all four rather than trusting the list.

### OUT - with the reason

- **`gw_detail_grid.dart:70` (8 / 8).** A read-only label/value TABLE inside a
  recessed well, with no leading glyph column at all - so three of the four
  numbers in the spec have nothing to attach to. Its own doc argues its
  hairlines are decorative rather than 1.4.11 graphical objects, and its five
  call sites are receipt and order drawers where the group is meant to read
  tighter than a scroll list. Jakub's spec is about a list row's glyph-to-text
  rhythm. Changing it would make every receipt taller against no complaint.
- **`gw_select_row.dart`.** A SELECTION row. It has no rule between rows at all -
  it uses a 4px bottom margin and a rounded selection tint, so there is no
  separator rhythm to apply. Its 36px leading is sized by the CALL SITE, not the
  row, so the component cannot own a 38. Applying the spec would mean inventing
  a separator this picker deliberately does not have.
- **`transactions_slim_view.dart:1176` (`_rule`).** Desktop `/transactions` page
  only, and it separates GROUPS of unlabeled filter chips - its neighbours are
  group HEADERS, not glyph rows. Its 18.50 / 16.00 asymmetry is real but comes
  from `_groupHeader`'s own top pad, which is a different fix on a surface that
  is not the mobile target.
- **`web_view_mobile.dart`, `responsive_overlay.dart:87`,
  `token_info_screen.dart:1230` vertical separators.** 1px WIDE, deliberately
  shorter than their container. A horizontal-gap spec has no meaning for a
  vertical rule.
- **Section rules** - `settings_screen.dart:338`, `submit_logs_screen.dart:603`,
  `markets_hero_card.dart:154`, `token_info_screen.dart:1492`, the two reown
  drawer headers, `responsive_drawer.dart:310`,
  `transactions_slim_view.dart:926`. These separate a title from a body or a
  header from a drawer, not one row from the next. Different relationship,
  different value.
- **`network_page.dart:130/155/181`** (debug screen),
  **`sdk_account_manager.dart:256`** (menu chrome), **`order_card.dart:79`**
  (label/value rows in a card, same category as `GWDetailGrid`). All three carry
  the F5 colour bug; none carries the rhythm problem. Todo, not this pass.

---

<tasks>

<task type="auto" wave="1" tdd="true">
  <name>Task 1: land the constants and MEASURE the before state (Wave 1 - alone, everything depends on it)</name>
  <files>lib/components/cards/gw_row_rhythm.dart, test/components/gw_row_rhythm_test.dart</files>

  <behavior>
    At the end of this task, run at a 390x844 logical phone window:
    - TransactionRow standalone: top inset 12, bottom inset 12, first ink x=8,
      title x=54, last ink right edge 8 from the row's right. ALL GREEN - the
      reference already ships this.
    - Transactions panel separator: 12 above the rule, rule 1, 12 below. GREEN.
    - CoinCardRow standalone: RED. Expect roughly 15.6 top / 20.0 bottom, first
      ink around x=8, title around x=62.
    - CryptoSparkLineChart standalone: RED. Expect roughly 13.25 top / 16.75
      bottom, first ink around x=16, title around x=66.
    - Assets panel separator: RED at roughly 15.63 / 1 / 20.00.
    The red cases are the RED half of RED-GREEN. Waves 2 and 3 turn them green.
  </behavior>

  <action>
Create `lib/components/cards/gw_row_rhythm.dart`. It holds the four numbers
Jakub named on 2026-08-07 and nothing else - no widget, no abstraction. Declare
`kGWRowWall` as `GeniusWalletConsts.space4`, `kGWRowIconToText` as
`GeniusWalletConsts.space4`, `kGWRowSeparatorGap` as `GeniusWalletConsts.space6`,
`kGWRowIconSize` as the literal `38`, a `kGWRowPadding` `EdgeInsets.symmetric`
built from `kGWRowWall` and `kGWRowSeparatorGap`, and a DERIVED
`kGWRowTextColumnX` computed as `kGWRowWall + kGWRowIconSize + kGWRowIconToText`
(do not type 54; let the arithmetic produce it, so a change to any term moves the
test with it).

Three things the file's doc comment must record, because this file exists to make
invisible numbers visible: (1) every spacing value is an existing token, so
nothing off-grid is introduced; (2) `kGWRowIconSize` 38 is the one untokened
value and it is a SIZE, not a spacing - it is Jakub's pick, taken from what the
Assets row already shipped; (3) these numbers previously came from Material's
default two-line `ListTile` height and were therefore undeclared anywhere,
which is the drift this file exists to stop. Cite the measurement report by
path.

Create `test/components/gw_row_rhythm_test.dart`. It MEASURES painted ink, never
source padding - the whole finding of the measurement report is that source
padding does not predict what renders. Reuse the existing measurement machinery:
`test/components/gw_section_title_rhythm_test.dart` declares `library;` at line
141, so `firstPaintedTopBelow` can be imported from it directly. Do NOT edit
that file from this task. If the runner rejects the cross-test import, copy
`_paintsInk`, `_decorationPaints` and `firstPaintedTopBelow` into the new file
and say in a comment that the duplication is deliberate because the source file
is pinned.

Add the three twins the report used and deleted: a `lastPaintedBottomAbove`, a
`firstPaintedLeftIn` and a `lastPaintedRightIn`, built the same way - iterate
painted descendants, read `localToGlobal` plus `size`, ignore anything that
occupies space without painting.

Every case sets a real phone window before pumping: `tester.view.physicalSize =
const Size(390 * 3, 844 * 3)`, `devicePixelRatio = 3.0`, with `addTearDown`
resets - the pattern already used in `transaction_row_test.dart` and
`assets_screen_test.dart`. This matters twice over: `compact` in
`transaction_displays.dart` reads the WINDOW, and mobile is the whole target.

Standalone row cases, one per row, each pumped in a `SizedBox(width: 364)` (the
phone card content box the report measured): assert row top inset equals
`kGWRowSeparatorGap`, row bottom inset equals `kGWRowSeparatorGap`, first painted
x minus row left equals `kGWRowWall`, the title paragraph's left minus row left
equals `kGWRowTextColumnX`, and row right minus last painted right equals
`kGWRowWall`. Measuring the title's left edge is what pins the glyph size and the
glyph-to-text gap JOINTLY without having to find three different glyph widgets
across three different anatomies - state that in a comment.

In-host separator cases: mount the Assets dashboard panel by copying the
`WalletDetailsCubit` fixture shape from
`test/dashboard/dashboard_section_caps_test.dart` (it mounts `CoinsScreen`
successfully), and mount `TransactionsSlimView` the way
`gw_section_title_rhythm_test.dart:519` does. For each, take the first `Divider`
between two rows and assert last-ink-above to rule top equals
`kGWRowSeparatorGap`, rule height equals 1, and rule bottom to first-ink-below
equals `kGWRowSeparatorGap`.

The Markets panel is NOT mountable - `DashboardMarkets` fetches in `initState`.
Its separator is a bare `Container(height: 1)` appended straight into a `Column`
with no padding around it (`dashboard_markets.dart:167`), so the rule gap IS the
two rows' own insets, which the standalone case already pins. Say exactly that
in a comment, name the limitation, and do not fake a mount.

`debugPrint` every measured number with a stable prefix so the before and after
runs can be diffed by eye, the way the section-title test already does. Paste
this run's output into the file's library doc as the BEFORE column, dated.

Run the file. Record which cases are red and with what numbers - that recording
is this task's real output.
  </action>

  <verify>
    <automated>/Users/jakub/development/flutter/bin/flutter analyze 2>&1 | tail -3</automated>
    <automated>/Users/jakub/development/flutter/bin/flutter test test/components/gw_row_rhythm_test.dart 2>&1 | tail -40</automated>
    <automated>grep -v '^\s*//' lib/components/cards/gw_row_rhythm.dart | grep -c 'kGWRowTextColumnX'</automated>
  </verify>

  <done>
`gw_row_rhythm.dart` exists, exports the five constants plus the derived text
column x, introduces no widget, and `flutter analyze` is 0 issues.
`gw_row_rhythm_test.dart` exists and its BEFORE numbers are pasted into its own
doc. The TransactionRow standalone case and the Transactions separator case are
GREEN. The CoinCardRow, CryptoSparkLineChart and Assets separator cases are RED
with the measured before numbers quoted in the task report. No file outside the
two listed is touched.
  </done>
</task>

<task type="auto" wave="2" tdd="true">
  <name>Task 2: the Assets row (Wave 2 - runs concurrently with Tasks 3 and 4)</name>
  <files>lib/components/coins/view/coin_card_row.dart, lib/components/coins/view/coins_screen.dart</files>

  <behavior>
    `flutter test test/components/gw_row_rhythm_test.dart` turns green for the
    `CoinCardRow` standalone case and the Assets panel separator case: 8 wall,
    text column at 54, 12 / 1 / 12 around the rule.
    No `RenderFlex` overflow at 364 wide with a long token name and a large
    balance.
  </behavior>

  <action>
In `coin_card_row.dart`, replace the `ListTile` with the same `Padding` + `Row`
shape `transaction_displays.dart:390-627` uses. Keep `GWHoverRow` exactly where
it is, including its `semanticLabel` - its doc says the child arrives already
padded, which is the contract this satisfies.

The shape: `Padding(padding: kGWRowPadding)` wrapping a `Row` whose children are
`buildTokenIcon(iconPath: iconPath, size: kGWRowIconSize)`, a
`SizedBox(width: kGWRowIconToText)`, `Expanded` around the existing name and
subtitle `Column`, a second `SizedBox(width: kGWRowIconToText)`, and the existing
trailing `Column`. The two `Text` children in the name column and the two in the
trailing column are unchanged - every style, colour, `noBalance` branch and the
24-01 contrast fix carry over verbatim. This task changes geometry only.

**The trailing takes `Flexible`, not `Expanded`, and that is a deliberate
difference from the reference.** The reference's amount column is an `Expanded`
because that row's amount must right-align flush to the card edge and ellipsise
at 320px. Here the trailing is two unbounded `Text`s, so it needs a bounded box
to ellipsise inside - but it must not be forced to fill half the row when its
content is short. `Flexible` gives it a loose upper half and lets the `Column`'s
`crossAxisAlignment: end` right-align inside it, which reproduces what
`ListTile`'s trailing slot did. Record this in a comment with that reasoning, so
a future consolidation into a shared component does not "tidy" it into
`Expanded`.

The right wall falls out of the symmetric `kGWRowPadding` - do not add a second
right-hand inset.

MEASURE and report the name column's rendered width before and after. The
`ListTile` gave the title whatever was left after an intrinsic-width trailing;
the 1:1 flex split gives it half. If a real token name ellipsises at 364 where it
did not before, say so in the task report with the measured widths - do not
silently change the flex ratio to hide it. That is Jakub's call at the walk.

Then correct `coins_screen.dart:429-435`. That comment states "The row's own
~20px ListTile centring snap IS the gap" between the total band and the first
row. After this change the gap is `kGWRowSeparatorGap`. Rewrite the comment to
state the new number, keep its conclusion (still NO spacer - the row's own top
inset is still the gap), and record that 12 is closer to sketch 178's drawn 14
than the 20 it replaces. Touch nothing else in that file - it is not otherwise
in this task's scope and Task 3 and Task 4 own different files.
  </action>

  <verify>
    <automated>/Users/jakub/development/flutter/bin/flutter analyze 2>&1 | tail -3</automated>
    <automated>/Users/jakub/development/flutter/bin/flutter test test/components/gw_row_rhythm_test.dart -n 'CoinCardRow' 2>&1 | tail -25</automated>
    <automated>/Users/jakub/development/flutter/bin/flutter test test/components/gw_row_rhythm_test.dart -n 'Assets' 2>&1 | tail -25</automated>
    <automated>/Users/jakub/development/flutter/bin/flutter test test/dashboard/assets_screen_test.dart test/dashboard/assets_sort_test.dart test/dashboard/dashboard_section_caps_test.dart 2>&1 | tail -12</automated>
    <automated>grep -v '^\s*//' lib/components/coins/view/coin_card_row.dart | grep -c 'ListTile('</automated>
  </verify>

  <done>
The last grep returns 0 - no `ListTile` constructor call remains in the row,
while doc comments explaining its removal are still allowed. The two
`gw_row_rhythm_test.dart` Assets cases are green. `assets_screen_test.dart`,
`assets_sort_test.dart` and `dashboard_section_caps_test.dart` are green.
`flutter analyze` is 0 issues. The before/after name-column widths are in the
task report. No `RenderFlex` exception at 364 wide.
  </done>
</task>

<task type="auto" wave="2" tdd="true">
  <name>Task 3: the Markets row and its coupled section-title declaration (Wave 2 - runs concurrently with Tasks 2 and 4)</name>
  <files>lib/chart/crypto_simple_chart.dart, lib/dashboard/chart/dashboard_markets.dart</files>

  <behavior>
    `flutter test test/components/gw_row_rhythm_test.dart -n 'CryptoSparkLineChart'`
    turns green: 8 wall, text column at 54, 12 top inset, 12 bottom inset.
    `flutter test test/components/gw_section_title_rhythm_test.dart -n 'CONTRACT'`
    stays green - the C=12 iteration it already runs is now the Markets panel's
    real value.
  </behavior>

  <action>
These two files MUST move together and therefore belong to one agent. The
Markets panel's `GWSectionTitle` declares `contentTopInset: 16.75` as a MEASURED
fact about its first row. Changing the row without changing that declaration
leaves a false fact in the tree and moves R2 off 26.

In `crypto_simple_chart.dart`, replace the `ListTile` with
`Padding(padding: kGWRowPadding)` around a `Row`: the token glyph at
`kGWRowIconSize`, a `SizedBox(width: kGWRowIconToText)`, `Expanded` around a
`Column` holding the existing title and subtitle `Text`s unchanged, a second
`SizedBox(width: kGWRowIconToText)`, then the existing trailing `Row` as a
NON-flex child. Keep `GWHoverRow` and its `semanticLabel` exactly as they are.
Keep every comment on the title, the subtitle and the RTL trailing order - the
`AutoSizeText` freeze warning and the sparkline geometry note are load-bearing
history, not decoration. The `titleAlignment: ListTileTitleAlignment.center`
line goes away; the `Row`'s default centre cross-axis alignment replaces it.

**The trailing is non-flex here, unlike Task 2's, and the reason is that its
width is bounded by construction** - a fixed 72x32 `LineChart`, a `space6` gap,
and a percentage chip whose longest label is a signed three-digit percentage.
There is no unbounded text in it, so it cannot overflow, and giving it flex would
only shrink the sparkline. Write that reason down; the two rows disagreeing on
this is the single largest obstacle to a future shared component and the next
agent needs to know it is deliberate.

Delete the `iconSize` field and its constructor parameter. It has a default of
34 and its one call site (`dashboard_markets.dart:174`) never passes it, so it is
a knob nobody turns - and leaving a per-call-site glyph size in place is exactly
how the three lists drifted to 40 / 38 / 34 in the first place. Use
`kGWRowIconSize` directly.

Then in `dashboard_markets.dart`, change `contentTopInset: 16.75` to
`kGWRowSeparatorGap`. Rewrite the comment above it: the number is no longer a
Material snap measured through a probe, it is now the row's own declared padding,
and it is a value the component can fully absorb - the derived bottom pad goes
from 0 to `space2` (4) and the rendered R2 goes from 26.75 to exactly 26. State
that this panel joins the shared 26 rather than overshooting it, and that
`gw_section_title_rhythm_test.dart`'s `CONTRACT` loop already covers C = 12 so
no new case is needed. Keep the paragraph about phase 25's `ListView.separated`
to `Column` swap - it is still true and still explains why the inset describes
the ROW rather than its host.
  </action>

  <verify>
    <automated>/Users/jakub/development/flutter/bin/flutter analyze 2>&1 | tail -3</automated>
    <automated>/Users/jakub/development/flutter/bin/flutter test test/components/gw_row_rhythm_test.dart -n 'CryptoSparkLineChart' 2>&1 | tail -25</automated>
    <automated>/Users/jakub/development/flutter/bin/flutter test test/components/gw_section_title_rhythm_test.dart -n 'CONTRACT' 2>&1 | tail -20</automated>
    <automated>/Users/jakub/development/flutter/bin/flutter test test/dashboard/markets_hero_height_test.dart 2>&1 | tail -8</automated>
    <automated>grep -v '^\s*//' lib/chart/crypto_simple_chart.dart | grep -c 'ListTile(\|iconSize'</automated>
  </verify>

  <done>
The last grep returns 0 - neither a `ListTile` constructor nor the `iconSize`
knob survives in code, while doc comments may still name them. The
`CryptoSparkLineChart` rhythm case is green. The `CONTRACT` loop in
`gw_section_title_rhythm_test.dart` is green and was NOT edited.
`dashboard_markets.dart` declares `kGWRowSeparatorGap` and its comment states the
26.75 -> 26 improvement. `flutter analyze` is 0 issues.
  </done>
</task>

<task type="auto" wave="2">
  <name>Task 4: the gallery reference row and the stale citation (Wave 2 - runs concurrently with Tasks 2 and 3)</name>
  <files>lib/components/cards/gw_token_row.dart, lib/dashboard/home/widgets/transaction_displays.dart</files>

  <action>
`GWTokenRow` renders in exactly one place - the dev gallery
(`design_gallery_screen.dart:713` and `:721`) - and
`transaction_displays.dart:267` cites it as the geometry the shipping
Transactions row matches. Both statements are now false: the reference row moved
to a 38 glyph with `space4` / `space6` padding this morning, and the gallery
still shows 40 with `space6` / `space4`. A gallery that contradicts every
shipping list is worse than no gallery.

In `gw_token_row.dart`: swap the `Padding`'s `EdgeInsets.symmetric` for
`kGWRowPadding`, the `SizedBox` glyph slot from 40 to `kGWRowIconSize` on both
width and height, and the glyph-to-text `SizedBox` from `space6` to
`kGWRowIconToText`. The `_FallbackDot`'s `CircleAvatar` radius is 20, which is
half of the old 40 - move it to half of `kGWRowIconSize` so the fallback still
fills its slot. Nothing else changes; the hover migration comment stays.

In `transaction_displays.dart`: correct ONLY the class doc line reading
"Geometry matches `GWTokenRow` (40px icon slot, space6/space4 padding, radiusMd
InkWell)". Replace the parenthetical with the values the row actually ships and
point at `gw_row_rhythm.dart` as the authority instead of at another widget - a
row citing a second row is how the two drifted apart. **Touch no code in that
file.** It is the approved pilot, it is uncommitted, and it is explicitly frozen
by this task's scope. If you find yourself editing anything inside a `build`
there, stop.
  </action>

  <verify>
    <automated>/Users/jakub/development/flutter/bin/flutter analyze 2>&1 | tail -3</automated>
    <automated>/Users/jakub/development/flutter/bin/flutter test test/dashboard/transaction_row_test.dart test/dashboard/transaction_row_subtitle_test.dart 2>&1 | tail -10</automated>
    <automated>grep -c '40px icon slot' lib/dashboard/home/widgets/transaction_displays.dart</automated>
    <automated>grep -v '^\s*//' lib/components/cards/gw_token_row.dart | grep -c 'kGWRowPadding'</automated>
  </verify>

  <done>
The `40px icon slot` grep returns 0. `gw_token_row.dart` uses `kGWRowPadding`,
`kGWRowIconSize` and `kGWRowIconToText` and no literal 40 or 20 remains in its
geometry. Both Transactions row test files are green, proving the doc-only edit
changed no behaviour. `flutter analyze` is 0 issues.
  </done>
</task>

<task type="auto" wave="3">
  <name>Task 5: reconcile the coupled tests and re-establish the baseline (Wave 3 - alone, after all of Wave 2)</name>
  <files>test/components/gw_section_title_rhythm_test.dart, test/components/assets_header_scheme_a_test.dart, test/components/gw_row_rhythm_test.dart</files>

  <action>
This task exists because F1 is unavoidable, and it is deliberately the ONLY task
allowed to touch `gw_section_title_rhythm_test.dart` - so that no Wave 2 agent
can quietly relax a pinned assertion to make their own change pass.

In `gw_section_title_rhythm_test.dart`, change exactly two cases and one table.
`ROW INSET - CoinCardRow (Assets)` and
`ROW INSET - CryptoSparkLineChart (Markets panel)` currently assert
`greaterThan(kMaxAbsorbableInset)` because a Material default put their content
below what the section title could absorb. That default is gone. Re-point both to
assert the measured inset equals `kGWRowSeparatorGap` and is now at or below
`kMaxAbsorbableInset`, and rewrite each `reason` to say what the assertion now
protects: that the row declares its own inset and the section therefore renders
the shared 26 rather than overshooting it. Keep the ink-measurement approach -
`firstPaintedTopBelow`, never `getRect(row).top` - the file's own doc explains at
length why, and that reasoning is untouched by this change.

Update the measured table in the library doc: the Markets panel row goes
C 16.75 -> 12, B 0 -> 4, R2 26.75 -> 26. The Assets row entry describes the
`CoinCardRow` standalone probe, not the section (Assets declares 0 because the
total band is first), so correct its C to 12 and note that the section's own R2
is unaffected. Rewrite the "the two overshoots are deliberate" paragraph: after
this change there is ONE overshoot case left and it is synthetic - the
`OVERSHOOT` loop's `InsetProbe` at 16.75 and 20 - which is now a pure contract
test with no real call site behind it. Say so; a reader must not go looking for
the panel it describes.

**Do NOT touch the `CONTRACT` loop, the `OVERSHOOT` loop, the `COMPUTE` loop or
the `TRANSACTIONS` case.** R1 stays 12 and R2 stays 26; both were approved on
device on 2026-08-06 and are inputs here, not outputs. If any of those four goes
red, a Wave 2 task did something outside its brief - report it, do not adjust the
assertion.

In `assets_header_scheme_a_test.dart`, change the `reason` string at line 559-563
only. Its claim that the row brings "its own ~20px ListTile snap and that IS the
gap" is now false; the gap is `kGWRowSeparatorGap`. **The 94 does not move** - it
measures layout box to layout box and internal padding does not enter it (F2).
If the number is red, something changed a box boundary and that is a stop, not a
number to update.

Finally, add the AFTER column to `gw_row_rhythm_test.dart`'s library doc from a
fresh run, next to Task 1's BEFORE column, so the file records the whole move.

Then run the FULL suite and quote real output. AGENTS.md forbids claiming a
baseline you did not run. The stated starting point is 384 green in
`test/dashboard/` and a green
`test/components/gw_section_title_rhythm_test.dart`; report the actual totals
and name every case whose status changed, with its number.
  </action>

  <verify>
    <automated>/Users/jakub/development/flutter/bin/flutter analyze 2>&1 | tail -3</automated>
    <automated>/Users/jakub/development/flutter/bin/flutter test test/components/gw_section_title_rhythm_test.dart 2>&1 | tail -20</automated>
    <automated>/Users/jakub/development/flutter/bin/flutter test test/components/gw_row_rhythm_test.dart 2>&1 | tail -30</automated>
    <automated>/Users/jakub/development/flutter/bin/flutter test 2>&1 | tail -20</automated>
    <automated>grep -c 'kFrozenBoxToTitle' test/components/gw_section_title_rhythm_test.dart</automated>
  </verify>

  <done>
The full suite is green and its totals are quoted from real output, not asserted.
`gw_row_rhythm_test.dart` is entirely green with BEFORE and AFTER columns in its
doc. In `gw_section_title_rhythm_test.dart` exactly two cases and the doc table
changed; the `CONTRACT`, `OVERSHOOT`, `COMPUTE` and `TRANSACTIONS` cases are
byte-identical and green, and the `kFrozenBoxToTitle` grep still finds its
assertions. `assets_header_scheme_a_test.dart` still asserts 94 and only its
prose moved. `flutter analyze` is 0 issues.
  </done>
</task>

<task type="checkpoint:human-verify" wave="4" gate="blocking">
  <what-built>
Assets and Markets rows now render the Transactions rhythm on the phone: 8 from
the card content edge to the glyph, a 38 glyph, 8 to the text, 8 to the right
edge, and 12 / 1 / 12 around every rule between two rows. The dev gallery's
reference row was aligned to the same numbers, and the four values now live in
one file with a test that measures painted ink.
  </what-built>
  <how-to-verify>
The app is ALREADY RUNNING on "Sidney". Do not relaunch it. Press `r` in the
running `flutter run` terminal for a hot reload - `R` (hot restart) crashes this
app on the RocksDB lock.

1. Home -> the Assets panel. The rule gaps should read even above and below, and
   the token logo should sit where a transaction logo sits.
2. Home -> the Markets panel. Same check. The logo is bigger than it was (34 ->
   38) and closer to the edge (16 -> 8).
3. Home -> the Transactions panel. Nothing should have moved. This is the
   control.
4. Put Assets, Markets and Transactions on screen together and scan the left
   edge - the three logo columns should line up.
5. **The Assets total band** (Home -> Assets panel). The gap between the dollar
   total and the first row tightened from 20 to 12. Is that right, or does the
   band now sit too close to the list?
6. **The `/assets` page** - tap View all. The gap between the "N assets" kicker
   and the first row tightened from 28 to 20. Same question. A one-token bump is
   the fix if it reads tight.
7. **Long token names on `/assets`.** The Assets row now splits its width 1:1
   between the name block and the value block. Look for a name ellipsising that
   did not before.
8. Buy GNUS -> "Your orders". It renders the same Transactions row and should
   have inherited everything for free.
  </how-to-verify>
  <resume-signal>Type "approved", or name the screen and what is wrong with it</resume-signal>
</task>

</tasks>

---

## Parallel execution

| Wave | Tasks | Concurrency | Files owned |
|---|---|---|---|
| 1 | Task 1 | ALONE | `gw_row_rhythm.dart`, `gw_row_rhythm_test.dart` |
| 2 | Tasks 2, 3, 4 | **All three in parallel** | 2: `coin_card_row.dart`, `coins_screen.dart` / 3: `crypto_simple_chart.dart`, `dashboard_markets.dart` / 4: `gw_token_row.dart`, `transaction_displays.dart` |
| 3 | Task 5 | ALONE | the three test files |
| 4 | Task 6 | ALONE, human | none |

**Why Wave 1 is alone.** All three Wave 2 tasks import `gw_row_rhythm.dart`, and
all three verify against `gw_row_rhythm_test.dart`. Neither exists until Task 1
lands.

**Why Wave 2 parallelises cleanly.** The three file sets are disjoint. No file
appears in two tasks. The one coupling that could have forced serialisation -
the Markets row and its `contentTopInset` declaration - is contained inside
Task 3 by design.

**Why Wave 3 is alone.** It is the only task permitted to edit
`gw_section_title_rhythm_test.dart`, and it must see all of Wave 2 landed before
it can run the full suite and quote a baseline.

**During Wave 2, agents run SCOPED tests only.** `gw_row_rhythm_test.dart` is
red for the other two rows until their sibling task finishes, so a full-suite run
mid-wave reports a neighbour's work as a failure - the exact 2026-07-22 collision
AGENTS.md documents. Each Wave 2 task's `verify` block is already scoped with
`-n`. Only Task 5 runs `flutter test` bare.

**Flutter is not on `PATH`** in this repo's environment. It is at
`/Users/jakub/development/flutter/bin/flutter`.

---

<threat_model>
## Trust Boundaries

| Boundary | Description |
|---|---|
| none crossed | Presentation-layer geometry only. No new input path, no network call, no storage, no key material. |

## STRIDE Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation Plan |
|---|---|---|---|---|---|
| T-wbu-01 | Denial of Service | `coin_card_row.dart` Row flex | low | mitigate | Replacing `ListTile`'s intrinsic-width trailing with a flex child can raise a `RenderFlex` overflow, which paints a stripe over real content. The trailing takes `Flexible` (loose) and both `Text`s keep `maxLines: 1` + ellipsis; `gw_row_rhythm_test.dart` pumps at 364 and asserts `takeException()` is null. |
| T-wbu-02 | Information Disclosure | `crypto_simple_chart.dart` | low | accept | Deleting `iconSize` narrows the widget's public surface. No caller passes it; no data path touched. |
| T-wbu-SC | Tampering | npm/pip/cargo installs | n/a | accept | This task installs no packages and adds no dependency. No legitimacy gate applies. |
</threat_model>

<verification>
1. `flutter analyze` returns 0 issues (it exits non-zero on infos - that is intentional).
2. `flutter test` is green, with the totals quoted from real output.
3. `test/components/gw_section_title_rhythm_test.dart` is green, and its `CONTRACT`, `OVERSHOOT`, `COMPUTE` and `TRANSACTIONS` cases are byte-identical to their state before this task. R1 = 12 and R2 = 26 everywhere.
4. `test/components/gw_row_rhythm_test.dart` is green and carries both a BEFORE and an AFTER column of real measured numbers.
5. `assets_header_scheme_a_test.dart` still asserts `kAssetsHeaderCost` = 94.
6. Jakub has walked it on "Sidney" via hot reload.
7. No commits exist. `git log` is unchanged from the start of the task.
</verification>

<success_criteria>
- On a 390pt phone, Assets, Markets and Transactions each render: 8 to the glyph, a 38 glyph, 8 to the text, 8 to the right content edge, and 12 / 1 / 12 around the rule between two rows - MEASURED in painted ink, not derived from source.
- The four numbers exist in exactly one file and every row reads them from there.
- A test goes red if any of them drifts.
- Desktop does not regress: the Transactions row is untouched, the Assets wall was already 8 at every width, and the Markets wall moves 16 -> 8, which brings it into agreement with the Assets panel it sits beside.
- Nothing outside the declared scope changed, and every OUT decision above is written down with its reason.
</success_criteria>

<deliberately_not_done>
Filed as observations for Jakub, not fixed here:

1. **The `dividerTheme` colour bug (F5).** `theme.dart:382` sets
   `dividerTheme.color` to `colorScheme.surfaceContainerHighest`, a FILL colour.
   It reaches four call sites that pass no colour of their own:
   `network_page.dart:130`, `:155`, `:181` (a debug screen) and
   `order_card.dart:79`. `theme.dart:380`'s comment claiming seven affected
   files is stale. This is a colour defect, not a rhythm defect.
2. **The residual desktop wall disagreement.** After this task, at desktop width
   the Transactions row keeps `space6` (12) while Assets and Markets sit at 8.
   `transaction_displays.dart` is frozen by this task's own scope, so it cannot
   be reconciled here. Mobile - the target - is consistent at 8.
3. **`assets_screen.dart:389`'s `space4` spacer** above the `/assets` rows. Now
   yields a 20px kicker-to-row ink gap where it yielded 28. Left alone on
   purpose; it is a device call (see checkpoint step 6).
</deliberately_not_done>

<output>
No SUMMARY file and NO COMMITS. Report results in the session transcript:
the measured BEFORE and AFTER tables, the full-suite totals quoted from real
output, and any number that did not land on the spec with the reason.
</output>
