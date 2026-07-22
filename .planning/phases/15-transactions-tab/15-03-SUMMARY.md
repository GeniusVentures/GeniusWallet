---
phase: 15-transactions-tab
plan: 03
subsystem: dashboard/transactions
tags: [empty-state, filters, wcag, shader-hoist, test-fixture-repair, appearance-flag]
requires:
  - Filters / filterCounts / _TransactionFilterBar (12-04)
  - GWSectionTitle's nullable trailing slot
  - GWEmptyState (12-05, re-anchored by 15-01/15-02)
  - GeniusWalletGradient.brandCta, GeniusWalletColors.brandPrimaryOnSurface
provides:
  - "file-scope `_activeLabelShader(GWColors)` — the single light-mode brand degradation, ready for 15-04's rail underline"
  - "`scoped.isEmpty` guard on the panel title row's trailing"
  - "`gwFor(GWAppearanceMode)` in transaction_filters_test.dart — appearance parameterisation that actually flips the global"
affects: [15-04 (filter rail — consumes the hoisted shader), 15-06 (walk)]
tech-stack:
  added: []
  patterns:
    - "A control with nothing to act on is HIDDEN, not disabled — a greyed control still claims there is something to filter"
    - "One brand-degradation function, keyed off surfaceMenu's luminance as an APPEARANCE PROXY, shared by every consumer so the marks cannot drift apart"
    - "Appearance parameterisation in tests must set GWAppearance.instance.value, not just construct GWColors.light() — the tokens are global getters"
key-files:
  created: []
  modified:
    - lib/dashboard/home/widgets/transactions_slim_view.dart
    - test/dashboard/transaction_filters_test.dart
decisions:
  - "The empty guard tests `scoped`, never `txs` — `txs.isEmpty` is the FILTERED-empty branch, whose control must stay or the user is stranded"
  - "`_activeLabelShader` hoisted to file scope unchanged; the hoist is a move, not a redesign"
  - "The group host's fixture is one `escrow` row (never empty), with an optional override for the two tests that genuinely need an empty wallet"
  - "The file's dark/light loops now parameterise over `GWAppearanceMode.values` and set the global flag, closing a latent 12-04 gap"
metrics:
  duration: ~55 min
  completed: 2026-07-22
requirements: [TT-05]
status: complete
---

# Phase 15 Plan 03: Empty-scope guard, empty-state icon, shader hoist Summary

Three corrections to the dashboard Transactions panel plus the one refactor 15-04 is built on:
a wallet with nothing in scope no longer offers five controls for filtering nothing, the
never-transacted state wears `Icons.sync_alt`, and `_activeLabelShader` is now a top-level
function so the page rail's underline can reuse its light-mode degradation instead of inventing
a second one. The test-fixture repair those edits force went further than repair: it also closed
a latent defect where this file's "light" parameterisation had never once painted light.

`transactions_slim_view.dart` 636 → 674 lines. `transaction_filters_test.dart` 546 → 619 lines,
43 → 45 tests.

## What changed

### 1. `_activeLabelShader` hoisted (a move, nothing else)

Out of `_TransactionFilterBar`, up to file scope as `LinearGradient _activeLabelShader(GWColors)`,
placed immediately above `_TransactionFilterBar` so a reader hunting "where does the brand mark
degrade" hits it before either consumer. Body byte-for-byte identical; the single call site at
`_menuItem` was already unqualified and needed no edit. The overflow menu's active label renders
exactly as before.

The doc comment gained two paragraphs, both of which are load-bearing:

- **The second consumer.** 15-04's rail underline (sketch 022 variant B2) is a NON-TEXT mark, so
  it answers to WCAG 1.4.11's 3:1 rather than AA's 4.5:1 — and `brandCta`'s blue stop **`#0AAEE6`**
  (`GeniusWalletColors.gradientBlue`, `genius_wallet_colors.dart:85-86`) is **2.56:1** on white and
  fails even that, while the degraded `#0A6885` is **6.30:1** and passes. Both numbers recomputed
  from the real token values before typing (table below); `#14C8FF` appears nowhere.
