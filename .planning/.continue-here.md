# Continue here · paused 2026-07-29

**Branch:** `redesign/jakub-260728`, forked from `origin/ui-redesign-port` at `8ed02e78`.
**PR target:** `ui-redesign-port`. **Never `main`** - the session header lies about the default branch
in this repo.

**Why commits exist despite `CLAUDE.md:23` ("Do not create commits").** Jakub overrode that rule
directly on 2026-07-29 - *"lets do the commits as always and create a PR on the ui redesign port so
Braian can take it from there."* That is the authorisation for both the commits and the PR. Nothing
before that point in the session was committed, which is why one pause produces a very large diff.

---

## Where this stopped

**Committed and pushed. PR #218 is open against `ui-redesign-port`.**
Five commits on `redesign/jakub-260728`, forked at `8ed02e78`.

Gates re-measured by the orchestrator, not quoted from agents: `flutter analyze` **0** ·
`check_brace_style --count` **0** · `flutter test` **676 pass / 0 fail**, excluding `test/account/`.
Baseline was 517, so this branch adds 159 tests.

Waves 1-3 all landed. **Plan `14-08`, the wiring plan, was never executed** - `ComputePanel` is built
and tested but is not connected to the dashboard, so merging does not put it on screen. That is the
single biggest piece of unfinished work.

## The one unresolved defect - DIAGNOSED, and it is not what I first said

`test/account/account_drawer_show_test.dart` **hangs forever with zero output**. I guessed twice and
was wrong twice - first "the test is broken or the toolchain is contended", then "I measured it while
the tree did not compile". Both fell over: it still hung on a clean tree, alone, past 400 seconds.

**The real cause, bisected.** The import graph is fine - a test that only imports
`account_drawer.dart` loads and passes in under a second. **Real Hive I/O inside a `testWidgets` body
is the hang**, because `flutter_test`'s FakeAsync zone never resolves real filesystem awaits. The
discriminator: `test/dashboard/transaction_row_test.dart:160-176` uses a near-identical Hive
setUp/tearDown under a plain `test()` and has passed for months.

The fix is `tester.runAsync()` around every real I/O call - `createTemp`, `openBox`,
`deleteBoxFromDisk` AND `close`. Full writeup in
`.planning/todos/pending/2026-07-29-real-hive-io-inside-testwidgets-hangs-forever.md`.

**The test is deliberately left uncommitted**, untracked in the working tree, so it cannot hang
Braian's CI. `lib/account/` shipped without it, which means **plan 14-04's extraction has no test of
its own**. Stated plainly rather than papered over. 14-04 also never produced a SUMMARY.

Three bisection probes written by the stalled `14-04` agent are preserved OUT of `test/` at
`<scratchpad>/14-04-probes/` (`zzz_drawer_probe`, `zzz_hive_probe2`, `zzz_hive_probe3`). The method
was right - isolate drawer vs `Hive.put` vs `setUp`/`tearDown` across tests - it just never reached a
conclusion. **They must not go back into `test/`.**

---

## Phase 14 · compute panel and job flow

```
01 ✓ → {02 ✓, 03 ✓, 04 ⚠, 05 ✓} → {06 ⏳, 07 ⏳} → 08 ⏸
```

- **`14-01`** `resolveComputeState`, pure Dart, **0 Flutter imports** (verified by grep, not quoted).
  18/18 tests. Resolved six design questions and flagged them for 02-08 to confirm or override.
- **`14-02`** moved the node's truth out of a private widget State into `AppBloc`. The catch at
  `app_bloc.dart:192-195` no longer kills the poll timer permanently. A dead feed is now
  distinguishable from a healthy idle node.
- **`14-03`** `GWStatusDot` + `GWCopyRow`. **The `GWCopyRow` promotion reverses Phase 23's refusal**,
  and the reason is recorded in the class doc comment citing `23-05-PLAN.md:155-166` - so the Phase 23
  executor meets a decision, not a contradiction.
