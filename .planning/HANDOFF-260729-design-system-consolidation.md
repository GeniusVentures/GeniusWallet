# Handoff · 2026-07-29 · Phase 23, plans 01-04

**Branch:** `ui-redesign-port`. **Started:** `bca3fac` (PR #218 merge). **Ended:** `82e262c`.
**44 commits. Working tree clean. Nothing pushed. No PR opened.**

Phase 22 was already done and is confirmed so. Phase 23 is **4 of 6 plans complete**.

---

## Verified baseline at `82e262c` — re-measured, not quoted

| Gate | Value |
|---|---|
| `flutter analyze --no-pub` | **No issues found!**, exit 0 |
| `tool/check_brace_style.sh --count` | **0** |
| `tool/check_raw_colors.sh --count` | **0** (new this session) |
| `dart format --output=none --set-exit-if-changed lib test` | **exit 0** |
| `flutter test --no-pub` | **707 pass / 0 fail** |

**The suite grew 682 → 707 today.** Every older planning doc says 512, 682 or 693 — all stale.
`23-01-PLAN.md`'s acceptance criterion literally reads "green at 512 or higher", which would let a
170-test regression pass. **Use 707 as the floor.**

---

## What shipped

- **23-01** — `GWColors` 21 → 64 fields at full name parity with the legacy palette; `context.gw`
  accessor with a non-throwing fallback; `gw_colors_parity_test.dart`, the value-equality proof that
  replaces the golden baseline this phase does not have. **Zero call sites changed.**
- **23-02** — AST codemod (`tool/codemod_colors.dart`, `package:analyzer`, **no new dependency** —
  `pubspec.yaml`/`.lock` byte-untouched). **179 of 251** `lib/` colour reads moved to `context.gw`,
  one commit per directory; 72 refused (45 const-context, 27 no-BuildContext) and inventoried.
  Task 4's appearance walk was **performed live by Braian and approved**.
- **23-03** — residue closed; toast palette re-derived; `gw_button`'s destructive AA failure fixed;
  `lib/reown/` moved off raw colours; forked warning widget replaced with `GWWarningNote`.
  +12 measured-WCAG contrast tests.
- **23-04** — `GeniusWalletColors` **demoted to a private `part` of `gw_colors.dart`**; mono type
  token; `GWDecorations` de-hexed; `tool/check_raw_colors.sh` landed with a scoped widening plan.

Plus one repair unrelated to Phase 23: **`66133b9` dart-formatted five files PR #218 left
unformatted.** `.github/workflows/build.yml:1396` runs `dart format --set-exit-if-changed` as a
gate; it was red, and the `quality` job has never run, so that would have been its first result.
Proven whitespace-and-trailing-comma-only by stripping both and comparing byte streams.

---

## Two adversarial probes, reproduced by the orchestrator — not taken on the executor's word

**The primitive layer is genuinely sealed.** A probe in `lib/dev/` importing `gw_colors.dart` and
reaching a primitive:

```
error - The getter '_brandPrimary' isn't defined for the type 'GeniusWalletColors'
```

All 65 members are underscore-private. The only surviving mention of the class outside `lib/theme/`
is a **RegExp string** in `test/banxa/banxa_reskin_literals_test.dart` — a pattern, not a reference.

**The new gate can actually fail.** Injected `Color(0xFF123456)` into `settings_screen.dart` →
**exit 1**; reverted → **exit 0**, tree clean. This repo has shipped two vacuously-passing gates
before (`check_no_new_key_logging.sh` diffed working tree vs index, always empty on CI;
`check_onboarding_seed_safety.sh` CHECK 4 text-matched an unbraced `if` and broke when 22-04 braced
it). **When you touch a gate, prove it still fails on an injected violation.**

---

## OPEN — carry these forward

1. **Light-mode status pills: success and error fail WCAG AA.** Measured against their own
   composited wash, 4.5:1 required (13px w600 is below the 18.66px large-text threshold):

   | Tone | elevated | menu | base |
   |---|---|---|---|
   | success | 3.77 | 3.39 | 2.91 |
   | error | 3.89 | 3.49 | 2.99 |
   | warning | 6.56 | 5.93 | 5.15 ← fixed today |

   Both `surfaceBase` figures are below even the 3:1 non-text floor. **Pre-existing.** Part 8 of
   `theme_contrast_test.dart` deliberately does NOT assert them — tuning the threshold down to admit
   them would be the unearned PASS this project forbids. Filed at
   `.planning/todos/pending/2026-07-29-status-pill-success-error-fail-aa-in-light-mode.md`.
   Upgrade path: `statusSuccessText`/`statusErrorText` mirroring `statusWarningText`.

2. **23-02's walk has two inconclusive surfaces.** The dashboard markets % cells and the token
   detail chart had no data to paint — CoinGecko timed out, TLS `HandshakeException`, and the RPC
   returned "Request timeout on the free plan". **Infrastructure, not code.** 23-06's closeout walk
   must re-check those two specifically.

3. **The CI `quality` job has STILL never run.** Nothing is pushed. `build.yml` only triggers on
   push to `develop`/`main`, PRs targeting those, or `workflow_dispatch`. The new
   `check_raw_colors.sh` has therefore never executed on CI, where Flutter is pinned to **3.38.10**
   vs **3.41.9** locally and analyzer output is version-sensitive.
   **DO NOT `workflow_dispatch` to test it** — that also runs the `build` job, which on the
   no-tag-input path does `gh release delete --yes` + tag delete + `gh release create`. Firing it to
   test a lint job would delete and recreate a GitHub release.

4. **`check_raw_colors.sh` covers 17 directories; 10 are uncovered** — **61 violations across 32
   files**, every one with a measured count and closing note in `23-04-GATE-SCOPE.md`. Highest
   leverage and highest review cost: `lib/components` (21 across 10 files, incl. `gw_button.dart`
   and `gw_mesh_background.dart`). `lib/reown`'s 9 are flagged as **needing re-verification**, not
   assumed deliberate.

5. **`GWColors.lerp` is `t < 0.5 ? this : other`** — pre-existing, untouched all session.
   `MaterialApp` wraps content in an implicit `AnimatedTheme` (STATE.md records this from 09-01), so
   an appearance flip animates and this snaps at the midpoint instead of crossfading. 23-01's
   acceptance criterion "`lerp` lists every field" rests on a false premise: it enumerates none.

---

## Still to do in Phase 23

- **23-05** — extraction adjudication (four candidates already refused on evidence by the re-plan)
  then extract `GWHoverable` across 12 sites, promoted from the private shim in `swap_field.dart`.
  Autonomous, no human gate.
- **23-06** — closeout: twelve-item walk in both modes at two widths, every gate re-run from a clean
  tree with output quoted, ORG-01..05 traceability (**ORG-05 partial by design**), handover list.
  Note `23-06-PLAN.md` also records that **ORG-01..03 were never written into `REQUIREMENTS.md`** —
  the Phase 22 plan that would have done it was superseded in the split.

---

## Method notes worth reusing

- **Re-measure every count.** It refuted a planning figure *four separate times* today: 65 public
  members not ~46; 277 call sites not 288/260; 251 `lib/` sites not 277; **eight** test files
  needing migration in 23-04, not the six the plan named.
- **A test can pin a bug.** `order_status_style_test.dart` asserted the warning label was identical
  in both modes, titled *"mode-invariant static, recorded as a fact rather than a defect"*. It was a
  defect (1.47:1). The assertion had to be flipped, not satisfied.
- **The assertion that proves a fix finds the next bug.** Adding the pill contrast test immediately
  surfaced the success/error failures in item 1 — which no one had measured because neither pill
  function had *any* test before today.
- **Comments outlive the defects they describe.** Two required correction after the code moved
  (`23-01-SUMMARY.md`'s false `lerp` claim; `transaction_displays.dart`'s "deferred to the light
  pass" block).

## Environment

- **Flutter SDK is not on `PATH`** — prefix every invocation with
  `export PATH="/c/Users/User/Documents/Projects/GNUS/flutter/flutter/bin:$PATH"`. Omitting it gives
  "command not found", historically misread here as a compile failure.
- `flutter analyze` **exits non-zero on infos** — judge by issue count, never exit code.
- The analyzer resolves the **nearest** `analysis_options.yaml`; `packages/genius_api/` has its own.
- Run the app: `CMAKE_ARGUMENTS="-DCMAKE_BUILD_TYPE=Release -DGENIUS_DEPENDENCY_BRANCH=develop -Dc-ares_DIR=C:/Users/User/Documents/Projects/GNUS/thirdparty/build/Windows/Release/cares/lib/cmake/c-ares" flutter run -d windows --debug --dart-define=GW_DEV_TOOLS=true`
  — ~17-37s from warm cache. **Kill any running `genius_wallet.exe` first**; it holds a DLL lock
  that fails the next build. No instance is left running.
- `test/account/account_drawer_show_test.dart` (the `testWidgets`+real-Hive hang) is still **absent**
  from the tree. `flutter test` runs clean in the foreground.
