---
phase: 15-transactions-tab
plan: 04
subsystem: dashboard/transactions
tags: [filter-rail, page-layout, active-state, wcag-1411, freeze-rule, mutation-testing, hit-testing]
requires:
  - Filters / filterCounts / _menuItem geometry (12-04)
  - _FilterChip's hover language — sketch 008 variant D lift chip (12-04)
  - "_activeLabelShader at file scope (15-03) — consumed, not reimplemented"
  - "scoped.isEmpty control-hiding rule (15-03) — applied to the page presentation"
  - DashboardScrollContainer (dashboard_screen.dart:308)
  - GeniusBreakpoints.medium
provides:
  - "_FilterRail + _RailRow, private to transactions_slim_view.dart"
  - "TransactionsSlimView.page — the flag that selects the two-card page layout"
  - "test/dashboard/transaction_filter_rail_test.dart (11 cases, 16 mutations proven RED)"
  - "_railWidth = 220, with the measured 194px content box behind it"
affects: [15-05 (the /transactions route mounts page: true under GWPageHeader), 15-06 (walk)]
tech-stack:
  added: []
  patterns:
    - "The active mark is the NAVBAR's, copied outright: w700 textPrimary label that is never recoloured + a 2px gradient rule. One mark, one precedent."
    - "A second presentation of the same state is a second WIDGET, not a shared abstraction — the chip and the row disagree on geometry, tap semantics and active mark"
    - "A page below its breakpoint reuses the panel outright rather than growing a third layout"
    - "Every number in a comment is measured; the plan's 196px content box was wrong and is corrected to 194"
key-files:
  created:
    - test/dashboard/transaction_filter_rail_test.dart
  modified:
    - lib/dashboard/home/widgets/transactions_slim_view.dart
decisions:
  - "Active row = sketch 022 B2. Label w700 textPrimary in BOTH states, 2px gradient rule beneath, glyph untouched. No brand-fill, no gradient count, no gradient wash."
  - "The 2px rule is painted through _activeLabelShader, so the rail introduces ZERO new colour decisions and degrades with the menu label in light mode"
  - "The rail does NOT reproduce the chips' tap-the-active-one-to-clear toggle — with an explicit All row it is redundant and reads as a misfire"
  - "The All row absorbs the panel's footer count; _page has no footer, because two live totals on one screen drift apart"
  - "Import cycle to dashboard_screen.dart taken deliberately (ponytail) to keep the phase at zero new files"
  - "HitTestBehavior.opaque was added, then MEASURED as redundant and deleted — RenderDecoratedBox.hitTestSelf already covers the whole row"
metrics:
  duration: ~95 min
  completed: 2026-07-22
requirements: [TT-02, TT-03]
status: complete
---

# Phase 15 Plan 04: The page filter rail Summary

The `⋯` overflow menu, unrolled. On a page wider than 768 the nine filters and a new **All** row
stand permanently beside the list as `_menuItem`'s own rows — 40px, `space6` pad, 14px
`textSecondary` glyph, 13/w500 label, 13px tabular count — in a second card 220px wide. The active
row wears the navbar's active-tab mark and nothing else: **w700 `textPrimary`, never recoloured, a
2px gradient rule beneath the word, glyph identical in both states.**

The dashboard panel did not move a pixel. `transaction_filters_test.dart` passes 45/45 **unedited**
(mtime 12:38, before this session opened), including its six 40×183 bar-geometry assertions.

`transactions_slim_view.dart` 674 → 1064 lines. One new test file, 11 cases.

**No commits created.** `./CLAUDE.md` holds the commit gate; `git diff --cached` is empty.

## What was built

### 1. `_RailRow` — `_menuItem`'s geometry plus B2

Stateful only to own the hover flag, exactly like `_FilterChip`. `Semantics(button, selected)` >
`MouseRegion` > `GestureDetector` > `AnimatedContainer(120ms, height: space20)` >
`Padding(space6)` > `Row[glyph, space4, IntrinsicWidth(label block), Spacer, count]`.

Three things the row deliberately does **not** do, each with the rejected alternative named in
source:

- **The glyph never changes with selection.** Same mark, same `textSecondary`, active or not — the
  rule locked at `_menuItem` and restated by all five variants in sketch 022.
- **The label is never recoloured.** `gw.textPrimary` in both states, weight is the only thing that
  moves. That is the whole difference between B2 and the rejected B, and it is why the rail carries
  no text degradation that has to stay in sync with the underline's.
- **The count is never marked.** `filterCounts()` runs over the unfiltered list on purpose, so a
  gradient numeral would promise a motion that never comes (sketch 022 variant C).

