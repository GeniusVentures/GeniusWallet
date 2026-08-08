# Handoff · 2026-07-29 · Phase 14 planned, charts decided, two header fixes

**Session:** executor, branch `redesign/jakub-260728`, forked from `origin/ui-redesign-port` at
`8ed02e78`. **Nothing is committed** - `CLAUDE.md` forbids it, so the entire session sits in the
working tree. Gates measured by me, not quoted from an agent: `flutter analyze` **0**,
`tool/check_brace_style.sh --count` **0**, `flutter test` **517 pass / 0 fail**.

---

## 1 · Braian's 70 commits, pulled

Phase 22 (hygiene) shipped on `ui-redesign-port`: analyze **408 → 0**, 192 brace-less `if` → 0 with a
gate, **−1,744 LOC** dead code, 9 fake `*.g.dart` widgets renamed, 7 CI quality gates wired, our one
standing test failure deleted. Phase 23 (design system) planned, 6 plans, **not started**.

Two things from his session that bite us: **`CLAUDE.md` held the bare text `AGENTS.md`, not an
import** - project instructions had never loaded, now `@AGENTS.md`. And **golden tests are cancelled
outright, twice**, along with any replacement harness (`integration_test`, `patrol`, Playwright).
Ordinary `flutter test` only.

---

## 2 · Phase 14 (compute) - planned and through the gate

```
design → CONTEXT → RESEARCH → UI-SPEC → PLANNER → plan-checker → [EXECUTE]
   ✓        ✓          ✓          ✓         ✓        ✓ PASS       ← next
```

**8 plans, 4 waves**, dependency graph `01 → {02,03,04,05} → {06,07} → 08`. All eight validate with
**0 errors, 0 warnings**. Plan-checker returned **PASS, no blockers**. Resume with
`/gsd-execute-phase 14`.

Artifacts in `.planning/phases/14-compute-panel-job-flow/`: `14-CONTEXT.md`, `14-RESEARCH.md` (90 KB),
`14-UI-SPEC.md` (56 KB), `14-01..08-PLAN.md`.

### Decisions locked

- **P1 · Twin tiles + F1 · Drawer with vertical steps** (sketches 076/077).
- **`GWCopyRow` promotion APPROVED** - promotion only, no migration of the two existing forks.
  **This reverses Phase 23's refusal**, which declined it at 2 consumers; the bridge-hash row is the
  third. The SUMMARY must record the reversal so the Phase 23 executor meets a decision, not a
  contradiction.
- **GNUS/Minions unit toggle**: the balance tile's existing unit suffix becomes the toggle; the
  200x36 `ToggleButtons` block goes. **Cost is +8px, not 0** - a 12px text cannot be a tap target
  without reaching WCAG 2.5.8's 24x24, and Flutter sizes tap targets in layout. The 8px is expected
  to be available only because the `≈ $` subline is dropped in exactly the tall states.
  **14-08 Task 3 says measure it, do not assume it.**

### Parked - backend logic, one file each in `.planning/todos/pending/`

| Parked | Cost to the phase |
|---|---|
| **Stall detector** - the "161 polls / 40s" figure matches **no shipped timer**; three intervals are conflated (1s processing, 3s init, 250ms trace) and the processing feed has never been traced | State **04 · Stalled is out**. Phase ships **8 of 9 states**. The UI half of the 52.5% fix - deleting the lying ring - still ships |
| **Can `requestGeniusSDKProcess` be re-called after a successful bridge?** Answer lives in native SuperGenius | Terminal state T2 (*bridged, not processed*) ships **informational only, no retry CTA**. `14-UI-SPEC.md:718` specifies that button; the planner deliberately overrode it and the checker confirmed no stray retry survives in any of the 8 plans |

### Numbers that died on re-measurement - do not trust the older docs

- **Budget is 274px, not 276.** `GWDecorations.surface`'s `Border.all(width: 1)` is folded into the
  Container's padding, costing 2px on top of `EdgeInsets.all(space6)`. That 2px was the entire slack.
- **P1 is 284px as specced and does not fit.** Tile padding `vertical: space4` brings the worst state
  to **268px, 6px headroom**. Verified independently by planner and checker.
- **`GWSectionTitle` costs 62px, not 44.**
- **Brand `#0AAEE6` is 2.56:1 on white, not 3.0:1.**
- **Free/blocked states went 6/3 → 4/5 → 5/3.** Research downgraded it; the planner then found
  state 09 · Offline IS free - `wallet_overview.dart:172` already subscribes to
  `SGNUSConnection.isConnected`, in the very file being rewritten.
