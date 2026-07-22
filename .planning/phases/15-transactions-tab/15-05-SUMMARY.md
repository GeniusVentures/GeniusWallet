---
phase: 15-transactions-tab
plan: 05
subsystem: dashboard/transactions
tags: [page-frame, breakpoints, gw-page-header, mutation-testing, test-surface, refresh-indicator, freeze-rule]
requires:
  - "TransactionsSlimView.page + the two-card _page layout (15-04)"
  - "GWPageHeader (owns its own space8 bottom gap)"
  - "GeniusBreakpoints.xl"
  - "markets_screen.dart:66-73 — the app's full-page convention"
  - "scoped.isEmpty control-hiding rule (15-03) — used by the narrow-gutter test's fixture"
provides:
  - "TransactionsScreen as a page frame: GWPageHeader + xl cap + additive 12/8 gutter"
  - "TransactionsStream.page and SgnusTransactionsScreen.page pass-throughs, both defaulting false"
  - "test/dashboard/transactions_page_frame_test.dart (5 cases, 7 mutations proven RED, 1 proven GREEN and acted on)"
  - ".planning/phases/15-transactions-tab/deferred-items.md — two measured, out-of-scope findings for the walk"
affects: [15-06 (walk)]
tech-stack:
  added: []
  patterns:
    - "A frame test pumps the REAL screen. A hand-copied replica of the tree cannot fail for the reason the test exists — proven, not argued."
    - "Padding OUTSIDE ConstrainedBox is caught by the WIDTH assertion, not by the gutter assertion — the two nestings are indistinguishable below the cap"
    - "A bloc-fed screen is testable for four lines: `implements X` + `noSuchMethod` forwarding, no mock package"
    - "Every number in a comment is measured; the plan's '1280 minus the padding' and its test-3 mutation were both wrong and are corrected"
key-files:
  created:
    - test/dashboard/transactions_page_frame_test.dart
    - .planning/phases/15-transactions-tab/deferred-items.md
  modified:
    - lib/dashboard/transactions/transactions_screen.dart
    - lib/dashboard/transactions/view/transactions_stream.dart
    - lib/dashboard/transactions/sgnus_transactions_screen.dart
decisions:
  - "The frame test pumps the real TransactionsScreen through two real cubits, NOT the plan's replica — the replica passes 4/4 under the exact mutation that reddens the real one"
  - "Content box is exactly xl (1280) with the gutter additive on top, not xl-minus-padding — the plan's arithmetic was inverted"
  - "The narrow-gutter test uses an empty scope, because the panel's title row has a pre-existing 413px harness floor that has nothing to do with the frame"
  - "RefreshIndicator left structurally untouched; the rail no longer arms it, measured and deferred rather than fixed"
metrics:
  duration: ~70 min
  completed: 2026-07-22
requirements: [TT-01]
status: complete
---

# Phase 15 Plan 05: The page frame Summary

`/transactions` is a page now. One 24px `GWPageHeader`, content capped at
`GeniusBreakpoints.xl` with the 12px gutter additive on top of it, and 15-04's
two cards underneath — reached by a `page` flag that travels three files and
defaults to `false` at every step, so the dashboard's two call sites are
byte-identical to what they were this morning.

`transactions_screen.dart` 40 → 98 lines (26 lines of it comment: four decisions
that a reader would otherwise "simplify" back into the defects). One new test
file, 5 cases. `git diff --stat lib/dashboard/home/view/dashboard_screen.dart`
is **empty**.

**No commits created.** `./CLAUDE.md` holds the gate; `git diff --cached` is
empty.

## What was built

### 1. The two pass-throughs (Task 1)

`TransactionsStream` and `SgnusTransactionsScreen` each gained `final bool page`
with `this.page = false`, forwarded verbatim to `TransactionsSlimView.page`.
Neither default is decoration: `dashboard_screen.dart:365-366` constructs both
as `const` with no arguments, and a defaulted parameter is the only shape that
leaves those two lines untouched. Verified by inspection and by
`git diff --stat` on that file returning nothing.

`SgnusTransactionsScreen` also drops its own `Center` — **only when
`page` is true**, written as `widget.page ? view : Center(child: view)` rather
than deleted. On the page the branch sits in an `Expanded` inside a stretched
`Column`; a second `Center` there would shrink-wrap the two cards to their
intrinsic width and undo that `Expanded`. On the dashboard the tree is exactly
what it was.

