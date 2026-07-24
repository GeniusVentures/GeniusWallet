---
phase: 13-boot-loading-sequence-signal-edge-splash-and-one-shared-dash
verified: 2026-07-24T00:00:00Z
status: passed
score: 4/5 must-haves verified
signed_off_by: Jakub
signed_off_at: "2026-07-24T00:00:00Z"
signoff_note: "Jakub marked Phase 13 complete on 2026-07-24. The two human_verification items below (light-theme boot walk, network-down boot walk) are ACCEPTED AS DEFERRED — the light walk to the app-wide light pass, the offline walk to a later run — not performed, consciously deferred, not blockers. Boot behaviour is code-verified incl. the offline mechanism (SC3: 3s http timeout → Hive cache fallback). Dark boot walk was APPROVED 2026-07-24 (kicker → variant C @ 85%)."
behavior_unverified: 0
overrides_applied: 1
overrides:
  - must_have: "The dashboard appears complete — no section renders its own loader on entry (SC2)"
    reason: "13-04 (per-section loader removal) was written then FULLY REVERTED at Jakub's call — he chose to KEEP the per-section loaders. 13-04/13-05 deleted. The retained loaders (coins_screen.dart:209 Loading(), crypto_live_chart.dart:534 PulsingSkeleton) are a conscious design decision, not an incomplete implementation."
    accepted_by: "Jakub"
    accepted_at: "2026-07-24T00:00:00Z"
human_verification:
  - test: "Cold-start the app in LIGHT theme and read the boot screen (mesh, white wordmark, STATUS kicker over the mesh, status text, gradient rail)."
    expected: "Renders IDENTICALLY to dark — dark canvas (#06070B), white wordmark visible, STATUS kicker legible over the mesh at 85% white, no light flash. Contrast AA in light too."
    why_human: "Live contrast over an animated mesh field cannot be measured statically; light-mode walk was consciously deferred (13-05 deleted, 'light after dark'). Code is mode-invariant by construction but UNVERIFIED live in light."
  - test: "Cold-start with the network DOWN (Wi-Fi off) and follow the full boot → closing run → dashboard handover."
    expected: "App boots to the dashboard on cached data within the bounded window, closing run completes, no hang, no exceptions."
    why_human: "The dedicated end-to-end network-down boot walk (SC3 as a phase walk) was consciously deferred (13-05 deleted). Mechanism is verified in code and 13-01 measured one offline cold start reaching a successful state, but the full combined boot→dashboard offline walk was never performed."
---

# Phase 13: Boot & loading sequence — Signal Edge splash and one shared dashboard gate — Verification Report

**Phase Goal:** A cold start shows one branded boot screen that never looks hung, then reveals a *complete* dashboard — no per-section loaders assembling in front of the user.

**Verified:** 2026-07-24
**Status:** human_needed
**Re-verification:** No — initial verification

> **Scope note (ground truth from STATE.md):** Phase 13 was WRAPPED as 13-01/02/03 only. **13-04 (per-section loader removal) and 13-05 (closeout) were DELETED at Jakub's call — he chose to KEEP the per-section loaders.** 13-04 code was written then fully reverted. Two conscious knock-ons: the `[boot-timing]` debugPrint stays in `wallet_details_cubit.dart`, and the full network-down cold start (SC3 as a phase walk) was never performed. These are recorded as conscious/known, NOT blockers. The boot walk (incl. kicker → variant C @ 85% alpha) was **APPROVED 2026-07-24 in dark**; light deferred.

## Goal Achievement

### Observable Truths (ROADMAP / 13-CONTEXT Success Criteria)

