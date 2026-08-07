---
phase: quick-260806-wys
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - test/components/gw_section_title_rhythm_test.dart
  - lib/components/cards/gw_section_title.dart
  - lib/components/coins/view/coins_screen.dart
  - lib/dashboard/chart/dashboard_markets.dart
  - lib/dashboard/chart/markets_screen.dart
  - lib/dashboard/compute/compute_panel.dart
  - lib/dashboard/home/widgets/transactions_slim_view.dart
  - lib/dashboard/news/view/crypto_news_screen.dart
  - lib/dashboard/home/view/dashboard_screen.dart
  - test/dashboard/compute_panel_height_test.dart
autonomous: false
requirements: [260806-wys]

must_haves:
  truths:
    - "In every panel that mounts GWSectionTitle, the gap from the box's inner top edge to the title equals that same panel's gap from the title to the first PAINTED pixel of its content, within 1px."
    - "The box-to-title gap is unchanged from what ships today in every panel - the title-to-content side is the only side that moved (Jakub, 2026-08-06)."
    - "The measurement is taken to the first painted pixel, not to the first row's layout box, because every dashboard row is a ListTile that snaps to a default tile height and centres its content inside it."
    - "GWSectionTitle's doc comment no longer claims a property the widget does not have; the same false claim is corrected in compute_panel.dart and transactions_slim_view.dart, which both repeat it as a derived number."
    - "The Compute panel's 'New processing job' CTA is still fully visible without scrolling inside its 340px slot, confirmed on device, not only by the height test."
    - "flutter analyze reports 0 issues and the suite is green at 1018+ passing."
  artifacts:
    - test/components/gw_section_title_rhythm_test.dart
  key_links:
    - "GWSectionTitle's bottom padding + the first content's own top inset is ONE number the eye reads as a single gap; today only the first half is declared anywhere and the second half is invisible."
    - "kDashboardPanelSlotHeight (340) and compute_panel_height_test.dart's derived 314 both descend from this exact geometry - if the rhythm changes the Compute panel's height, both must move together or the test asserts against a slot the layout no longer uses."
    - "ComputePanel lives in a SingleChildScrollView, so blowing the budget throws nothing - the CTA silently drops below the fold. The height test is the only alarm."
---

<objective>
Make the vertical rhythm inside every dashboard panel symmetric around its
section title: box top edge -> title, then title -> first content, the same
distance on both sides. Keep the top gap exactly where it is and move only the
bottom side to meet it.

Purpose: Jakub read the panels side by side on his iPhone (2026-08-06) and the
titles do not sit in a consistent rhythm. The component that was introduced
specifically to guarantee this rhythm asserts in its own doc comment that it
already delivers it - so either the widget is wrong or the comment is, and both
outcomes are worth fixing.

Output: a measured table of the real gaps for all eight call sites, a corrected
GWSectionTitle contract, three corrected doc comments, one component-level test
that pins the invariant, and an on-device confirmation.
</objective>

<the_mechanism_this_plan_is_about>

## Read this before Task 1 or the measurement will repeat the bug it is measuring

Two separate places in the codebase state the title-to-first-content distance as
a derived number. Both derive it the same way, and both derivations are
incomplete in the same way.

`transactions_slim_view.dart:472-478`:

> "Assets and Markets put GWSectionTitle's space8 bottom gap above a GWTokenRow
> that carries its own space4 vertical padding, so their title->first-content
> distance is 24."

`gw_section_title.dart:15-19`:

> "It also RESERVES a shared header min-height (~44 ...) so all four panels
> read at ONE geometry: an identical title->panel-top padding AND title->first-row
> gap."

**What both omit:** the first row in Assets (`CoinCardRow`) and in Markets
(`CryptoSparkLineChart`) is a `ListTile`, and a `ListTile` does not size to its
content. It snaps to a default tile height - 72 for a two-line tile with a
leading widget - and then centres the content inside that height. `CoinCardRow`
declares `contentPadding: symmetric(vertical: 4)`; `CryptoSparkLineChart`
declares no vertical contentPadding at all. Neither declares the centring slack,
because neither can see it. The slack is real, unpadded whitespace sitting
directly under the title, and it is what the eye reads as the gap.

So `space8 + space4 = 24` is a **belief about layout, not a measurement of it**,
and it is the belief this plan exists to replace. The Transactions panel then
paid a real `space4` on its day label to match that number - meaning one panel
was tuned to a figure the panel it was matching never actually had.