- **Why the luminance test reads `gw.surfaceMenu`.** It is an APPEARANCE PROXY, not "the surface I
  am painting on" — the rail underline sits on the card, not on the menu. One token decides the
  branch for every consumer so the two marks cannot degrade at different thresholds. Written down
  explicitly because it is the one thing about the hoist a future reader would otherwise "fix"
  into a per-surface argument.

### 2. The filter control hides on an empty scope

```dart
trailing: scoped.isEmpty ? null : _TransactionFilterBar(...)
```

`GWSectionTitle` already emits its trailing with `?trailing`, so a null trailing is the existing,
working state (the title left-aligns via `spaceBetween`) — no new parameter, no `Visibility`
wrapper, no disabled variant. Sketch 021 locked *hidden entirely*: a greyed control still occupies
the title row and still says "there are things to filter", directly above a block explaining there
are not.

**The test is `scoped`, not `txs`, and that is the whole decision** — spelled out in a comment at
the call site. `txs.isEmpty` is the FILTERED-empty branch, whose control must stay: that wallet is
not empty, and hiding the bar there strands the user on a filter with no route back to All
(T-15-07). The inverted mutation is exercised below.

`compact` (`:185`) is still consumed inside the non-null branch, so the `LayoutBuilder` derives
exactly the one boolean it derived before. The freeze rule (`37639d5`) is untouched — nothing new
is derived from `constraints`, and no `FittedBox`/`AutoSizeText` was introduced.

### 3. The empty-state icon

`Icons.receipt_long_outlined` → `Icons.sync_alt`, branch still `const`. The filtered-empty branch
keeps `Icons.filter_alt_outlined` — untouched, as the plan requires.

A comment records what sketch 022 recorded so a walk does not re-report it: two horizontal opposed
arrows is also the silhouette of the Swap tab's navbar mark (`Icons.swap_horiz_outlined`,
`lib/components/overlay/responsive_overlay.dart:56`); the collision was known and accepted at pick
time, and `Icons.swap_vert` is the one-word alternative if the meaning is ever wanted without it.

### 4. The test file: repair, then two behaviours, then the latent gap

**Repair.** `group('bar fits the title row')`'s `host` pumped an EMPTY list on purpose — no rows
means no coin assets to decode and no row action chip printing "Sent" to collide with the chip
labels two tests search for by text. That reasoning survives; the empty list does not. The fixture
is now one `escrow` row: its action chip reads "Escrow locked" and its subtitle "Locked in escrow"
(`transaction_utils.dart:259,325`), so it collides with nothing, and `_tx`'s other strings are
already short (`coinSymbol: 'ETH'`, `hash: '0xabc'`) for the 419px case.

**Two behaviours added**, both in that group, both with `takeException()` null:

| Test | Asserts | Reddens when |
|---|---|---|
| `an empty wallet offers no filter control at all` | empty list at 900: `barFinder` findsNothing, `byTooltip('More filters')` findsNothing, `emptyTransactionsTitle` findsOneWidget — then the one-escrow list: `barFinder` findsOneWidget | the `scoped.isEmpty ? null :` guard is removed |
| `the filtered-empty branch keeps its way out` | one SENT transfer, tap `byTooltip('Received')`: `barFinder` findsOneWidget, `'Show all'` findsOneWidget, `emptyTransactionsTitle` findsNothing | the guard is written against `txs.isEmpty` |

The absent-then-present PAIR in the first is what proves the control is bound to the scope rather
than merely missing by accident. Plus `expect(find.byIcon(Icons.sync_alt), findsOneWidget)` added
to `an empty wallet and an empty filter render differently`, which is the one place a never-
transacted state is asserted.