- **`14-04`** ⚠ code on disk (`account_drawer.dart` new, `account_dropdown_selector.dart` modified),
  **no SUMMARY, gates never measured**. Its agent stalled twice on the same pattern: backgrounding a
  test run and ending its turn waiting for a notification nobody was waiting for. Finish it by hand.
- **`14-05`** the reason this phase exists: **the burned bridge hash is no longer dropped**. Also the
  gas-shortfall message now passes through instead of being replaced by a generic string under a
  "File Picker Error" title, one error field became three channels, a 5 MB cap landed, and the CTA
  ladder's `<` → `<=` off-by-one is fixed. 35/35.
- **`14-06`/`14-07`** see above.
- **`14-08`** blocked on 04, 06, 07.

**Parked, one todo file each, both backend:** the stall detector (state `04 · Stalled` is out, phase
ships 8 of 9 states) and whether `requestGeniusSDKProcess` can be re-called after a successful bridge
(so terminal state T2 ships informational, **no retry CTA**, deliberately overriding
`14-UI-SPEC.md:718`).

### I added one thing by hand

`lib/dev/dev_tools_bubble.dart` - two MOCK buttons (`SGNUS init`, `Feed dead`) that `14-02` could not
add because the file was outside its fence. Without them the two states it made representable are
unreachable on a walk. I also extended the shared `Clear` button, which released only
`processingOverride` and would otherwise have left the node stuck. Needs
`--dart-define=GW_DEV_TOOLS=true` on **every** `flutter run`.

---

## Charts · sketch 078, quick task `260729-gt4`

Tasks 1-4 landed. **Task 5 is a blocking human-verify checkpoint - Jakub walks it, nobody
self-approves it.** Walk script is in `260729-gt4-SUMMARY.md`.

**Scheme B (trading frame) above 220px of plot, scheme A below, chosen at RUNTIME** from the box the
chart is handed. Not a per-surface flag - `ChartDashboardView` has three call sites under three
height regimes and the two-column one has no minimum at all.

### My arithmetic was wrong and the measurement caught it

I claimed the Markets hero chart could grow 180 → 253 for free on 73px of `Spacer` slack. **False.**
`test/dashboard/markets_hero_height_test.dart` pins the card at **619.0** with a 180px chart and
**692.0** with a 253px chart - it grew by the **full 73px**. The right column drives the
`IntrinsicHeight`; there was never any slack. The row is 585 tall, not the 301 I derived, and **the
missing 284px is still unexplained** - `getMaxIntrinsicHeight` is a different question from laid-out
height, and that is where to look.

**The hero chart stays at 180.** Trend colour and the `borderControl` contrast fix shipped on it
anyway. Sketch README and the handoff are corrected; do not resurrect the 73px claim.

Still deferred, and it is Jakub's call, not a tidy-up: **the dashboard header's `space24`**. The
dashboard's real problem is the filed floor-height bug (two todos in `.planning/todos/pending/`), not
that padding.

---

## Also in this diff, from earlier in the session

`lib/components/scaffold/gw_page_header.dart` - two fixes, verified live by Jakub: trailing content
now reaches the right edge (a loose `Flexible` and a `Spacer` were splitting free space 50/50 and
parking the remainder at the row's end), and the title-to-subtitle gap went 19px → 12px. The
remaining 12px is a **paid-for accessibility margin** - Jakub was offered 4px for `height: 32` and
kept the 48px tap targets. Recorded in `token_info_screen.dart`. Do not tidy it away.

---

## Resume

1. Wait for `14-06` and `14-07`; **re-measure the gates yourself**, never quote an agent's numbers.
2. Finish `14-04` by hand: gates in the FOREGROUND, then its SUMMARY.
3. Diagnose the hanging account test with nothing else running.
4. Run `14-08` (Wave 4).
5. Commit, then open the PR against **`ui-redesign-port`**.
6. Jakub walks the charts (Task 5). Until then the chart work is unverified on screen.

**Baseline at `8ed02e78`, measured in-session:** `flutter analyze` 0 · `check_brace_style --count` 0 ·
`flutter test` 517 pass / 0 fail. The suite has grown by roughly 100 tests since; a higher count is
this session's work, not a regression.