Its `Timer`, `initState`, `dispose` and `StreamBuilder` were not touched. One
parameter travelled one level.

### 2. The frame (Task 2)

`Center > Padding(12/8) > ConstrainedBox(xl) > Column(stretch)[GWPageHeader,
Expanded(branch)]`, with `Scaffold`, `SafeArea`, `RefreshIndicator` and the
`BlocBuilder` kept exactly as they were.

The four things the plan asked to be commented are commented, and the second one
is commented **differently from how the plan describes it** — see correction 2.

No `SizedBox` after the header (`GWPageHeader` owns its `space8`). The panel's
`GWSectionTitle` does not reach this route, so the page carries exactly one
title, at 24px.

### 3. The test (Task 3)

`test/dashboard/transactions_page_frame_test.dart`, 5 cases, all with
`takeException()` null. It pumps the **real** `TransactionsScreen` — see
deviation 1, which is the largest decision in this plan.

## Measurements the plan asked for

All from the running widget tree. Surface set explicitly on every pump
(`physicalSize = logical × 3`, `dpr = 3.0`, both torn down) — without it the
content measures 776 on `flutter_test`'s default 800×600 and `xl` and `xxl` are
indistinguishable.

### Content width, by window

| Window | Content box | Dead space each side |
|---|---|---|
| 360 | 336 (viewport − 24) | 0 — the cap is inert, the `Padding` is all of it |
| 1000 | 976 (viewport − 24) | 0 |
| **1600** | **1280.0** | **160** |
| **2000** | **1280.0** | **360** |
| 2560 | 1280.0 | 640 |

Header and branch measured separately at every width and equal at every width,
so the cap binds the whole content box rather than one child of it.

For the record, the defect this replaces: at 2000px the old frame inherited the
panel's `medium` cap and drew a **736px** column with ~630 dead each side. It now
draws 1280 with 360 dead.

### `RefreshIndicator` — works, but not everywhere

Measured on the real screen at 1600×900 with 30 rows, by dragging and watching
for `RefreshProgressIndicator`:

| Drag at | Indicator arms |
|---|---|
| x=900, over the list card | **yes** |
| x=250, over the rail card | **no** |

The page hands `RefreshIndicator` two depth-0 scrollables where the panel gave it
one. The list's `ListView` captures the pull exactly as before. The rail's
`SingleChildScrollView` does not: at any normal page height its content fits
(15-04 measured it engaging its scroll only at a 502px page slot and below), and
a scroll position whose min and max extents are equal refuses the drag, so it
emits no notification for the indicator to see. 220px of a 1280px page is dead to
the gesture.