**The latent gap.** Every `{'dark': GWColors.dark(), 'light': GWColors.light()}` loop in this file
was nominal. `GWColors.light()` populates `surfaceMenu` from `GeniusWalletColors.surfaceMenu`, a
GLOBAL getter keyed off `GWAppearance.isLight` (`gw_colors.dart:94`), so under the default dark
global it returns the DARK `#171A21` **inside a "light" instance** — `_activeLabelShader` took the
dark arm in both parameterisations and the light degradation had never been painted. Both loops now
parameterise over `GWAppearanceMode.values` and build their `GWColors` through a new `gwFor(mode)`
helper that sets `GWAppearance.instance.value` and `addTearDown`s dark back, mirroring `themeFor`
at `test/theme/theme_contrast_test.dart:23-29`. Parameterising over the enum rather than over two
hand-built instances is what stops the flag and the extension disagreeing again.

**Flipping the flag broke no existing assertion.** All six width cases still measure 40 × 183, both
overflow-trigger tests still pass, and `flutter test test/theme/` is green after this file runs
(the teardown holds). The light code paths simply ran for the first time and were correct.

## Mutation testing — every new assertion proven RED

Run against the finished tree, one mutation at a time, each reverted before the next.

| # | Mutation | Result |
|---|---|---|
| 1 | `trailing: scoped.isEmpty` → `trailing: txs.isEmpty` | **`the filtered-empty branch keeps its way out` RED** (+ 4 collateral: both icon-only tests and both overflow-trigger tests, all of which lose the bar once a filter matches nothing) |
| 2 | guard removed entirely (`trailing: _TransactionFilterBar(...)`) | **`an empty wallet offers no filter control at all` RED**, and *only* that one — 44 others green |
| 3 | `Icons.sync_alt` → `Icons.receipt_long_outlined` | **`an empty wallet and an empty filter render differently` RED** |
| 4 | `throw StateError` in `_activeLabelShader`'s LIGHT arm | **`an overflow filter marks the trigger (light)` RED**, dark green — the light arm is genuinely reached now |
| 4b | same throw, but the test reverted to the OLD `GWColors.light()` pattern | **all 45 PASS** — direct empirical proof the light arm had never been executed by this file |

Mutation 1 is the one the plan cares about: it distinguishes `scoped` from `txs` rather than merely
detecting "some guard exists". Mutation 2 shows the two new tests are not redundant with each other.
4/4b together are the evidence for the latent-gap claim above, rather than a code-reading argument.

## Contrast, recomputed from source (not copied from the design notes)

Computed with the standard `(L1+0.05)/(L2+0.05)` on the real token values —
`brandCta = [gradientGreen #0AD89C, gradientBlue #0AAEE6]` (`genius_wallet_gradient.dart:16-23`,
`genius_wallet_colors.dart:85-86`), `brandPrimaryOnSurface` light `#0A6885`
(`genius_wallet_colors.dart:68`).

| Stop | dark `surfaceMenu` `#171A21` | light `surfaceMenu` `#EFF2F6` | white `#FFFFFF` |
|---|---|---|---|
| `#0AD89C` | 9.38 | 1.65 | 1.86 |
| `#0AAEE6` | 6.81 | 2.28 | **2.56** ✗ 1.4.11 |
| `#0A6885` (degraded) | — | 5.61 ✓ | **6.30** ✓ |

Every number the doc comment carries matches this table: the pre-existing 9.4 / 6.8 dark and
1.65 / 2.28 / 5.61 light figures are confirmed, and the new rail-underline sentence uses 2.56 and
6.30. **`#14C8FF` was not written anywhere** — not in source, not in a test, not in this summary
except to say so. It is `brandPrimary`, not a `brandCta` stop; the erroneous 2.0:1 figure attached
to it does not appear either.

## Deviations from plan

**1. [Rule 3 — less code, same guarantee] The shared `host` gained an optional list parameter
instead of the "render differently" test gaining its own inline harness.**