The 2px rule is **always rendered**, transparent when inactive, so every row is the same height and
the rail cannot twitch when selection moves. It is painted through `_activeLabelShader(gw)` — the
function 15-03 hoisted — so the rail adds **zero new colour decisions**. `grep -c
'_activeLabelShader'` is 4: the declaration, the menu label, and the rail's use plus its comment.

`Filters.all` is the one value with no `badgeKind`, so the All row takes `Icons.list_alt_outlined` —
sketch 021 §4's unpicked ledger candidate, and `grep -rn list_alt lib/` confirms it collides with
nothing in the app.

### 2. `_FilterRail` — All, Type ×7, a hairline, Status ×2

`SingleChildScrollView > Column(stretch)`. The scroll view is not decoration; see the measured
scroll threshold below. Group headers take `_header`'s type treatment with different wording —
unrolled, nothing is "more". The divider pins `gw.borderSubtle` rather than inheriting the app-wide
`dividerTheme`, same as the menu's `PopupMenuDivider`.

Tap is `onChanged(f)` plainly. The chips' tap-the-active-one-to-clear toggle is **not** reproduced,
and the divergence is commented at the call site.

### 3. `TransactionsSlimView.page` — one flag, one boolean

`build` now computes `gw`/`scoped`/`txs` exactly as before and returns `widget.page ? _page(…) :
_panel(…)`. `_panel` is today's tree moved verbatim — the `ConstrainedBox(maxWidth: medium)`, the
`compact` bool, 15-03's `scoped.isEmpty ? null :` trailing, `Expanded(_body(…))` and the footer.
Both existing const call sites (`transactions_stream.dart:14`, `sgnus_transactions_screen.dart:48`)
keep compiling untouched.

`_page` derives exactly one value from layout and it is a **boolean**: `wide = maxWidth >= 768`.
Below it, the page **is** the panel — the narrow branch calls `_panel` rather than growing a third
layout. Above it, a `Row(stretch)` of `SizedBox(220) > DashboardScrollContainer > _FilterRail` and
`Expanded > DashboardScrollContainer > _body`, with the rail wrapped in `if (scoped.isNotEmpty)` so
it disappears with the panel's chips on an empty wallet.

No `GWSectionTitle` and no footer in `_page` — the page title is 15-05's `GWPageHeader`, and the All
row absorbed the count.

## Measurements the plan asked for

All taken from the running widget tree, not computed on paper.

| Question | Measured |
|---|---|
| Rail card width | **220.0** (pinned in test 7) |
| Rail content box | **194.0** — see the correction below |
| Row height | **40.0**, all ten rows |
| Rail column height | **477.0** |
| Does the `SingleChildScrollView` ever scroll? | Not at a 900, 700, 600, 520 or **503**px page slot. It engages at **502** (1px) and below. `takeException()` is null at every height down to 400, where it scrolls 103px. |
| Underline raggedness | Label widths **39.75 → 119.25**, a 3× range (`All` 3 chars to `Purchased`/`Computing` 9) |

### Contrast of the rule's stops — recomputed from the tokens, not copied

Formula cross-checked against 15-03's independently-computed `#0AAEE6` on white = **2.56**, exact
match, before any number below was written.

| Appearance | Rule stops | vs card top | vs card bottom | 1.4.11 (3:1) |
|---|---|---|---|---|
| Dark | `#0AD89C` | 9.27 (`#181B24`) | 10.39 (`#0C0E14`) | ✓ |
| Dark | `#0AAEE6` | **6.72** | 7.54 | ✓ (worst case) |
| Light | `#0A6885` ×2 | **6.30** (`#FFFFFF`) | **5.87** (`#F5F7FA`) | ✓ |

And what the **undegraded** gradient would measure in light — i.e. what mutation M6 ships:
`#0AD89C` 1.86 / 1.73, `#0AAEE6` **2.56 / 2.38**. All four under 3:1. This is why the rule goes
through `_activeLabelShader` and not through `GeniusWalletGradient.brandCta`.

**`#14C8FF` was written nowhere** — not in source, not in a test, not above. It is `brandPrimary`,
not a `brandCta` stop.

## Corrections to the plan — facts that did not survive contact with the code

**1. The rail's content box is 194px, not 196.** The plan (and `_railWidth`'s first draft comment)
computed `220 - 2*space6 = 196`. Measured: **194.0**. `DashboardScrollContainer`'s decoration is
`GWDecorations.surface`, which carries a **1px hairline border** as well as its padding
(`genius_wallet_decorations.dart:97-101`), so the real arithmetic is `220 - 2*1 - 2*12`. Test 7
failed on this on its first run — `Expected: <196>  Actual: <194.0>` — which is how it was found.
The comment now carries 194 and the border term, and the test pins it.