- **Roadmap pointers:** two of five had drifted, and `genius_balance_display.dart` is under
  `lib/wallets/view/`, **not** `lib/components/`.

### Two hazards with no in-repo precedent

1. **`SubmitJobCubit` is route-scoped; `ResponsiveDrawer` pushes on the ROOT navigator.** A
   drawer-owned cubit dies to a barrier tap mid-flight, recreating the exact unrecoverable-hash bug
   this phase exists to fix. **None of the ~20 existing drawer call sites provides a bloc** - no
   pattern to copy. Plans hoist it and wrap both `child` and `footer`.
2. **`test/freeze_rule_test.dart` bans `AutoSizeText`/`FittedBox`** in `lib/components/cards/`. The
   widgets being rewritten use it and currently sit outside the scanned dirs.

Also: the gas check **already exists and already runs** (`hasEnoughFundsForGas`, `web3.dart:500`,
called from `:390`); its message is swallowed at `submit_job_cubit.dart:148-151` and replaced with a
generic one under a "File Picker Error" title.

---

## 3 · Charts - scheme, colour and rollout all decided

Sketch **078** (`.planning/sketches/078-chart-restyle/`), interactive, JS `node --check` clean.

**Chosen: B · Trading frame.** Right Y axis, horizontal gridlines, time labels, full-height crosshair.

**The line takes the TREND colour - green up, red down.** This reverses an "always green" call taken
earlier the same session. Recorded rather than overwritten because the reversal is the interesting
part: always-green was proposed on the grounds that the % pill already states direction. It was
reversed once the consequence was shown - the Markets sparklines colour by sign **on purpose**, to
mirror the Assets panel (`crypto_simple_chart.dart:53-55`), so an always-green hero chart would have
sat directly above red sparklines reporting the same fact.

### The rollout problem, resolved 2026-07-29 - and the fix changed shape

An earlier version of this handoff said "B fits one surface out of three, three ways out, none
chosen". Superseded. Checking the room turned up the thing that matters more than the answer:
**the dashboard chart does not have *a* height.** `ChartDashboardView` has three call sites under
three height regimes (`dashboard_screen.dart:223`, `:273`, `:303`); only one is the 350 cap the
earlier analysis used. So no per-surface setting can answer "does B fit the dashboard".

| Surface | Plot | Verdict | Action |
|---|---|---|---|
| Coin page, wide 997x530 | 454 | B, free | none |
| Coin page, stacked 876x558 | 482 | B, free | none |
| Markets hero, wide | **180, unchanged** | B, colour only | **73px slack FALSIFIED by measurement** |
| Coin page, mobile 366x260 | 184 | **A, permanently** | none possible |
| Dashboard, 3-column >1536 | **232+** | B, free | none - `minHeight: 380` covers it |
| Dashboard, 1-column | 202 | B after 32px | *don't do this yet* |
| Dashboard, 2-column | **140** | **already broken** | fix the filed floor-height bug |

**The hero was NOT free. My arithmetic was wrong and the measurement caught it.** I derived left = 301
and right = 228, concluding the `Spacer` at `markets_hero_card.dart:168` held 73px of slack.
`test/dashboard/markets_hero_height_test.dart`, pumped at width 1200 so it exercises the wide
`IntrinsicHeight` branch, measured the card at **619.0** with a 180px chart and **692.0** with a 253px
chart - it grew by the **full 73px**. Growing by exactly the chart's delta means the RIGHT column
drives the `IntrinsicHeight`, so there was no slack at any point. The row is 585 tall, not the 301 I
derived, and **the missing 284px is not yet explained** - `IntrinsicHeight` asks for
`getMaxIntrinsicHeight`, which is a different question from laid-out height, and that is where to
look. **Decision: the hero chart stays at 180.** Trend colour and the `borderControl` fix shipped on
it regardless; neither depended on the height claim.

**The dashboard's 2-column layout is already broken and already filed, twice.** The chart is
`(viewport - 324) / 2` with no floor, so at a 900px window the plot is 140 and 32px of reclaim only
reaches 172. In the wild it is far worse: the filed traces have the chart's Column handed **h=6.5**,
throwing *"RenderFlex overflowed by 33 pixels"* at every boot
(`todos/pending/2026-07-21-bitcoin-chart-card-height-dashboard-vertical-budget.md`,
`2026-07-24-dashboard-bitcoin-chart-renderflex-overflow.md`). Both conclude: **the slot is broken,
not the chart**; the fix is a floor height on the dashboard side.

### ★ Recommendation