The plan says to give `an empty wallet and an empty filter render differently` its own inline
empty-list harness. Instead `host` is now
`Widget host(double width, GWColors gw, [List<Transaction>? txs])`, defaulting to
`[_tx(type: TransactionType.escrow)]`.

Reasoning: the plan's concern is that the SHARED host must never be empty again. A default
parameter satisfies that more strongly than a copied harness — "empty" is now something a call site
must ask for by name, and there is exactly one host to reason about. It also let me delete the
inline harness that test *already* carried in its second half (the sent-transfer pump), so the file
gained two tests and still shed a duplicated `MaterialApp > Scaffold > Center > SizedBox` block.
Per `./CLAUDE.md`, fewer lines and one construct beat two. The default is commented with why
`escrow` specifically, and with the note that `txs` is an override, not a second fixture.

**2. [Record only] The plan's `responsive_overlay.dart:56` is at
`lib/components/overlay/responsive_overlay.dart:56`.**

Line 56 is correct and is `icon: Icons.swap_horiz_outlined` on the `/swap` `_TabDestination`, as the
plan says — only the directory prefix was elided. The comment in source carries the full path.

**3. [Record only] The test baseline is not 187.**

The plan and the standing brief both state 187 passing / 1 failing. Measured before touching
anything: **193 passing / 1 failing**. Measured at the end: **205 passing / 1 failing**. The single
red is the same pre-existing `test/local_wallet_storage_test.dart` → `Missing definition of 'main'
method` (the file is fully commented out); untouched, unfixed, not a regression.

The drift is a concurrently-active session in this tree — `lib/components/feedback/gw_empty_state.dart`
was rewritten by it mid-run (the 15-01/15-02 anchor work), and `test/dashboard/` is still entirely
untracked. **My contribution is +2, and the per-file count is the honest number: 43 → 45 in
`transaction_filters_test.dart`.** Nothing here should be read as this plan having added twelve
tests.

**4. [Record only] An intermittent 3-test flake in `test/dashboard/transaction_utils_test.dart`
under the FULL suite, present before this plan.**

`a processing job prints the fee it spent`, `a job fee keeps its full precision for the tooltip`
and `an unpriced job fee drops the value line` failed on two of four full-suite runs at baseline —
**before any edit of mine** — and passed on the others. Running that file alone: `+42: All tests
passed!`, twice. The suite log carries
`Error loading tokens from …/tokens.json: Exception: Failed to load tokens: HTTP 404` alongside
them, and `transaction_row_test.dart` opens a real Hive box, so this looks like cross-file
parallelism plus a network dependency rather than logic. Out of this plan's scope
(`transaction_utils.dart` is one of the concurrently-modified files); flagged, not touched,
not fixed.

**5. [Deliberate omission] `STATE.md`, `ROADMAP.md` and `REQUIREMENTS.md` were NOT updated.**

`.planning/STATE.md` currently tracks *Phase 06 — Onboarding* and is already modified in the working
tree by the concurrent session; `ROADMAP.md` carries no per-plan progress row for phase 15. Writing
to either would either clobber another agent's in-flight edits or record a position this workstream
does not hold. The commit gate is held by the user anyway, so there is no atomic unit to keep in
sync. Flagged here rather than done silently — if the phase-15 workstream wants a STATE row, that is
a deliberate call for whoever owns it.

## Verification actually run