The downstream budget, also measured rather than estimated: 194 − 24 row padding − 14 glyph − 8 gap
= **148px for label + count**. The widest labels (`Purchased`, `Computing`) draw **119.25** in the
harness's one-em-per-character fallback font, leaving 28.75 — two digits. A **three**-digit count
beside them overflows by exactly **11px**, verified by pumping 120 purchases. That is a
harness-font ceiling, not necessarily a real one: real Inter is roughly half that advance, and I
have **not** measured it on a device, so the source comment claims only what was measured and names
the upgrade path (widen the literal; never `FittedBox`/`AutoSizeText`).

**2. `grep -c 'IntrinsicWidth' … is 1` does not hold, and cannot.** Measured: **3**. One is the code
(line 991); the other two are the comment explaining why an intrinsic pass is not the `37639d5`
pattern. `grep -n 'IntrinsicWidth' … | grep -cv '//'` is **1**, which is the check the plan meant.
There is exactly one intrinsic pass, on the label block only.

**3. `git diff --stat test/dashboard/transaction_filters_test.dart` is empty for a reason the plan
did not anticipate** — the whole `test/dashboard/` directory is still **untracked**, so that command
is vacuously empty and proves nothing. The evidence used instead is the file's **mtime, 12:38**,
which predates this session, plus a 45/45 pass.

**4. The plan's stated baseline of 187 passing is stale** (15-03 already recorded this). Measured at
the start of this session: **205 / 1**. At the end: **217 / 1**. Reconciliation: +11 mine, +1 from
the concurrent session's `test/freeze_rule_test.dart` (mtime 13:31, written mid-run). The single red
is the pre-existing `test/local_wallet_storage_test.dart` → `Missing definition of 'main' method`;
the file is entirely commented out and fails at load. Untouched, unfixed, not a regression.

## Deviations from plan

**1. [Rule 3 → then reverted] `HitTestBehavior.opaque` was added to the row's `GestureDetector`,
then measured as redundant and deleted.**

The reasoning for adding it was that the row's fill is `Colors.transparent` at rest, so
`deferToChild` would leave the gap between the label and the count dead. It is wrong.
`RenderDecoratedBox.hitTestSelf` delegates to the **decoration's shape** and ignores its colour, so
the `AnimatedContainer` already hit-tests across its full area at any alpha.

Proven, not argued: a `tapAt` in the measured dead zone (x = 220, label ends at 200, count starts
near 282) selects the row **identically with and without** the flag. `_FilterChip` relies on the
same mechanism. Per `./CLAUDE.md` — deletion over addition — the flag is gone; a two-line comment
records the measurement so it is not helpfully re-added.

**2. [Rule 2 — a test that could not fail] Test 2's original form did not detect its own mutation,
and was rebuilt.**

As planned, test 2 read the All row's count once, at rest. But at rest `selectedFilter` is `All`, so
`txs == scoped` and `total: txs.length` is **indistinguishable** from `total: scoped.length` — the
mutation the test exists to catch (M2a) ran GREEN. The test now taps `Mint` (1 of 8) first and then
re-reads All, which separates them; M2a is RED.

The footer half had the same weakness in a different form: `find.text('8 transactions')` is a
negative assertion, so a typo would make it pass forever. It now also pumps the same fixture as a
**panel** and watches `1 transaction` appear — which doubles as the guard that this plan removed the
footer from the page and not from the dashboard.

**3. [Rule 2] Test 4 gained a `ShaderMask` assertion, because the planned one cannot see it.**

The plan says test 4 goes red if the label is wrapped in a `ShaderMask`, "its child would be
`Colors.white`". In dark, `gw.textPrimary` **is** `Colors.white`
(`genius_wallet_colors.dart:133`) — so `expect(style.color, gw.textPrimary)` passes under exactly
that mutation. Built the mutation, ran it, confirmed. Test 4 now also asserts
`find.descendant(of: rail, matching: find.byType(ShaderMask))` is `findsNothing`, which is what
actually catches it (M4b, RED).

**4. [Rule 3] `_host` keys `TransactionsSlimView` on `page`.**

Re-pumping from `page: true` to `page: false` inside one test reused the `State`, so
`selectedFilter` survived the switch and the panel opened on `Mint` — the footer never rendered and
the new assertion failed for the wrong reason. `key: ValueKey(page)` forces a remount. In the app
`page` is fixed per call site, so remounting is the faithful behaviour, not a workaround.