Not fixed — the plan says not to restructure `RefreshIndicator` speculatively.
Logged in `deferred-items.md` with the one-line answer if 15-06 decides it
matters (`AlwaysScrollableScrollPhysics` on the rail's scroll view).

### The SGNUS branch — not exercised, as predicted

**No automated test in this repo reaches `SgnusTransactionsScreen`.** Every pump
here leaves `selectedWallet` null, so `isSgnusWallet` is false and
`TransactionsStream` mounts. Reaching the other branch needs an `AppBloc`, a
`GeniusApi` in the tree and a live stream controller — far past what a frame
assertion earns. Its `page` pass-through and its conditional `Center` compile and
analyze clean and are **otherwise unverified**. Named in the test file's header
comment as well as here, because 15-06 has to select an SGNUS wallet to see it
at all.

## Corrections to the plan — facts that did not survive contact with the code

**1. The content box is `xl`, NOT `xl` minus the horizontal padding.** The plan's
test 2 says "assert it EQUALS `GeniusBreakpoints.xl` minus the horizontal
padding — i.e. the cap is binding". That is the arithmetic for the *other*
nesting. With the `Padding` outside — which the same plan correctly insists on —
the `ConstrainedBox` sees an already-deflated 1576 at a 1600 window and caps its
child at a clean **1280**; the gutter is additive on top, 1304 of window used.
Measured 1280.0 at 1600, 2000 and 2560. Had I written `closeTo(xl - 24)` the test
would have failed on its first run against correct code. The assertion pins 1280
and the `reason:` names the window.

**2. The plan's mutation for test 3 does not exist. Moving the `Padding` inside
the `ConstrainedBox` does NOT reproduce the 06-01 bezel defect** — and the
correction is more useful than the claim was.

Built the mutation, ran it: at 360 the content still starts at x=12 and test 3
(now test 4) stays **GREEN**. It has to. Below the cap the `ConstrainedBox` is
inert either way, so the `Padding` still insets by 12 whichever side of it the
cap sits on. The two nestings are *indistinguishable* at narrow width.

Where they differ is at WIDE width, and by exactly the padding: the swapped
nesting measures **1256.0** instead of 1280.0. So the ordering property is caught
by the width assertion, not the gutter assertion, and the file now says so at
both sites. The mutation that actually reddens the gutter test is **deleting the
`Padding`**, which drops the content to x=0 and 360-wide — run, RED, in the
matrix below.

Both properties are still pinned. Only the plan's account of which test pins
which was wrong.

**3. The plan's frame test, as specified, cannot fail.** See deviation 1 — this
is the one worth reading.

**4. The plan's baseline of "187 passing" is stale, as 15-03 and 15-04 both
recorded.** Measured immediately before touching anything: **217 passing / 1
failing**, matching the standing brief exactly. At the end: **222 / 1**. +5 is
mine, all in the new file. The single red is the pre-existing
`test/local_wallet_storage_test.dart` → `Missing definition of 'main' method`;
the file is entirely commented out and fails at load. Untouched, unfixed, not a
regression. No extra reds appeared, so no serial re-run was needed to rule one
out.

**5. Line references, for the record.** The plan cites `dashboard_screen.dart:364-366`
for the two call sites; they are at **365-366** (`:364` is the `return
isSgnusWallet`). `transactions_screen.dart`'s body was at `:26-33`, as stated.
The source comments name constructs, not line numbers, so they cannot drift.

## Deviations from plan

**1. [Rule 2 — a test that could not fail] The frame test pumps the REAL
`TransactionsScreen`, not the plan's hand-copied replica.**

The plan's Task 3 says to skip the bloc apparatus by pumping "the exact tree
`transactions_screen.dart` builds" with a `TransactionsSlimView(page: true)` in
place of the branch. A replica of the file under test cannot detect a change to
the file under test — no test in it ever reads `transactions_screen.dart`.

Proven rather than argued. Built the plan's replica exactly as specified, four
assertions, and ran it both ways:

| | replica harness | this file (real screen) |
|---|---|---|
| unmutated source | 4 passed | 5 passed |
| `GeniusBreakpoints.xl` → `xxl` | **4 passed — GREEN** | **RED**, `Actual: <1536.0>` |

The replica is green under the single most likely mistake in the plan. Deleted.

The apparatus that buys a real mutation turned out to be small: `TransactionsCubit`
takes `{List<Transaction> initial = const []}` and needs nothing else, and
`WalletDetailsCubit` only *stores* its `GeniusApi` — the sole call on this screen
is `getCoins()` behind the pull-to-refresh, which no test triggers. So the whole
cost is eleven lines of `MultiBlocProvider` and:

```dart
class _UnusedApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}
```

Four lines, no `mockito` (installed but unused anywhere in `test/`, and this did
not need it), and it throws loudly if that call ever starts happening rather than
returning a silent null. Per `./CLAUDE.md` — use what is already there, write the
minimum that works — this beats both a mock package and a replica that lies.

It also covers Task 1 for free: dropping `page: page` in
`transactions_stream.dart` reddens two cases (M1b below). The replica would not
have touched the pass-throughs at all.

**2. [Rule 3 — scope boundary] Five tests, not four, and the narrow one uses an
empty scope.**

The plan's test 2 carries two viewports in one case (at the cap and below it).
They are split, because they fail for different reasons and a single case cannot
report which. That is the fifth test, not a fifth assertion.

The narrow case pumps an **empty** transaction list. With a non-empty scope at
360 it fails on `A RenderFlex overflowed by 77 pixels` — which is not the frame.
It is `_panel`'s title row (`GWSectionTitle` + the compact filter bar), which this
plan does not touch. Measured through the real screen:

| content width | 320 | 328 | 336 | 344 | 360 | 380 | 400 | 413 |
|---|---|---|---|---|---|---|---|---|
| overflow | 93 | 85 | 77 | 69 | 53 | 33 | 13 | **none** |

Exactly 1:1 with width; the row needs 413px. Three things make it out of scope:
it is in a file this plan does not open; 15-05 made it **8px better** (the old
`EdgeInsets.all(16)` left 328px and overflowed by 85, the new 12px gutter leaves
336 and overflows by 77 — both measured); and it is very probably the harness
font, which draws ~1em per character, so `Transactions` costs ~216px here against
real Inter's ~110. An empty scope removes the red without weakening the test:
15-03's `scoped.isEmpty` guard drops the bar, and the gutter is measured on
`GWPageHeader`, which sits above the branch and renders identically either way.

Logged in `deferred-items.md` with the full table. **Not fixed, and the "real
Inter fits" half is arithmetic on a harness measurement, not a device
measurement** — nobody has put this screen on a 360px window.

**3. [Record only] No appearance parameterisation, deliberately.** Every
assertion here is geometry, which does not move with the palette, so the file
uses `GWColors.dark()` on the default global exactly as the plan says. The
`gwFor`/`themeFor` flag-setting pattern is therefore not needed — and is not
half-used, which is the failure mode 15-03 found: constructing `GWColors.light()`
without setting `GWAppearance.instance.value` yields dark tokens inside a
nominally-light test. If a colour assertion is ever added here, it needs `gwFor`
first.

**4. [Record only] `flutter test` was NOT run after each task in isolation.** The
plan's per-task `<verify>` blocks each call the full suite. It was run at
baseline (217/1) and at the end (222/1), plus the target file and the whole
`test/dashboard/` directory after every mutation. Three full-suite runs of a
10-second suite bought nothing the mutation matrix did not buy better.

**5. [Deliberate omission] `STATE.md`, `ROADMAP.md` and `REQUIREMENTS.md` not
written.** Both of the first two are modified in the working tree by the
concurrent session and the brief forbids touching them. What I would have
written:

- `STATE.md` — Current Plan → 15-06; session Stopped At → `Completed
  15-05-PLAN.md`; the four decisions in this summary's frontmatter; no new
  blockers; the two `deferred-items.md` entries as walk inputs.
- `ROADMAP.md` — phase 15 progress row 4/6 → **5/6** plans complete.
- `REQUIREMENTS.md` — mark **TT-01** complete.

## Mutation matrix — every assertion proven RED

Run serially against the finished tree, one at a time, each reverted and
`cmp`-verified before the next, with a 2s gap. No batch loop — 15-04's produced
two false survivors.

| # | Mutation | Result |
|---|---|---|
| M1 | `const TransactionsStream(page: true)` → `()` in the screen | **RED** — tests 1, 5 |
| M1b | `page: page` dropped in `transactions_stream.dart` | **RED** — tests 1, 5 |
| M2 | `GeniusBreakpoints.xl` → `xxl` | **RED** — test 2 only, `Actual: <1536.0>` |
| M2b | `GeniusBreakpoints.xl` → `large` | **RED** — test 2 only, `Actual: <1024.0>` |
| M3 | `Padding` and `ConstrainedBox` swapped (Padding inside) | **RED** — test 2 only, `Actual: <1256.0>`. Test 4 **GREEN** — see correction 2 |
| M4 | `Padding` removed entirely | **RED** — tests 3 and 4 (`Actual: <0.0>` for the gutter) |
| M5 | `GWPageHeader` → `SizedBox.shrink()` | **RED** — tests 1–4 |
| MR | the PLAN's replica harness, under M2 | **GREEN — and that is the finding.** See deviation 1 |

M1 and M1b are the same red from two different files, which is the point: the
flag has to survive all three hops, and either break is caught. M2/M2b/M3 are
three different wrong widths caught by one assertion, which is what "equals the
cap" buys over "greater than medium". MR is why this file exists in the shape it
does.

## Verification actually run

| Check | Result |
|---|---|
| `flutter analyze lib/dashboard/transactions lib/dashboard/home/view/dashboard_screen.dart test/dashboard` | **No issues found!** |
| `flutter test test/dashboard/transactions_page_frame_test.dart` | **5 passed** |
| `flutter test test/dashboard/` | **181 passed** — 15-04's and 12-04's files unaffected |
| `flutter test` (full suite) | **222 passed / 1 failed** — 217 baseline + 5, the red pre-existing |
| `flutter test test/freeze_rule_test.dart` | **1 passed** |
| `git diff --stat lib/dashboard/home/view/dashboard_screen.dart` | **empty** — the dashboard is byte-unchanged |
| `grep -n 'GWPageHeader\|GeniusBreakpoints.xl' transactions_screen.dart` | both present |
| Mutation matrix (8) | table above |
| `git diff --cached` | **empty** — nothing staged, no commit |

### Freeze rule (`37639d5`) — held

The frame derives **nothing** from constraints. There is no `LayoutBuilder` in
it; `ConstrainedBox`, `Padding` and `GWPageHeader`'s style are fixed literals and
tokens, and the only conditional is the `isSgnusWallet` **boolean**, which comes
from the bloc and not from a dimension. No `AutoSizeText`, no `FittedBox`, no
`textScalerOf(...).scale(...)`. `test/freeze_rule_test.dart` scans
`lib/dashboard/`, so it scans this file, and it passes.

## What was NOT verified

**Nothing was rendered on a screen.** The app was not launched. The five cases
perform real layout and paint, headlessly, in a fallback font roughly twice
Inter's advance. For 15-06's walk:

1. **The SGNUS branch**, which needs an SGNUS wallet selected and which no
   automated test in this repo reaches. Its `page` pass-through and its dropped
   `Center` are compile-checked and nothing more.
2. **Pull-to-refresh over the rail**, measured dead. Decide whether 220px of
   dead gesture on a 1280px page is worth one line.
3. **The panel's title row at phone width** — 413px in the harness, probably fine
   in Inter, never seen.
4. **Whether 1280 is the right cap.** The tests pin that it is 1280 and that it
   binds; whether a transaction row and a 220px rail want 1280 of a 2560 monitor,
   with 640 dead each side, is a judgement no assertion makes.
5. **Whether the page reads as a sibling of Markets and Swap** — same 12/8
   gutter, same 24px header, different cap (xl vs Markets' xxl) by design.

## Compliance

- **No commits created.** Nothing staged, nothing added. `./CLAUDE.md` holds the
  gate and the user has deferred it.
- No `git add -A`, no `git add .`, no `git commit -a`, no `git clean`, no
  `git stash`. Mutations were applied and reverted by file copy (`cp` to `/tmp`
  and back, each revert `cmp`-verified), never by `git checkout`.
- No `dart format` on any file — every edit written by hand in the repo's
  existing style.
- Shared-tree files left alone: `lib/screens/boot_sequence.dart`,
  `tool/boot_sequence_check.dart`, `test/boot_sequence_test.dart`,
  `.planning/phases/13-*`, `.planning/phases/14-*`, `.planning/sketches/015-018`,
  `.planning/sketches/020-boot-mesh-depth`, `.planning/spikes/`, `cmake/*.cmake`.
  `.planning/STATE.md` and `.planning/ROADMAP.md` not written — see deviation 5.
- Exactly three source files modified and two files created. Zero new source
  files, zero new dependencies, zero new abstractions. `mockito` is installed and
  was deliberately not reached for.
- `lib/dashboard/home/widgets/transactions_slim_view.dart` was **not touched** by
  this plan — 15-04's page layout is consumed as delivered.
- No colour hex was copied from a sketch mockup; this plan introduces no colour
  at all. `GeniusWalletGradient.brandCta` is `[#0AD89C, #0AAEE6]`; `#14C8FF` is
  `brandPrimary` and appears nowhere.
- Every number in every comment and table above was measured in this session. The
  one derived figure (real Inter's ~110px for `Transactions`) is labelled as
  derived, twice.
- **Tree state:** branch `redesign/homepage-chrome-260721` at `ea33561`; all
  edits uncommitted. Other modified files listed by `git status`
  (`lib/main.dart`, `lib/hive/init.dart`, the chart files, `cmake/*`, …) belong
  to the concurrent session, not this plan.

## Self-Check: PASSED

- `lib/dashboard/transactions/transactions_screen.dart` — FOUND (98 lines, rewritten, analyzes clean)
- `lib/dashboard/transactions/view/transactions_stream.dart` — FOUND (26 lines, modified)
- `lib/dashboard/transactions/sgnus_transactions_screen.dart` — FOUND (70 lines, modified)
- `test/dashboard/transactions_page_frame_test.dart` — FOUND (221 lines, new, 5/5 pass)
- `.planning/phases/15-transactions-tab/deferred-items.md` — FOUND
- `.planning/phases/15-transactions-tab/15-05-SUMMARY.md` — FOUND
- Scratch files (`zz_narrow_scratch_test.dart`, `zz_replica_scratch_test.dart`,
  `zz_probe_scratch_test.dart`) — **all deleted**; `ls test/dashboard/` shows six
  files, none of them scratch.
- Commits: **none, by design.** Staging area empty.