| Check | Result |
|---|---|
| `flutter analyze lib/dashboard/home/widgets` | **No issues found!** |
| `flutter analyze lib/dashboard/home/widgets test/dashboard/transaction_filters_test.dart` | **No issues found!** |
| `flutter test test/dashboard/transaction_filters_test.dart` | **45 passed** (was 43) |
| `flutter test` (full suite) | **205 passed / 1 failed** — the pre-existing `local_wallet_storage_test.dart` load failure |
| `flutter test test/theme/` after the appearance flag work | **16 passed** — no flag leak |
| `grep -n '^LinearGradient _activeLabelShader' …slim_view.dart` | **one line (368)** — the precondition 15-04 reads |
| `grep -n 'Icons.sync_alt\|Icons.filter_alt_outlined' …slim_view.dart` | 272 / 283 — one each, no collision |
| Mutation matrix (5 mutations) | table above — every new assertion reddens under its named mutation |
| Contrast maths | recomputed from the real tokens; table above |

### Geometry: unchanged, as 15-04 assumes

**The bar still measures 40 × 183** at 419 / 420 / 900px in BOTH appearances — now including the
first genuinely-light iterations. The six assertions were not touched, relaxed or re-baselined, and
`compact: the active chip stays icon-only` still pins 183 after a selection. **This plan moved no
pixels on the panel.**

**The 419px case needed no fixture shortening.** Adding one escrow row produced no
`RenderFlex overflowed` at any width — `takeException()` is null in all six cases. The row's
strings were already short enough for the harness's one-em-per-character fallback font, so
`coinSymbol: 'ETH'` and `hash: '0xabc'` stayed as they were.

### What was NOT verified

**Nothing was rendered on screen.** The app was not launched. The widget tests do perform real
layout and paint — both appearances, 419/420/900, popup opened and an overflow filter selected —
but headlessly, with the substitute font. What still needs eyes in 15-06's walk:

1. **`Icons.sync_alt` at 32px in the empty-state circle**, next to the Swap tab in the navbar.
   The collision is accepted, not unknown (sketch 022) — but "accepted on paper" and "reads fine
   live" are different claims, and only the second one has not been made yet.
2. **The title row with no trailing.** `GWSectionTitle` reserves a 44px min-height and centres a
   lone title via `spaceBetween`; that path is now reachable on the dashboard for the first time.
   Confirm the empty panel's header sits at the same baseline as Assets and Markets.
3. **The light-mode active menu label**, which a machine has now painted but no human has seen.

## Compliance

- **No commits created.** Nothing staged, nothing added. `./CLAUDE.md` holds the commit gate and
  the user has deferred it.
- No `git add -A`, no `git add .`, no `git commit -a`, no `git clean`, no `git stash`.
- Shared-tree files left alone: `lib/screens/boot_sequence.dart`, `tool/boot_sequence_check.dart`,
  `test/boot_sequence_test.dart`, `.planning/phases/13-*`, `.planning/phases/14-*`,
  `.planning/sketches/015-018`, `.planning/spikes/`, `cmake/*.cmake`.
- Exactly two source files touched: `lib/dashboard/home/widgets/transactions_slim_view.dart` and
  `test/dashboard/transaction_filters_test.dart`.
- The panel keeps its chips and `⋯` menu; the `Filters` enum is untouched; nothing was removed from
  the dashboard's filter bar. The rail is 15-04's, page-only.
- Freeze rule (`37639d5`) intact: one layout-derived value, still a boolean, still `compact`.
- No new dependency, no new file, no new abstraction beyond the one test helper the plan asked for.
- **Tree state, for the record:** the working tree is on branch `ui-redesign-port` at `ea33561`.
  The session opened on `redesign/homepage-chrome-260721` at `73a09a4`; the switch was not made by
  this plan and no branch, checkout, stash or reset operation was performed here. The edits are
  uncommitted in the working tree, so they travel with whatever branch is checked out — worth a
  glance before anything is committed.

## Self-Check: PASSED

- `lib/dashboard/home/widgets/transactions_slim_view.dart` — FOUND (modified, 674 lines)
- `test/dashboard/transaction_filters_test.dart` — FOUND (modified, 619 lines)
- `.planning/phases/15-transactions-tab/15-03-SUMMARY.md` — FOUND
- Commit hashes: **none, by design** — no commits were created.