| # | Truth (Success Criterion) | Status | Evidence |
|---|---------------------------|--------|----------|
| SC1 | On a cold start the boot screen never reads as hung — nothing on screen promises motion it cannot deliver during the frozen window | ✓ VERIFIED | `splash.dart` renders mesh + centred logo + `STATUS` kicker + held line `Preparing your wallet…` + rail at `_railTarget = 0` (`splash.dart:85-87`); no spinner (`Loading` import dropped); `getInitializationStatus()` appears nowhere in `splash.dart`/`boot_sequence.dart` (M3 respected). `BootSequence` only advances the rail AFTER settle. **Approved dark walk 2026-07-24, item 1 PASS** ("reads as waiting"). |
| SC2 | The dashboard appears complete — no section renders its own loader on entry | ⚠️ PASSED (override) | Per-section loaders **RETAINED** by conscious decision: `coins_screen.dart:209` `Loading()`, `crypto_live_chart.dart:534` `PulsingSkeleton`. Dashboard gate (`dashboard_screen.dart:70`) not widened onto `coinsStatus`. Override: 13-04 written then fully reverted; Jakub chose to keep loaders — accepted by Jakub 2026-07-24. |
| SC3 | The app opens even with the network down (cached data, timeout honoured) | ✓ VERIFIED (mechanism + one offline cold start); dedicated combined walk deferred | `requestTimeout = Duration(seconds: 3)` (`coin_gecko_api.dart:22`) chained onto all three `http.get()` sites (`:47, :143, :203`); pre-existing `catch (e)` blocks (`:76, :174, :229`) fall back to Hive cache. 13-01 Run 4 (Wi-Fi off) cold start: `getCoins` settled `successful` at 137ms, 1× `TimeoutException after 0:00:03`, cache fallback, **0 exceptions / 0 Unhandled**. Full combined boot→dashboard offline walk deferred (13-05 deleted) → human item. |
| SC4 | Zero `RenderFlex overflowed`, zero exceptions, no `LateInitializationError` across a cold start | ✓ VERIFIED | Single-flight `initSDK()`: `initSDK() => _initFuture ??= _doInitSDK()` (`genius_api.dart:189`) kills the double-dispatch `LateInitializationError`. Truthful always-settling `getCoins()` (`wallet_details_cubit.dart:211 await coinFuture`, catch→`error` at :229, every early exit emits terminal status). 13-01 walk (4 cold starts): `Base path directory`=1, `LateInitializationError`=0, `RenderFlex`=0, `Unhandled`=0. 13-03 walk item 8 (dark): 0/0/0. |
| SC5 | Contrast verified live in both themes, including the `STATUS` kicker over the mesh | ⚠️ PARTIAL — dark verified/approved, light pending | Dark: kicker raised 0.38→**0.85** (variant C, `splash.dart:216 Colors.white.withValues(alpha: 0.85)`), walk item 4 **PASS after fix**. Colours mode-invariant by construction (pinned `_kBootCanvas` literal, three `static const` members, explicit `color:` on every text). **Light-mode contrast UNVERIFIED live** — deferred → human item. |

**Score:** 4/5 truths verified (SC1, SC2 override, SC3, SC4) · 1 override applied · SC5 partial (light walk pending)

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `lib/screens/splash.dart` | Re-skinned StatefulWidget: BlocListener gate → Scaffold → GWMeshBackground(pinned baseColor) → Stack[logo, status+rail], drives BootSequence, no `Loading` import | ✓ VERIFIED | Present, substantive (283 lines), wired via `router.dart:30`. `flutter analyze` clean. Kicker fix uncommitted (per commit gate). |
| `lib/screens/boot_sequence.dart` | Plain-Dart `enum BootStage` + `class BootSequence` (stageGap, minimumHold, finalHold, run), `dart:async` only | ✓ VERIFIED | Present (`:9, :24`), `finalHold` clamps ≥0 (`:43-46`), `run()` swallows rejecting work via `guardedWork`+`Future.wait` (`:105`). No Flutter import. Analyze clean. |
| `packages/genius_api/lib/src/genius_api.dart` | `_initFuture` field; `initSDK()` = `_initFuture ??= _doInitSDK()`; body moved to `_doInitSDK()` | ✓ VERIFIED | `:110 Future<void>? _initFuture`, `:189` memoized one-liner, `:191 _doInitSDK()`. `_initSDK` guard untouched (protects onboarding path). |
| `lib/wallets/cubit/wallet_details_cubit.dart` | `await coinFuture` + emit inside try/catch; every exit settles `coinsStatus`; temporary `[boot-timing]` debugPrint | ✓ VERIFIED | `:211 await coinFuture`, catch→`error` `:229`, early exits emit `error` (`:171,:179,:201`), `finally` prints `[boot-timing]` `:231-234`. |
| `lib/services/coin_gecko/coin_gecko_api.dart` | One `requestTimeout` const beside `cacheDuration`, chained onto three `http.get()` | ✓ VERIFIED | `:22 requestTimeout = Duration(seconds: 3)`; `.timeout(requestTimeout)` at `:47,:143,:203`. |
| Runnable check for BootSequence | `tool/boot_sequence_check.dart` runnable via `dart run` | ✓ VERIFIED (relocated) | The check shipped as **`test/boot_sequence_test.dart`** (144 lines, 6 cases: finalHold/clamp, hold-as-floor, hold-stretches, timeout terminates, rejecting-work swallowed, stage order/targets). NOTE: `tool/boot_sequence_check.dart` does NOT exist — the 13-02 SUMMARY and the `boot_sequence.dart:19` comment still name the old path. Documentation staleness only; the runnable check exists as a proper test. |
| `tool/verify_additive_boundary.sh` | Loading canonical importer count 19→18 after splash drops `Loading` | ✓ VERIFIED (per SUMMARY) | Shadow `lib/components/splash.dart` still dead (no real importer outside gallery). Not re-run here (shell guard). |