1. **B on the coin page (wide + stacked) and the Markets hero now.** Free, unblocked, and where
   people actually read a chart.
2. **Make A-versus-B a runtime rule** - the chart reads the box it was handed, B above 220px of plot,
   A below. Already B's own documented reduction. It is the only form of the fix that survives a
   layout with no minimum height.
3. **Do not trim the dashboard's 48px yet.** Polishing padding on a card filing RenderFlex overflows
   at boot is fixing the wrong layer. After the floor lands, rule 2 gives it B for free and the 32px
   only moves the threshold window height from 1060 to 996.

Rejected: a cut-down B on every surface (a second chart language that looks like B but cannot be read
like B), and B on the coin page only (three chart languages in one product, and the failing
`borderStrong` indicator stays).

### Checked, not assumed - what this does not break

- `MarketsHeroCard`: one consumer, `markets_screen.dart:197`, in an uncapped `SingleChildScrollView`.
- `_ChartSectionHeader`: one consumer, `dashboard_screen.dart:555`. Padding is not shared with
  `GWSectionTitle`; restoring `space8` moves it *toward* the shared rhythm.
- No test asserts either number. `compact_price_font_size_test.dart` pins the price block against
  `priceHeight: 28` (unchanged); `coin_page_stat_rail_test.dart` does not touch chart height.
- `freeze_rule_test.dart`'s `AutoSizeText`/`FittedBox` ban covers `lib/components/cards/` - no chart
  file lives there.
- Contrast: gridlines are decoration (1.4.11 does not bind), axis labels are `textSecondary`, already
  AA in both themes. The one contrast *fix* in scope is the touched-spot indicator off `borderStrong`.

### The sketch now shows it rather than tabulating it

078's `index.html` carries four **before/after pairs at 1:1** - dashboard 1-col 202 vs 234, hero 180
vs 253, mobile B-forced vs A, and dashboard 2-col 140 vs A - plus a live per-surface floor check and
the rollout table, recommendation, runner-up and rejected option **in the HTML**. Nine surfaces now,
including `dash2col` and `dash3col`. All 450 scheme x state x surface x theme combinations render
without a throw or a NaN (verified headless in Node against a DOM shim).

## 4 · Two header fixes in the tree

Both in `lib/components/scaffold/gw_page_header.dart`, one shared component, verified by Jakub live.

1. **Trailing content now reaches the right edge.** `Flexible` and `Spacer` both default to `flex: 1`
   and split free space 50/50; a loose `Flexible` whose short title does not spend its half leaves
   the remainder parked at the row's END. Measured shortfall: `trailing.right` 1307 against
   `header.right` 1900. The identity now takes one `Expanded` and `trailing` takes the rest.
2. **Title-to-subtitle gap 19px → 12px.** 15px was the price block sitting INSIDE the title row and
   dragging it to 62px. The remaining 8px is the 48px icon tap targets overhanging a 32px title.
   **Jakub was offered 4px for `height: 32` and kept 48** - the 12px is a paid-for accessibility
   margin, recorded in `token_info_screen.dart`. Do not tidy it away.

Three new tests: `gw_page_header_trailing_flush_test.dart`, `gw_page_header_subtitle_gap_test.dart`.

---

## 5 · Environment notes that cost time

- **Hot reload cannot be driven from this harness.** Three approaches failed: a fifo on stdin
  (`flutter run` only enables key commands when stdin `hasTerminal`), `script -q /dev/null` (macOS
  needs a real tty on its own stdin, gets a socket), and the Dart VM Service `reloadSources` over
  HTTP (returns `success:false` - the incremental compiler belongs to `flutter run`, so the VM has no
  kernel). **A full relaunch is the only option, ~2-3 min.** If fast UI iteration is wanted, Jakub
  runs `flutter run` in his own terminal and presses `r`.
- Never `R`. Hot restart kills the app on the native node's RocksDB lock.
- A stale instance holds the Hive lock - `pkill` before relaunching.

---

## 6 · Open for the next session

1. **Execute Phase 14** - `/gsd-execute-phase 14`. Everything upstream is done and passed.
2. **Chart rollout** - scheme, colour rule and rollout rule are all settled. Ship B on the coin page
   (wide + stacked) and the Markets hero, and make A-versus-B a runtime read of the plot box. The
   dashboard is **not** a padding decision - it is the filed floor-height bug; fix that first.
3. **Commits** - the whole session is uncommitted by policy. Someone has to decide when it lands.
4. **The walk list from 2026-07-28 is still untouched** - the coin page has been rebuilt three times
   and walked once, partly; 15 of 17 drawers have never been looked at.