**The second thing neither comment can know:** the box's own top inset is not
constant across hosts either.

| Host | Top inset above GWSectionTitle |
| --- | --- |
| `DashboardScrollContainer` | `space6` (12) **+ 1px border fold** = 13 |
| `markets_screen.dart:213` | page padding `space6`, plus `space12` after a hero card when one renders |
| `crypto_news_screen.dart:358/375` | a `space12` SizedBox spacer immediately above the title |
| `crypto_news_screen.dart:498` (`_NextUp`) | whatever the column above it leaves |

The border fold is not a rounding detail: `Container` merges `padding` with
`decoration.padding` via `_paddingIncludingDecoration`, so
`DashboardScrollContainer`'s content box starts 13px in, not 12.
`compute_panel_height_test.dart`'s own doc comment derives this at length and
`transaction_filter_rail_test.dart` confirms it independently at a different
card size. Use 13.

**Therefore:** a single fixed bottom padding inside GWSectionTitle CANNOT produce
Jakub's rule everywhere, because the rule is per-section (`kazda z sekcji`) and
both terms it has to balance - the host's top inset and the content's own top
inset - vary per section. Any fix that changes one constant and declares victory
is wrong. That is the finding Task 2 has to design around.

</the_mechanism_this_plan_is_about>

<the_invariant>

## Stated precisely, so it can be asserted rather than eyeballed

For each panel P that mounts a `GWSectionTitle`:

```
R1(P) = titleLineBox.top   - boxContentTop(P)      // box -> title
R2(P) = firstPaintedTop(P) - titleLineBox.bottom   // title -> content
```

**Rule: `R2(P) == R1(P)` within 1px, with `R1(P)` frozen at its currently
shipping value.** Jakub's instruction is explicit - "zachowaj padding ktory jest
uzyty box vs title" - so R1 is an input to this task, never an output.

Three definitions that decide whether the measurement is honest:

1. **`boxContentTop`** is the box's INNER top edge - `getRect(box).top` plus the
   1px border where the host is `DashboardScrollContainer`. For hosts that are
   not a bordered card (news, markets page), it is the top of the space the
   section owns, i.e. the bottom of the spacer immediately above the title.

2. **`titleLineBox`** is `tester.getRect(find.text('<title>'))` - the rendered
   paragraph, 24px tall for `titleLg` (fontSize 18, height 24/18 - read from
   `genius_wallet_typography.dart:95-96`, not assumed). Use the LINE BOX on both
   sides, not glyph extents. Reason to record in the test: for Inter at 18/24 the
   cap-top inset and the baseline inset inside the line box differ by well under
   a pixel, so line-box symmetry tracks optical symmetry - and unlike glyph
   extents it does not change when a title happens to contain a descender
   ("Compute", "Next up") and is expressible on the spacing grid.

3. **`firstPaintedTop`** is the topmost painted pixel of the first content
   widget, NOT `getRect(firstRow).top`. This is the whole point. Walk the first
   content subtree and take the minimum global `dy` over render objects that
   actually paint - `Text`, `Image`, `Icon`, `DecoratedBox`/`Container` with a
   visible decoration - via:

   ```
   final RenderBox rb = element.renderObject as RenderBox;
   final double top = rb.localToGlobal(Offset.zero).dy;
   ```

   Use the render object directly. Do not round-trip through `find.byWidget`,
   which is not identity-stable when rows repeat.

</the_invariant>

<execution_context>
@$HOME/.claude/gsd-core/workflows/execute-plan.md
</execution_context>

<context>
@lib/components/cards/gw_section_title.dart
@lib/theme/genius_wallet_consts.dart
@test/dashboard/compute_panel_height_test.dart
</context>

<tasks>

<task type="auto">
  <name>Task 1: Measure all eight call sites and write the numbers down</name>
  <files>test/components/gw_section_title_rhythm_test.dart</files>
  <action>
Create a measurement harness FIRST, with no production edits in this task. It
starts life printing a table and ends life (Task 3) asserting the invariant, so
write it as a real test file, not a scratch script.

Implement the three helpers from `<the_invariant>` above: `boxContentTop`,
`titleLineBox`, `firstPaintedTop`. Put `firstPaintedTop` behind a named helper
with a comment recording WHY it does not use the row's layout box - a future
reader who "simplifies" it back to `getRect(row).top` reintroduces exactly the
error this task exists to correct.

