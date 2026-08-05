# Phase 23 Closeout: Design System Consolidation — Theme Tokens and Shared Components

**Written:** 2026-07-30
**Tree state:** clean, branch `ui-redesign-port`, commit `0bde805` (the security fix that landed
between 23-05 and this plan — see the dedicated section below)
**Verification method:** gate re-run from a clean tree with output quoted verbatim, plus the
twelve-item human walk this phase makes load-bearing (no golden baseline exists — see
`23-CONTEXT.md`'s locked "NO GOLDEN TESTS" decision).

---

## 1. The human walk — Task 1, ALREADY COMPLETE

Performed by the developer on 2026-07-30 against a Windows build of commit `0bde805`, driven by the
orchestrator session (which owns the running app; a second `flutter run` instance dies on the Hive
container lock).

**Verdict: ALL ITEMS PASSED.** Every item was exercised in BOTH appearance modes; items 10 and 11
were also exercised at a narrow window width. No regressions were reported. The three items expected
to look different — item 4's light-mode swap warning note, item 7's toasts, and item 8's button
foregrounds — were called out to the walker in advance, as the plan requires.

The walk ran the plan's twelve items **plus** the three OUTSTANDING batch walks that 23-05 handed
forward, folded into one pass rather than run twice — an explicit developer decision at the
checkpoint, on the grounds that all three 23-05 batches were already committed and green, so the
per-batch bisect rationale was moot. Total: **fourteen items** (twelve plan items plus two added
sub-items), each with an explicit verdict.

| # | Item | Verdict | Notes |
|---|------|---------|-------|
| 1 | Dashboard — balance header, holdings, transactions, markets, news; hover a card + a markets row | PASS (both modes) | Also discharges 23-05 hover-walk item 1: `GWCard` lift, `GWViewAllLink` arrow slide, slim-transactions `_FilterChip`, transaction-detail `_CopyRow` |
| 1b | (added) Transactions tab filter-rail `_RailRow` hover | PASS (both modes) | 23-05's item 1b |
| 2 | Dashboard timeframe tabs — click through, selected/unselected treatment unchanged | PASS (both modes) | Also discharges 23-05 item 2: `GWTimeframeSegment` (dashboard) and `markets_hero_card`'s own `_TimeframeSegment` |
| 3 | Token detail screen — chart, price header, address row, stat rows, timeframe tabs; hover the copy affordance; copy address and paste elsewhere is the FULL address | PASS (both modes) | Also discharges 23-05 item 3: `_CopyAddressRow` glyph, `_BackToMarkets` chip |
| 3b | (added) Submit-job copy row (`GWCopyRow`'s only shipped consumer) | PASS (both modes) | 23-05's item 3b |
| 4 | Swap — amount fields (hover), token selectors, settings drawer; light-mode warning note legible (accessibility fix, expected to look different) | PASS (both modes) | Also discharges 23-05 item 4: swap token selector, MAX chip, `GWSelectRow` pickers, `_PresetChip` |
| 5 | Settings — toggle dark → light → dark; every surface flips live, not only on re-navigation | PASS (both modes) | |
| 6 | Submit logs — monospace text stays monospace (even columns) | PASS (both modes) | |
| 7 | A toast — success and error, in light mode (expected to look different — before, unreadable) | PASS (both modes) | |
| 8 | Buttons — primary/secondary/tertiary-destructive; enabled/hovered/pressed/disabled; disabled reads clearly disabled (expected to look different) | PASS (both modes) | |
| 9 | dApp connect flow — connect prompt and approval text readable | PASS (both modes) | |
| 10 | Onboarding screen at NARROW window width — no edge-to-edge run with zero gutter | PASS (both modes, narrow width) | |
| 11 | Dashboard at NARROW window width — same check | PASS (both modes, narrow width) | |
| 12 | Recovery phrase screen — monospace family; no new copy affordance | PASS (both modes) | |

**Gate outcome: Task 1 is CLOSED.** All fourteen items carry an explicit PASS verdict in both
appearance modes; items 10 and 11 also at narrow width. Nothing is recorded OUTSTANDING — the three
23-05 batch walks that had been left OUTSTANDING are now discharged by this pass (see the row-by-row
mapping above and 23-05-SUMMARY.md's own "Batch A/B/C walk" checklists, which supplied the sub-item
detail folded into items 1/1b/2/3/3b/4 here).

---

## 2. The out-of-phase commit landed between 23-05 and this plan — `0bde805`

`0bde805` — `fix(security): stop printing WalletConnect pairing URIs to the console` — landed
between 23-05 and this plan, authored by the orchestrator with the developer's explicit approval. It
closes the clipboard-logging finding 23-05's extraction audit raised, at **two** sites, not one:

- `lib/web/web_view_windows.dart:75` — printed a clipboard-**read** pairing URI in full; its `catch`
  clause also printed `$e`, which could echo the URI back because `Uri.parse` quotes its source in
  the `FormatException` it throws. Now logs `e.runtimeType` instead.
- `lib/reown/reown_connect_button.dart` — printed a freshly minted pairing URI immediately after
  creating it. This second site was **not** named in 23-05's audit; it was found by grepping for the
  same `debugPrint` pattern once the first site's fix was underway.

A WalletConnect v2 pairing URI carries `symKey`, the session's symmetric encryption key — this was a
credential in the console output, not an inert identifier.

**Consequence for this closeout's handover list:** the "any clipboard site that failed the
full-value or no-logging check" item is recorded below as **found and CLOSED in `0bde805`**, with
the second site noted as additional to 23-05's own audit — it is not carried forward as an open
item.

---

## 3. Gate re-run from a clean tree — Task 2

Tree was clean (`git status --short` empty) at `0bde805` before any of the following ran. Every
command below is quoted verbatim, not paraphrased.

### `flutter analyze --no-pub` — repo root

```
$ export PATH="/c/Users/User/Documents/Projects/GNUS/flutter/flutter/bin:$PATH" && flutter analyze --no-pub
Analyzing GeniusWallet...
No issues found! (ran in 3.7s)
```

### `flutter analyze --no-pub` — `packages/genius_api`

```
$ cd packages/genius_api && flutter analyze --no-pub
Analyzing genius_api...
No issues found! (ran in 1.2s)
```

### `dart format --output=none --set-exit-if-changed lib test`

```
$ dart format --output=none --set-exit-if-changed lib test
Formatted 338 files (0 changed) in 0.80 seconds.
```
Exit code: **0**.

### `bash tool/check_brace_style.sh --count`

```
$ bash tool/check_brace_style.sh --count
0
```
Exit code: **0**.

### `bash tool/check_brace_style.sh --self-test`

```
PASS: 1-collapsed-one-liner-with-braces
PASS: 2-braceless-body-on-next-line
PASS: 3-braceless-nested-paren-condition
PASS: 4-compliant-then-violating-in-same-file
PASS: 5-compliant-form
PASS: 6-else-if-chain-all-compliant
PASS: 7-violation-inside-line-comment
PASS: 8-violation-inside-string-literal
PASS: 9-collection-if-inside-list-literal
PASS: fix-A-simple-guard-clause
PASS: fix-A-simple-guard-clause-idempotent
PASS: fix-B-closure-body
PASS: fix-B-closure-body-idempotent
PASS: fix-C-else-same-line-byte-identical
PASS: fix-C-else-same-line-refusal-reported
PASS: fix-D-body-on-later-line-byte-identical
PASS: fix-D-body-on-later-line-refusal-reported
PASS: fix-E-multiline-body-byte-identical
PASS: fix-E-multiline-body-refusal-reported
PASS: fix-F-collapsed-with-braces-byte-identical
PASS: fix-F-collapsed-with-braces-refusal-reported
PASS: fix-G-collection-if-untouched
PASS: fix-G-no-spurious-refusal
```
Exit code: **0** (23/23 cases pass).

### `bash tool/check_raw_colors.sh --count`

```
$ bash tool/check_raw_colors.sh --count
0
```
Exit code: **0** — over the gate's own covered scope (16 `lib/` subdirectories + `lib/main.dart`;
`lib/theme/` is never covered by design). See §4 for the full-tree count outside the covered scope.

### `bash tool/check_raw_colors.sh --self-test`

```
PASS: 1-material-colors-reference
PASS: 2-hex-color-constructor
PASS: 3-violation-inside-line-comment
PASS: 4-violation-inside-string-literal
PASS: 5-transparent-constant-permitted
PASS: 5b-transparent-does-not-mask-a-later-real-violation
PASS: 6-exempted-line-with-reason-permitted
PASS: 7-bare-marker-with-no-reason-still-flags
PASS: 8-lib-theme-path-excluded
PASS: 9-non-theme-path-not-excluded
```
Exit code: **0** (10/10 cases pass).

### `bash tool/check_no_new_key_logging.sh --scan-tree`

The CI `quality` job invokes this gate as `bash tool/check_no_new_key_logging.sh --scan-tree` (see
`.github/workflows/build.yml`'s "Security gate — no key-material console logging" step) — that
invocation, not the plan's own shorthand (which omits the required mode flag and only prints usage),
is what was re-run here to match what CI actually executes:

```
$ bash tool/check_no_new_key_logging.sh --scan-tree
OK: no key logging in lib/account/sdk_account_manager.dart
```
Exit code: **0**.

### `bash tool/check_onboarding_seed_safety.sh`

```
== CHECK 1 (3.1): recovery phrase is read-only (no selectable/editable widget) ==
PASS [3.1]: neither seed screen declares SelectableText/TextField/TextFormField.
== CHECK 2 (3.2): _isVisible defaults to shown ==
PASS [3.2]: _isVisible = true (phrase shown by default) preserved.
== CHECK 3 (3.3): no print/debugPrint in scope, no bloc observer in lib/ ==
PASS [3.3a]: no print/debugPrint-family call under lib/onboarding/** or in pin_screen.dart.
PASS [3.3b]: no Bloc.observer registration or BlocObserver subclass in lib/.
== CHECK 4 (3.4): 'if (!mounted) return;' within 2 lines after the awaited copy ==
PASS [3.4]: the mounted guard is adjacent to (<=2 lines after) the awaited copy.
== CHECK 5 (3.6): paste_field.dart sets autocorrect:false and enableSuggestions:false ==
PASS [3.6]: both autocorrect:false and enableSuggestions:false present on the import field.
== CHECK 6 (4.9): pin_screen.dart masks entry and uses gw.statusError (not the flat const) ==
PASS [4.9]: obscureText:true and gw.statusError present; flat statusError const absent.

check_onboarding_seed_safety.sh: PASSED -- all six Section 3 checks hold over the finished tree.
```
Exit code: **0**.

### `bash tool/verify_additive_boundary.sh`

```
== Check 1: shadow import boundary ==
FAIL [Loading]: canonical importer set for 'package:genius_wallet/components/loading.dart' does not match the recorded baseline.
  --- expected ---
    lib/banxa/banxa_orders_history.dart
    lib/banxa/banxa_payment.dart
    lib/banxa/checkout_qr.dart
    lib/banxa/user_kyc/kyc_registration.dart
    lib/components/coins/view/coins_screen.dart
    lib/components/custom_future_builder.dart
    lib/components/sgnus/sgnus_connection_widget.dart
    lib/components/splash.dart
    lib/dashboard/news/view/crypto_news_screen.dart
    lib/onboarding/existing_wallet/view/import_security_screen.dart
    lib/onboarding/new_wallet/view/recovery_phrase_screen.dart
    lib/onboarding/routes/wallet_routes.dart
    lib/screens/banxa_buy_screen.dart
    lib/screens/loading_screen.dart
    lib/squid_router/swap_screen.dart
    lib/submit_job/view/submit_job_screen.dart
    lib/web/web_view_windows.dart
  --- actual ---
    lib/banxa/banxa_orders_history.dart
    lib/banxa/banxa_payment.dart
    lib/banxa/checkout_qr.dart
    lib/banxa/user_kyc/kyc_registration.dart
    lib/components/coins/view/coins_screen.dart
    lib/components/custom_future_builder.dart
    lib/components/sgnus/sgnus_connection_widget.dart
    lib/components/splash.dart
    lib/dashboard/news/view/crypto_news_screen.dart
    lib/onboarding/existing_wallet/view/import_security_screen.dart
    lib/onboarding/new_wallet/view/recovery_phrase_screen.dart
    lib/onboarding/routes/wallet_routes.dart
    lib/screens/banxa_buy_screen.dart
    lib/screens/loading_screen.dart
    lib/squid_router/swap_screen.dart
    lib/web/web_view_windows.dart
PASS [Loading]: shadow path 'package:genius_wallet/components/loading/loading.dart' has no un-allowlisted importers.
PASS [Splash]: canonical importer set for 'package:genius_wallet/screens/splash.dart' matches baseline (1 files).
PASS [Splash]: shadow path 'package:genius_wallet/components/splash.dart' has no un-allowlisted importers.
PASS [WalletsOverview]: canonical importer set for 'package:genius_wallet/components/wallet_overview.dart' matches baseline (1 files).
PASS [WalletsOverview]: shadow path 'package:genius_wallet/components/wallets_overview.dart' has no un-allowlisted importers.

== Check 2: duplicate public class name census (includes genuinely-generated *.g.dart files -- analyzer is blind to those) ==
FAIL: the following duplicate public class name(s) are NOT in the captured baseline (tool/shadow-baseline.txt):
    _Section
    _SplashState
    _TimeframeTab
  Do NOT add them to the baseline without a written, reviewed justification -- investigate first.

== Check 3: WIRE- standing tripwire ==
FAIL: 'WIRE-' marker(s) found in lib/ (should be zero):
lib/components/overlay/global_swap_fab_host.dart:21:/// time — WIRE-02 keeps the AI FAB out of this milestone, and its button

verify_additive_boundary.sh: FAILED
```
Exit code: **1** — **this is the CI job's known, deliberately non-blocking gate.** `build.yml`'s
"Security gate — additive shadow-import boundary" step runs this exact command with
`continue-on-error: true`, with an inline comment explaining why: two pre-existing false positives
(the WIRE-02 prose match, and Check 2's blindness to Dart's own library-scoped `_`-prefix privacy)
predate every phase since Phase 8/16, and wiring the gate hard on day one would turn the whole
`quality` job red for reasons no PR author in this phase could fix. Two findings here are worth
calling out individually, since neither was previously documented in a 23-0N-SUMMARY.md and this
closeout's own standard is to quote real output, not the prior phases' summary of it:

- **Check 1's Loading-importer set dropped one entry** (`lib/submit_job/view/submit_job_screen.dart`)
  relative to the recorded baseline — re-verified as a **pre-existing, unrelated drift**: the import
  was removed in commit `deeba91` ("fix(job-flow): the burned bridge hash is no longer thrown away"),
  which predates Phase 23 entirely and touches job-flow logic, not colours or shared components. Check
  1 still PASSES on its own merits (the actual shadow-boundary invariant this check exists to
  enforce); the baseline file itself is now one entry stale and belongs to whichever phase next
  touches `tool/shadow-baseline.txt`, not this one.
- **Check 2's duplicate-class list shrank from four names to three** since 23-01's first recorded
  run (`_Section`, `_SplashState`, `_TimeframeTab`, `_TimeframeTabState`) — `_TimeframeTabState` is
  gone because 23-05 demoted every `GWHoverable`-migrated hover widget (including
  `gw_timeframe_segment.dart`'s `_TimeframeTab`) from `StatefulWidget` to `StatelessWidget`, which
  removed its `State` subclass entirely. This is a genuine, positive side effect of 23-05's own work,
  not a new finding.

Neither failure is new, neither is caused by this plan, and neither touches `lib/theme/` or any
colour/component surface — both are recorded here (updated from prior phases' figures) rather than
silently carried forward unchanged.

### `flutter test --no-pub` (full suite)

```
$ flutter test --no-pub
...
00:12 +718: C:/Users/User/Documents/Projects/GNUS/GeniusWallet/test/web/url_bar_focus_remount_test.dart: constant decoration keeps the field alive across focus
00:12 +719: C:/Users/User/Documents/Projects/GNUS/GeniusWallet/test/web/url_bar_focus_remount_test.dart: constant decoration keeps the field alive across focus
00:12 +720: C:/Users/User/Documents/Projects/GNUS/GeniusWallet/test/web/url_bar_focus_remount_test.dart: constant decoration keeps the field alive across focus
00:12 +721: C:/Users/User/Documents/Projects/GNUS/GeniusWallet/test/web/url_bar_focus_remount_test.dart: toggling decoration null <-> non-null remounts the field
00:12 +722: All tests passed!
```
**722 pass / 0 fail** — above the 512 entry baseline.

### CI `quality` job status

`gh run list --limit 20` and `gh run list --branch ui-redesign-port --limit 10` were run (read-only;
`workflow_dispatch` was NOT triggered — it deletes and recreates a GitHub release on the no-tag-input
path, per this project's standing rule). Results:

- `gh run list --branch ui-redesign-port --limit 10` → **empty. Zero runs have ever executed on this
  branch.**
- `gh run list --limit 20` shows runs only for `develop`, `main`, and various `pull_request` branches
  targeting `develop`/`main` (`redesign/jakub-260726b`, `ui-redesign-3.514-develop`,
  `chore/adopt-gsd`, `dev_mergeandroidbg`, `qr-code`) — never `ui-redesign-port`.
- Reading `.github/workflows/build.yml`'s `on:` block confirms why: the workflow triggers only on
  `push`/`pull_request` to `develop`/`main`, or `workflow_dispatch`. `ui-redesign-port` has never
  been merged or PR'd into either watched branch, so the workflow has had no trigger to fire on.

**Answer to "has it now actually executed": No.** The `quality` job remains wired (landed in
22-08) and blocking for six of its eight steps — the two-exception continue-on-error step is
`verify_additive_boundary.sh`, documented above, not a change made by this plan — but it has **never
run once**, on this branch or any predecessor of it, since it was written. This matches the
2026-07-28 phase-entry state exactly; nothing in Phase 23 changed it, because nothing in Phase 23
pushed to a watched branch or opened a PR. The first real signal on this job will come from the
eventual PR into `develop`.

---

## 4. Before/after table (2026-07-28 entry baseline vs. this closeout, `0bde805`)

| Metric | 2026-07-28 baseline | This closeout (0bde805, re-measured 2026-07-30) |
|---|---|---|
| `flutter test` | 512 pass / 0 fail | **722 pass / 0 fail** |
| `flutter analyze --no-pub` (repo root) | 0 issues, exit 0 | **0 issues, exit 0** (unchanged) |
| `flutter analyze --no-pub` (`packages/genius_api`) | not separately quoted at phase entry | **0 issues, exit 0** |
| `tool/check_brace_style.sh --count` | 0 | **0** (unchanged) |
| `dart format --set-exit-if-changed lib test` | exit 0 | **exit 0**, 338 files, 0 changed |
| Raw colour references outside `lib/theme/` (full `lib/` tree, this phase's own comment/string-stripping matcher) | **525** (grep-based; over-counts doc-comment mentions per 23-02-RESIDUE.md's own reconciliation) | **66** across 29 files in 10 directories — re-measured fresh for this closeout using the gate's exact AWK logic against every `lib/` subdirectory; identical to 23-04-GATE-SCOPE.md's figure, confirming no drift since 23-04 (23-05 and `0bde805` touched no colour literal) |
| — of which, the mode-breaking `Colors.white/black/grey` subset | 83 | not re-measured as a separate subset this closeout (superseded by the 66 total, which uses a stricter matcher than the 83/525 grep-era figures) |
| Raw colour references over the CI gate's own covered scope (16 `lib/` subdirectories + `lib/main.dart`) | gate did not exist | **0** |
| `GeniusWalletColors` (legacy palette) call sites outside `lib/theme/` | 288 (2026-07-28 context) / 277 (23-01's own per-symbol re-measure) | **0 real call sites** — 5 remaining `grep` hits are all doc-comment prose mentions (`gw_warning_note.dart`, `loading.dart`, `pin_screen.dart`, `splash.dart`, `token_selector_drawer.dart`), none executable; any real reference is now a **compile error** since 23-04's `part`/`part of` demotion |
| `GWColors` field count | 21 | **65** (64 after 23-01's parity extension, +1 for 23-03's `statusWarningText` promotion) |
| Net LOC change across `lib/` (`bca3fac`..`HEAD`, the commit immediately before 23-01) | — | **+3,129 / −1,981 across 93 files** (net **+1,148** lines) |
| CI `quality` job | wired and blocking, never executed | **still wired**, still blocking on 6 of 8 steps (`verify_additive_boundary.sh` remains `continue-on-error` by 22-08's own deliberate design, unchanged by this phase) — **still never executed** (see §3) |
| Brace-less `if` (repo-wide) | 0 (closed in Phase 22) | 0 (unchanged) |
| `tool/verify_additive_boundary.sh` | 2 pre-existing failures (WIRE-02 prose, duplicate-class census) | same 2 failure classes, re-measured: duplicate-class list is now 3 names not 4 (one closed as a side effect of 23-05), Loading-importer baseline is 1 entry stale from an unrelated Phase-14-era commit — both pre-existing, neither caused by this phase |

---

## 5. What proved this phase, and what did not

**Value equality proved the token migration.** `test/theme/gw_colors_parity_test.dart` asserts every
one of `GWColors`'s 65 fields resolves to the exact same `Color` the legacy `GeniusWalletColors`
static produced, in both appearance modes — the AST codemod (`tool/codemod_colors.dart`) then only
ever rewrites the *access path* (`GeniusWalletColors.<name>` → `context.gw.<name>`), never the value.
If the parity test holds and the codemod's own `--self-test` proves it never rewrites anything but a
plain access-path expression, the painted result is provably unchanged at all 179 migrated call
sites — a stronger proof than a pixel comparison would have given, because it holds for every
possible render, not just the one frame a golden happens to capture.

**The compiler proved the primitive demotion.** `GeniusWalletColors` is a `part of gw_colors.dart`;
every one of its 65 formerly-public members is underscore-prefixed. Reaching one from outside
`lib/theme/` is not a lint warning or a convention — it is a compile error, demonstrated in 23-04 with
two deliberate probe files, written, run, and quoted (`error - Undefined name GeniusWalletColors`,
`error - The getter brandPrimary isn't defined for the type GeniusWalletColors`), then reverted. This
closeout's own re-grep (§4's "0 real call sites" row) confirms the boundary still holds at the tip of
the phase.

**Measured contrast ratios proved the accessibility fixes.** Every colour pair this phase deliberately
changed — `toast_widget.dart`'s palette, `gw_button.dart`'s destructive variant, the swap settings
warning note, the `lib/reown/` dApp-approval surface, and (via orchestrator follow-up) the
`statusWarningText` token and the status-pill warning label — has a measured WCAG ratio asserted in
`test/theme/theme_contrast_test.dart`, quoted in `23-03-CONTRAST.md`. Goldens were never the right
proof for these: the pixels were *supposed* to move.

**The builder shape proved the hover extraction preserved paint.** `GWHoverable`'s contract (hit area
matches the child's own rect, cursor default/override, no-op `setState` guard on a redundant
enter/exit) is pinned by an ordinary widget test the way no golden could have been, and every one of
the 13 migrated call sites' hover-dependent local was confirmed, by reading the diff hunk, to move
into the builder closure unchanged — the value computed is identical, only its home moved. Net LOC
under `lib/` for that migration alone was **−22 lines** (measured in 23-05-SUMMARY.md), consistent
with pure de-duplication rather than a rewrite that could have drifted.

**Nothing automated proved layout or spacing anywhere in this phase, and that is the residual risk.**
No test in this suite, no compiler check, and no WCAG measurement can catch a 2px padding drift, a
wrong radius, or a control that silently stopped reacting to a hover — the class of defect a golden
baseline exists to catch, and this phase has none (`23-CONTEXT.md`'s "NO GOLDEN TESTS" decision,
locked 2026-07-28, declined twice). **The fourteen-item human walk in §1 is what stood in for that
missing check** — it is the only place in this whole phase that a person actually looked at the
running app and confirmed a hover still reacts, a surface still flips live, and nothing runs
edge-to-edge at a narrow width. That walk PASSED, but it is a point-in-time observation on one
build, on one machine, in one session — it does not carry forward automatically the way a compiled
guarantee does. Any future change to a file this phase touched (the extraction candidates listed as
DEFERRED especially — `GWAppBar`, the `GWScreen` sweep) reopens exactly this same gap, and needs its
own walk, not an inherited PASS from this one.

A closeout that claimed more coverage than this — that treated the walk as equivalent to a
regression-proof test, or that treated the 66 remaining raw-colour references as closed because the
gate is green over its scoped 16 directories — would be the unearned PASS this project has a standing
rule against. This document says plainly where the proof is strong (value equality, the compiler,
measured ratios, the builder shape) and where it is exactly one human's one look (layout and
spacing), because the next phase plans against this document.

---

## 6. Requirement traceability — ORG-01..ORG-05

Written into `.planning/REQUIREMENTS.md` (scoped edit — a new "Organizational & Codebase Quality
(ORG)" section, five new Traceability table rows, and one Coverage note; `git diff` on that file
touches only those three locations):

| Requirement | Phase | Status |
|---|---|---|
| ORG-01 — rules mechanically enforced in CI | Phase 22 | ✓ Complete (CI `quality` job wired; extended by Phase 23's raw-colour gate) |
| ORG-02 — dead code removed | Phase 22 | ✓ Complete |
| ORG-03 — analyzer clean, both packages | Phase 22 | ✓ Complete |
| ORG-04 — one colour source of truth | Phase 23, plans 01-04 | ✓ Complete |
| ORG-05 — duplicated UI collapsed at 3+ call sites | Phase 23, plan 05 | **PARTIAL** — one extraction shipped (`GWHoverable`, 13 sites); four candidates refused/deferred on measured grounds. See `23-05-EXTRACTION-AUDIT.md`. |

ORG-05 is recorded PARTIAL, not complete, because that is what actually happened: one extraction
crossed the Rule-of-Three floor and shipped with zero repaints, and four others — `GWTimeframeSegment`
(the two live copies genuinely diverge on track fill and label set), `GWCopyRow` (out of this plan's
fence, not below the floor — it now exists, built independently), `GWAppBar` (deferred to Phase 24,
which reopens the same 15 files), and the `GWScreen` sweep (deferred whole — a layout change with no
automated proof) — did not. A row claiming ORG-05 complete would misstate what this phase actually
closed.

## 7. Handover list — everything this phase found and deliberately did not fix

Each item below names its source document so a future reader can check the reasoning rather than
re-derive it.

1. **The raw-colour gate's uncovered directories.** 66 raw colour references remain across 29 files
   in 10 `lib/` subdirectories (`lib/account` 1, `lib/banxa` 10, `lib/components` 21, `lib/dashboard`
   6, `lib/network` 6, `lib/reown` 9, `lib/screens` 4, `lib/utils` 2, `lib/wallets` 2, `lib/web` 5),
   re-measured for this closeout and unchanged from 23-04's own count. A full de-hex of everything
   remaining across `lib/` is larger than one phase. `tool/check_raw_colors.sh`'s `COVERED_DIRS` list
   widens by appending a directory the moment its own count hits zero — do not widen speculatively
   ahead of the actual work. Ordered widening plan (smallest/most self-contained first) and per-file
   detail: `23-04-GATE-SCOPE.md`.

2. **Four refused or deferred extractions, with their measured reasons.**
   - `GWTimeframeSegment` — REFUSED. The dashboard/coin-page copy and the Markets hero's own private
     copy diverge on track fill (`surfaceSunken` vs `surfaceMenu`) and label set (5 ranges vs 4); the
     border divergence the original premise cited has since closed (both copies now carry it). Folding
     them would drop a domain each screen expresses or force a reconciling parameter — the exact
     Rule-of-Three stop signal. Tracked follow-up:
     `.planning/todos/pending/2026-07-24-unify-timeframe-segment-component.md`.
     Source: `23-05-EXTRACTION-AUDIT.md`.
   - `GWCopyRow` — REFUSED as an invention, because it already exists (built independently for a
     bridge-hash row, Phase 14 plan 06). Migrating `transaction_displays.dart`'s `_CopyRow` and
     `token_info_screen.dart`'s `_CopyAddressRow` onto it is a legitimate zero-repaint follow-up, not
     yet filed as a todo. Source: `23-05-EXTRACTION-AUDIT.md`.
   - `GWAppBar` — DEFERRED. 15 files construct an `AppBar` directly (count corrected from the
     planning-time 16); Phase 24's routing work opens the same files, so extracting now is still
     churn ahead of that phase. Source: `23-05-EXTRACTION-AUDIT.md`.
   - `GWScreen` sweep — DEFERRED whole. `GWScreen` imposes scroll, a 1200px width cap, centring,
     padding and a background — adopting it where a screen's shape does not already match is a
     layout change, and this phase's own boundary (`23-CONTEXT.md`) forbids layout changes. 25
     screens hand-roll `Scaffold`; only 2 already use `GWScreen`. Needs a functional test net first.
     Source: `23-05-EXTRACTION-AUDIT.md`.

3. **The `GWScreen` scaffold sweep's own reason, stated again because it recurs above:** it is a
   layout change with no automated proof available in this phase (no golden baseline), so it needs a
   functional test net (e.g. layout-value assertions in ordinary widget tests, per `23-CONTEXT.md`'s
   own suggestion) before a future phase attempts it. Source: `23-CONTEXT.md`, `23-05-EXTRACTION-AUDIT.md`.

4. **The platform-generic monospace reference in the Banxa order-details card.**
   `lib/banxa/banxa_components/order_details_card.dart:125`'s `'monospace'` string is a different
   thing from the bundled `JetBrainsMono` family (`GeniusWalletTypography.monoFamily`) and was
   deliberately left untouched — tokenizing a platform-generic fallback would change its meaning, not
   just its spelling. Source: `23-04-SUMMARY.md`.

5. **The clipboard-logging finding — CLOSED, not outstanding.** 23-05's extraction audit found
   `lib/web/web_view_windows.dart:75` logging a clipboard-read WalletConnect pairing URI to the
   console. The orchestrator's follow-up commit `0bde805` (landed between 23-05 and this plan, with
   the developer's explicit approval) fixed it, and in the process found and fixed a **second** site
   `23-05` did not name — `lib/reown/reown_connect_button.dart`, which printed a freshly minted
   pairing URI. Both are fixed; this item does not carry forward. Source: `23-05-EXTRACTION-AUDIT.md`
   (the finding), this closeout §2 (the fix).

6. **A deliberate context-free colour consumer served by a narrow named accessor.** Three static
   accessors on `GWColors` — `statusNeutral`, `fixedStatusError`, `fixedTextSecondary` — exist
   specifically for `const`-context or no-`Theme`-ancestor consumers that cannot read the
   appearance-aware instance layer (three `const TransactionBadgeSpec` sites, `lib/main.dart`'s
   `ErrorWidget.builder` icon, and two mode-invariant `theme.dart` reads). These are a deliberate,
   documented exception to "always read `context.gw`," not an oversight. Source: `23-04-SUMMARY.md`.

7. **The known x64 WalletConnect architectural finding in `lib/reown/`, untouched by design.**
   Finding 3 in `.planning/reference/REVIEW_FINDINGS_REDESIGN.md` — WalletKit is skipped by an
   architecture check on x64 desktop — is owned by Phase 10 (dApp connectivity), not this phase.
   Phase 23 touched `lib/reown/`'s **colours** only (23-03's raw-colour migration); the architectural
   defect itself is out of this phase's scope by ROADMAP assignment. Source: `ROADMAP.md` Phase 10,
   `.planning/reference/REVIEW_FINDINGS_REDESIGN.md`.

8. **The golden/visual-regression gap itself — a standing decision, stated with its consequence.**
   Braian declined the `alchemist` install and the no-dependency `matchesGoldenFile` fallback twice
   at 22-07's blocking-human gate, the second time after a full explanation ("no need to test it
   design diff wise"). No replacement test infrastructure was authorized either — no
   `integration_test`, no `patrol`, no browser-driver approach. **Consequence:** layout and spacing
   changes in this phase, and in every phase since, ship with no automated proof — value equality,
   compiler enforcement, measured WCAG ratios and the existing test suite prove everything *except*
   geometry and paint layout, which only a human walk can catch, and only for the one build it was
   run against. This is *why* `GWAppBar` and three of the four extraction candidates above are
   deferred rather than shipped: each is layout-visible with nothing in this phase's toolkit able to
   prove it stayed correct. If a future phase wants those extractions, **it needs a functional test
   net first.** The Flutter-native candidates the developer already named as a someday item are
   `integration_test` (in-SDK) and `patrol`; a browser-driver approach (Playwright or equivalent) is
   explicitly the wrong tool for Flutter, because Flutter renders its entire UI to a single `<canvas>`
   with no DOM nodes for a browser driver to select. Source: `23-CONTEXT.md`
   ("NO GOLDEN TESTS — locked, 2026-07-28" and "NO NEW TEST INFRASTRUCTURE EITHER — locked"),
   `.planning/phases/22-.../22-07-DEFERRED.md`, §5 above.

---

*Phase: 23-design-system-consolidation-theme-tokens-shared-components*
*Task 2 completed: 2026-07-30*
*Task 3 (requirement traceability + handover list) completed: 2026-07-30*