**5. [Record only] The plan's `_menuItem` line references have drifted.** The plan cites `:498-551`
for `_menuItem`, `:564-635` for `_FilterChip` and `:525` for the glyph rule; after 15-01…15-03 and
this plan they are at `:637`, `:711` and `:661`. Every comment I wrote names constructs, not line
numbers, so they cannot drift again. The navbar mark the rail copies is at
`responsive_overlay.dart:301-368` and was read before building — verified as `IntrinsicWidth` +
`AnimatedContainer(height: 3, gradient: isSelected ? brandCta : null)` with the label at
`gw.textPrimary` and no gradient on it. The rail is the same mark at height 2.

**6. [Deliberate omission] `STATE.md`, `ROADMAP.md` and `REQUIREMENTS.md` not written.** Both are
modified in the working tree by the concurrent session and the brief forbids touching them. What I
would have written:

- `STATE.md` — Current Plan → 15-05; session Stopped At → `Completed 15-04-PLAN.md`; decision
  entries for the four in this summary's frontmatter; no new blockers.
- `ROADMAP.md` — phase 15 progress row 3/6 → 4/6 plans complete.
- `REQUIREMENTS.md` — mark **TT-02** and **TT-03** complete.

## Mutation matrix — every assertion proven RED

Run serially against the finished tree, one mutation at a time, each reverted before the next.

| # | Mutation | Result |
|---|---|---|
| M1 | rail drops `Filters.overflowTypes` | **RED** — test 1 (+ 7, 8 collaterally) |
| M1b | rail drops the Status group | **RED** — test 1 (+ 7) |
| M2a | `total: txs.length` (All count on the filtered list) | **RED** — test 2 |
| M3 | `counts: filterCounts(txs)` on the PAGE | **RED** — test 3 |
| M4 | active label tinted `brandPrimaryOnSurface` (variant B) | **RED** — test 4 |
| M4b | label wrapped in a `ShaderMask` (`srcIn`, white child) | **RED** — test 4 |
| M5 | glyph tinted `textPrimary` when active | **RED** — test 5 |
| M6 | rule painted with `brandCta` unconditionally | **RED — light only**, dark green (6.72 ≥ 3, 2.38 < 3) |
| M6b | rule rendered only when active | **RED** — test 6, both appearances |
| M7a | row height `space20` → 44 | **RED** — tests 7, 8 |
| M7b | `_railWidth` 220 → 200 | **RED** — all ten |
| M8 | `lifted = _hovered` (drops `&& !active`) | **RED** — test 8 |
| M9 | `scoped.isNotEmpty` guard dropped | **RED** — test 9 |
| M10a | `wide` removed, rail always | **RED** — test 10 |
| M10b | `>=` → `>` (off-by-one at the breakpoint) | **RED** — test 10, at 768 |
| MX | `HitTestBehavior.opaque` removed | **GREEN — and that is the finding.** See deviation 1; the flag was deleted. |

M6 is the one that matters: it reddens the **light** iteration only, which is direct evidence the
appearance flag is genuinely flipped and the light arm genuinely executed. Under the old
`GWColors.light()`-only pattern both iterations would have taken the dark arm and M6 would have
survived.

**A note on batch mutation runs.** A first pass that applied all mutations back-to-back reported
M2a, M3, M8 and MX as survivors. M3 and M8 were **false** survivors: re-run individually with a
sleep between, both are unambiguously RED. Rapid successive `flutter test` invocations against a
file rewritten seconds apart appear to hit a stale compilation. **Every row above is from a serial
run with a 1s gap, and the four survivors were each re-run alone.** Anyone repeating this should not
trust a tight mutation loop.

## Verification actually run

| Check | Result |
|---|---|
| `flutter analyze lib/dashboard/home/widgets lib/dashboard/home/view test/dashboard` | **No issues found!** |
| `flutter test test/dashboard/transaction_filter_rail_test.dart` | **11 passed** (10 tests, test 6 ×2 appearances) |
| `flutter test test/dashboard/transaction_filters_test.dart` | **45 passed**, file unedited (mtime 12:38) |
| `flutter test` (full suite) | **217 passed / 1 failed** — the pre-existing load failure |
| `flutter test test/freeze_rule_test.dart` | **1 passed** — the concurrent session's scanner covers `lib/dashboard/`, and the rail introduces no banned widget |
| `flutter test test/theme/` | green after this file runs — no appearance-flag leak |
| `grep -n 'IntrinsicWidth' \| grep -cv '//'` | **1** |
| `grep -c '_activeLabelShader'` | **4** (declaration, menu label, rail use, rail comment) |
| Mutation matrix (16 mutations) | table above |
| `git diff --cached` | **empty** — nothing staged, no commit |