Pump and measure every site that mounts the component. Take them in cost order
and do not fight a harness that does not exist:

  - `ComputePanel` - pure fixture, no bloc, no network. Mount it exactly as
    `test/dashboard/compute_panel_height_test.dart` does (real
    `DashboardScrollContainer`, `_kRealisticPanelWidth` 320) and reuse that
    file's `_viewFor` shape. Measure at least `ComputeState.processing` and the
    no-wallet state, since `_BalanceTile` changes form between them.
  - `TransactionsSlimView` - a harness already exists; mirror whatever
    `test/dashboard/transaction_filters_test.dart` and
    `transactions_page_frame_test.dart` do to get a populated panel. Measure the
    dashboard PANEL branch (`page: false`), and note that its first content is a
    day-label `GWKicker` inside a `Padding`, not a row.
  - `GWSectionTitle` mounted directly in a `DashboardScrollContainer` above a
    zero-inset probe (a `SizedBox` with a `ColoredBox`, extracted as a small
    StatelessWidget - AGENTS.md forbids `_buildFoo()` returning a Widget). This
    is the component's OWN baseline: it isolates R1 and R2 with C held at zero.

  - Assets (`coins_screen.dart`), Markets panel (`dashboard_markets.dart`),
    All Markets (`markets_screen.dart`), and the three news sites: these need a
    bloc or a network future. Do NOT build new fixtures for them in this task.
    Instead, derive their content inset the cheap way: measure `CoinCardRow` and
    `CryptoSparkLineChart` STANDALONE - mount one of each at 320px wide with
    fixed inputs and record `firstPaintedTop(row) - getRect(row).top`. That
    single number is the row's own top inset C, and R2 for those panels is then
    `GWSectionTitle`'s bottom padding + C. Record the arithmetic explicitly.

Print, then transcribe into the file's doc comment, a table with one row per
site: host, R1, GWSectionTitle bottom pad, content inset C, R2, and
`R2 - R1`. State each number's arithmetic. The table belongs in the doc comment
of the test that enforces it, so it cannot drift away from the assertion.

Then answer, in that same doc comment, the question this task was really asked:
**is `gw_section_title.dart:15-19`'s claim true, false, or once-true?** Judge it
against the measured table, and say which of the two terms (host inset, content
inset) breaks it. Do not soften the verdict - a comment asserting a property the
widget lacks is worse than no comment, because it stops the next reader from
checking.

Finally, record the DIRECTION for each panel, because it decides Task 3's risk:
`R2 > R1` means the bottom is too airy and shrinking it FREES height budget;
`R2 < R1` means the bottom is too tight and growing it EATS budget. Expect
different directions in different panels - Compute (C=0) and Assets (C dominated
by ListTile's 72px snap) are the two ends of the spread.
  </action>
  <verify>
    <automated>flutter test test/components/gw_section_title_rhythm_test.dart</automated>
  </verify>
  <done>The test file exists and passes (measure-only, no invariant assertion yet). Its doc comment carries a per-site table with stated arithmetic, an explicit true/false/once-true verdict on the GWSectionTitle doc claim, and a per-panel direction. No production file changed in this task.</done>
</task>

<task type="auto">
  <name>Task 2: Make the bottom gap equal the top gap, holding the top gap fixed</name>
  <files>lib/components/cards/gw_section_title.dart, lib/components/coins/view/coins_screen.dart, lib/dashboard/chart/dashboard_markets.dart, lib/dashboard/chart/markets_screen.dart, lib/dashboard/compute/compute_panel.dart, lib/dashboard/home/widgets/transactions_slim_view.dart, lib/dashboard/news/view/crypto_news_screen.dart</files>
  <action>
Apply the correction using Task 1's table. R1 does not move in any panel.

**Choose the mechanism, and state the reasoning in the code.** The two candidates,
with the recommendation:

  - RECOMMENDED - keep the rule in the shared component, but stop making it
    guess. `GWSectionTitle` currently hardcodes a `space8` bottom pad that is
    only correct when the content below it has zero top inset. Give it an
    explicit, tokened declaration of the content's own top inset (for example a
    `contentTopInset` parameter defaulting to zero) and have the component
    subtract that from its own bottom pad, so the RENDERED gap is one number
    owned in one place. Each call site then declares a fact about its content
    rather than carrying a hand-tuned magic spacer. This keeps a single
    definition of the rhythm, keeps the invariant testable at the component
    level, and makes the ListTile centring slack visible in source for the first
    time.

  - REJECTED unless the table forces it - per-call-site spacers. Eight
    independently tuned numbers is the arrangement that produced the current
    drift, and it is why one panel is currently tuned to another panel's
    imaginary 24px.

  - ALSO REJECTED - normalising the rows themselves (forcing ListTile heights,
    or replacing them). That changes row-to-row rhythm, divider spacing and
    touch-target heights across three panels, which is a much larger visual
    change than Jakub asked for and is not reversible in one edit.