### Key Link Verification

| From | To | Via | Status | Details |
|------|-----|-----|--------|---------|
| `router.dart:30 GoRoute('/')` | `lib/screens/splash.dart` Splash | routed importer; shadow stays dead | ✓ WIRED | Confirmed sole importer; `lib/components/splash.dart` has no live importer. |
| `AppBloc` subscribeToWalletStatus==loaded + accountStatus settled | `splash.dart` closing run | BlocListener gate | ✓ WIRED | `splash.dart:142,156-159` gates on both statuses; wallet-less → `/landing_screen` `:144-148`. |
| `BootSequence.run(onStage, work)` | status text + `_ClosingRail` tween | setState from onStage | ✓ WIRED | `splash.dart:89-101` maps stages to text + railTarget/duration; `:253-268` TweenAnimationBuilder. |
| `http.get → requestTimeout → TimeoutException` | existing `catch (e)` → Hive cache | shared fetch functions | ✓ WIRED | Timeout only makes the already-correct cache fallback reachable on a hang. |
| Rail | NEVER `getInitializationStatus()` | — | ✓ WIRED (absence) | `getInitializationStatus` absent from splash.dart and boot_sequence.dart (M3: stalls at 52.5% forever). |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| splash.dart + boot_sequence.dart analyze clean | `flutter analyze lib/screens/splash.dart lib/screens/boot_sequence.dart` | No issues found (1.3s) | ✓ PASS |
| BootSequence runnable check exists | `ls test/boot_sequence_test.dart` + case enumeration | 6 cases present (race + stage order) | ✓ PASS |
| Full `flutter test` / `flutter run` | — | Not run per constraints (Hive lock, shared baseline) | ? SKIP |

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `lib/wallets/cubit/wallet_details_cubit.dart` | 231 | Temporary `[boot-timing]` debugPrint (not `kDebugMode`-gated) | ℹ️ Info (conscious/known) | Retained knock-on of the 13-04/05 deletion; 13-05 would have removed it. Console noise on every `getCoins`. NOT a blocker per STATE.md. Clearly commented as temporary (`:163-166`). Upgrade path: delete alongside the Stopwatch when convenient. |
| `lib/components/coins/view/coins_screen.dart` | 209 | Retained `Loading()` per-section loader | ℹ️ Info (conscious) | Covered by SC2 override — Jakub chose to keep loaders. |
| `lib/chart/crypto_live_chart.dart` | 534 | Retained `PulsingSkeleton` per-section loader | ℹ️ Info (conscious) | Covered by SC2 override. |

No `TBD`/`FIXME`/`XXX` debt markers in any Phase 13 boot file.

### Human Verification Required

**1. Light-theme boot screen (SC5)**
- **Test:** Cold-start in LIGHT theme; read the mesh, white wordmark, STATUS kicker over the mesh, status text, gradient rail.
- **Expected:** Renders identically to dark (dark `#06070B` canvas, white wordmark visible, kicker legible at 85% white), AA contrast, no light flash.
- **Why human:** Live contrast over an animated mesh cannot be measured statically; light walk consciously deferred. Code is mode-invariant by construction but unverified live.

**2. Full network-down boot walk (SC3)**
- **Test:** Cold-start with Wi-Fi off; follow boot → closing run → dashboard.
- **Expected:** Boots to dashboard on cached data, closing run completes, no hang, no exceptions.
- **Why human:** Dedicated combined offline boot→dashboard walk deferred (13-05 deleted). Mechanism verified in code + 13-01 measured one offline cold start reaching a successful state, but the full combined walk was never performed.

### Gaps Summary

No blocking gaps. Every ROADMAP/CONTEXT success criterion is either VERIFIED (SC1, SC3-mechanism, SC4), consciously overridden (SC2 — loaders retained at Jakub's explicit call), or verified-in-dark-with-light-deferred (SC5). The two open items (light-theme contrast walk, full network-down boot walk) are conscious deferrals recorded in STATE.md, not implementation misses — hence `human_needed`, not `gaps_found`. The `[boot-timing]` debugPrint and the retained per-section loaders are the two documented, conscious knock-ons of deleting 13-04/13-05. One documentation-only discrepancy noted: the BootSequence runnable check shipped as `test/boot_sequence_test.dart`, while 13-02-SUMMARY and `boot_sequence.dart:19` still reference the never-created `tool/boot_sequence_check.dart` path.

---

_Verified: 2026-07-24_
_Verifier: Claude (gsd-verifier)_