### Freeze rule (`37639d5`) — held

The page derives exactly one value from constraints and it is the `wide` **boolean**. Every
dimension in the rail is a literal or a 4-pt token: 220, 40, 14, 13, 2, `space6` 12, `space4` 8,
`space2` 4. No `AutoSizeText`, no `FittedBox(scaleDown)`, no `textScalerOf(...).scale(...)`.
`IntrinsicWidth` is used once, on the label block, and is a layout-only intrinsic pass over a
two-child subtree that derives no font size or scale from the incoming constraints — the same
construct the navbar's own underline uses. The concurrent session's `freeze_rule_test.dart`, which
scans `lib/dashboard/`, passes.

## What was NOT verified

**Nothing was rendered on a screen.** The app was not launched. The widget tests perform real layout
and paint in both appearances, but headlessly, in a fallback font that is roughly twice Inter's
advance. What 15-06's walk still has to judge:

1. **Whether the ragged underline reads as deliberate.** This is B2's known cost and it is now
   quantified: the mark spans **39.75 → 119.25** in the harness, a 3× range driven purely by
   character count (`All` 3, `Purchased` 9). Real Inter narrows the absolute widths but not the
   ratio. Whether a rail whose active mark is three times longer on one row than another reads as
   content-tracking or as sloppy is a judgement no assertion here makes.
2. **Whether the 2px rule is loud enough** in a permanent rail read from peripheral vision (T-15-11).
   The tests pin that both marks exist; only eyes can say whether two are enough.
3. **The light-mode rule**, which a machine has now painted at 6.30:1 but no human has seen.
4. **Whether the rail scrolls in practice.** It does not down to a **503px** page slot, and the
   `/transactions` route under `GWPageHeader` should be well above that on any laptop — but the
   threshold is a measurement of the harness's header text height, so confirm on a real short window.
5. **`Icons.list_alt_outlined` at 14px** as the All row's glyph, beside nine badge marks it was never
   designed to sit with.

## Compliance

- **No commits created.** Nothing staged, nothing added. `./CLAUDE.md` holds the gate.
- No `git add -A`, no `git add .`, no `git commit -a`, no `git clean`, no `git stash`.
- No `dart format` run on any file — the repo predates Dart 3.11 tall style and 15-02 already paid
  for that mistake. Both edited files were written in the repo's existing style by hand.
- Shared-tree files left alone: `lib/screens/boot_sequence.dart`, `tool/boot_sequence_check.dart`,
  `test/boot_sequence_test.dart`, `.planning/phases/13-*`, `.planning/phases/14-*`,
  `.planning/sketches/015-018`, `.planning/spikes/`, `cmake/*.cmake`. `.planning/STATE.md` and
  `.planning/ROADMAP.md` not written — see deviation 6.
- Exactly two files touched: `lib/dashboard/home/widgets/transactions_slim_view.dart` (modified) and
  `test/dashboard/transaction_filter_rail_test.dart` (created). Zero new source files.
- The dashboard panel keeps its chips and its `⋯` menu; the rail is page-only. No shared "chip or
  row" abstraction was factored out — the two disagree on geometry, tap semantics and active mark.
- No colour hex was copied from a sketch mockup. Every colour is read from `lib/theme/`, and the
  rail's only gradient comes from `_activeLabelShader`.
- No new dependency, no new abstraction beyond the two widgets the plan asked for.
- **Tree state:** branch `ui-redesign-port` at `ea33561`; all edits uncommitted in the working tree.
  Several files listed by `git status` (`lib/main.dart`, `lib/hive/init.dart`, the chart files, …)
  are the concurrent session's, not this plan's.

## Self-Check: PASSED

- `lib/dashboard/home/widgets/transactions_slim_view.dart` — FOUND (1064 lines, modified, analyzes clean)
- `test/dashboard/transaction_filter_rail_test.dart` — FOUND (515 lines, new, 11/11 pass)
- `.planning/phases/15-transactions-tab/15-04-SUMMARY.md` — FOUND
- Scratch files created for measurement (`zz_rail_measure_scratch_test.dart`,
  `zz_diag_scratch_test.dart`, `zz_hit_scratch_test.dart`, `zz_scroll_scratch_test.dart`) —
  **all deleted**; `ls test/dashboard/` confirms five files, none of them scratch.
- Commits: **none, by design.** Staging area empty.