If a panel's host inset genuinely differs (news sites sit under a `space12`
spacer, All Markets sits under a hero card), the fix is per-host: that section's
R2 matches THAT section's R1. Do not average them into one global number - the
rule is per section.

**Grid discipline.** Every value written must be an existing token from
`genius_wallet_consts.dart` (`space2` 4, `space3` 6, `space4` 8, `space6` 12,
`space8` 16, `space10` 20, `space12` 24). `space3` = 6 is the ONE documented
half-step. If the measured table demands a value that is not on the grid, STOP
and surface it as a decision with the arithmetic attached - an untokened literal
is a design decision needing a stated reason, not a tweak. The existing top `2`
literal in GWSectionTitle is already such an exception and it is inherited, not
introduced: leave it alone (it is part of R1, which is frozen).

Dark mode / mobile is the target. Do not chase anything light-mode-only.
Do not touch `/banxa` or `/squidrouter`.
  </action>
  <verify>
    <automated>flutter analyze 2>&1 | tail -3 && flutter test test/components/gw_section_title_rhythm_test.dart test/dashboard/compute_panel_height_test.dart</automated>
  </verify>
  <done>Every measured site has R2 == R1 within 1px with R1 unchanged from its Task 1 value. All spacing values are existing tokens, or an off-grid value carries a written justification. flutter analyze is at 0 issues.</done>
</task>

<task type="auto">
  <name>Task 3: Correct the false comments, pin the invariant, reconcile the height budget</name>
  <files>test/components/gw_section_title_rhythm_test.dart, lib/components/cards/gw_section_title.dart, lib/dashboard/compute/compute_panel.dart, lib/dashboard/home/widgets/transactions_slim_view.dart, lib/dashboard/home/view/dashboard_screen.dart, test/dashboard/compute_panel_height_test.dart</files>
  <action>
**3a - turn the harness into a guard.** Promote Task 1's measurements to
assertions: for each site it can mount, assert `R2 == R1` within 1px. Keep the
measured table in the doc comment - the assertion says WHAT, the table says why
that number and not another. Include the component-level baseline case (zero-inset
probe), which is the one that pins the contract for the five panels no test can
mount.

**3b - correct the three comments that assert the old belief.** All three are now
false or stale:

  - `gw_section_title.dart:15-19` - the "identical title->panel-top padding AND
    title->first-row gap" claim. Replace with what the component actually
    guarantees after Task 2, and name the two terms it depends on (host inset,
    content inset) so the next reader knows the claim is conditional.
  - `transactions_slim_view.dart:472-478` - the "so their title->first-content
    distance is 24" derivation. It cites `GWTokenRow`; Assets actually renders
    `CoinCardRow` and Markets renders `CryptoSparkLineChart`, so the reference is
    wrong as well as the arithmetic. Correct both, and re-derive the day-label's
    own `space4` against the real number - if that first-header padding is now
    double-counting, remove it rather than leaving it.
  - `compute_panel.dart:112-119` - "the component reserves a 44px header and owns
    its `space8` bottom gap" and "the 38px it costs is why kDashboardPanelSlotHeight
    went 300 -> 340". Update the gap figure if Task 2 changed it, and update the
    38px only if you re-measure it; do not restate a number you did not check.

**3c - reconcile the budget, in whichever direction Task 1 found.**
`kDashboardPanelSlotHeight` = 340 (`dashboard_screen.dart:53`) and
`compute_panel_height_test.dart` derives `340 - 2*(space6 + 1) = 314` from it.

  - If Compute's panel height GREW and the 314 assertion fails: raise
    `kDashboardPanelSlotHeight` by the measured delta and update that test file's
    doc comment honestly - it currently narrates the 300 -> 340 move and must
    narrate this one too, with the new arithmetic. Do not relax the assertion to
    make it pass.
  - If Compute's panel height SHRANK: the test still passes. Record the freed
    headroom in the test's doc comment but do NOT lower the slot in this task -
    the slot is shared with three other panels and lowering it is a separate
    visual decision Jakub has not been asked about.

**Why this matters more than the assertion suggests:** `ComputePanel` is mounted
inside a `SingleChildScrollView`, so exceeding the budget throws NOTHING. The
panel silently becomes scrollable and the "New processing job" CTA drops below
the fold with no error anywhere. The height test is the only alarm in the
system, which is why it must be repaired rather than accommodated.
  </action>
  <verify>
    <automated>flutter analyze 2>&1 | tail -3 && flutter test 2>&1 | tail -5</automated>
  </verify>
  <done>flutter analyze reports 0 issues; the full suite is green at 1018+ passing with the new rhythm test included. No comment in the three named files still asserts a gap figure that the measured table contradicts. If the slot moved, both dashboard_screen.dart:53 and the test's derivation comment moved together.</done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <name>Task 4: Confirm the rhythm on Jakub's iPhone</name>
  <action>Blocking human verification - see how-to-verify. Do not mark this plan complete on green tests alone.</action>
  <what-built>
GWSectionTitle's bottom gap now matches each panel's own box-to-title gap,
measured to the first painted pixel rather than to the row's layout box. The
box-to-title gap is unchanged everywhere.
  </what-built>
  <how-to-verify>
A change earlier in this session passed `flutter analyze` and all 1018 tests
while leaving the app unusable on device. Tests do not close this task - eyes do.
Five of the eight call sites have no test harness at all and are covered ONLY by
this step.

1. Hot reload onto Jakub's iPhone:
   `echo r > /private/tmp/claude-501/-Users-jakub-Desktop-GeniusAI-GeniusWallet/ace46b7b-2b07-4939-8473-925d73aaa236/scratchpad/gw.fifo`
   If new parameters were added to GWSectionTitle in Task 2, hot reload may not
   pick up the constructor change - do a full relaunch rather than trusting a
   reload that silently kept the old widget.
2. Dashboard: check Assets, Markets, Transactions and Compute. For each, the
   space above the title and the space below it should read as the same gap.
   Compare panels against each other too - that side-by-side inconsistency is
   what Jakub actually reported.
3. Compute panel specifically: confirm "New processing job" is fully visible
   WITHOUT scrolling the panel. If you can drag the panel's contents, the budget
   regressed and Task 3c was resolved in the wrong direction.
4. Markets page ("All Markets") and the News tab ("More news", "Next up", and
   "Results" via the search box) - these five have no test coverage and are the
   real reason this checkpoint is blocking.
5. Dark mode only. Ignore anything light-mode-specific.
  </how-to-verify>
  <resume-signal>Type "approved", or name the panel that still reads wrong and whether its gap is too tight or too airy</resume-signal>
</task>

</tasks>

<threat_model>
No trust boundary is crossed: this task changes vertical padding constants and
doc comments in local UI widgets. No network input, no persistence, no
credential handling, and no package-manager installs - so no legitimacy gate
applies. The one real risk is availability of a UI affordance, tracked above as
the Compute CTA dropping below the fold, and it is covered by the height test
plus the blocking on-device check.
</threat_model>

<verification>
- `flutter analyze` - 0 issues (baseline must hold).
- `flutter test` - 1018+ passing (baseline must hold; the new rhythm test adds to it).
- `flutter test test/dashboard/compute_panel_height_test.dart` - all states within budget.
- On-device dark-mode walk of all eight call sites (blocking checkpoint above).
</verification>

<success_criteria>
- Every panel's title-to-content gap equals that panel's box-to-title gap within 1px.
- No panel's box-to-title gap changed.
- The gap is measured to the first painted pixel, and the test says why in a comment.
- The three stale/false comments are corrected, not merely edited around.
- The slot constant and its test agree with each other and with the measured layout.
- Jakub confirms the rhythm on the phone.
</success_criteria>

<output>
No commits in this task - plan and execute only, per the request. Report the
measured table and the doc-comment verdict in the completion message.
</output>
