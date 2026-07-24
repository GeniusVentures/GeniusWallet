---
phase: 13-boot-loading-sequence-signal-edge-splash-and-one-shared-dash
plan: 03
subsystem: screens/boot
tags: [boot, splash, signal-edge, human-walk, dark-only, mesh, shadow-boundary]
type: execute + checkpoint:human-verify
requires:
  - "13-01 (single-flight initSDK + truthful getCoins)"
  - "13-02 (CoinGecko shared timeout + BootSequence engine)"
provides:
  - "routed Signal Edge boot screen (lib/screens/splash.dart), walked and APPROVED in dark"
affects:
  - lib/screens/splash.dart
  - tool/verify_additive_boundary.sh
  - .planning/phases/03-gw-component-library/03-SHADOW-NAMES.md
key-files:
  modified:
    - lib/screens/splash.dart
walk:
  date: 2026-07-24
  walker: Jakub
  build: flutter run -d macos --dart-define=GW_DEV_TOOLS=true (Flutter 3.41.9), genuine cold starts
  mode: DARK (light mode-invariance carried to 13-05 - see below)
decisions:
  - "Kicker alpha raised 0.38 -> 0.85 (walk variant C, Jakub's pick): the 38% STATUS kicker faded into bright mesh blobs. One-line literal change, still mode-invariant (Colors.white, no flipping token). UNCOMMITTED."
  - "Coins/holdings leg: INCLUDED in the parallel work future, with NO own timeout - it rides coin_gecko_api.dart's shared 3s requestTimeout (13-02); a second timeout would be redundant. Measured getCoins settle: 10853ms on the cold run (that figure includes the ~9.6s frozen isolate, not network) / 843ms warm. The network call itself is bounded at 3s."
status: complete
---

# Phase 13 Plan 03: Signal Edge boot screen - walk Summary

Task 1 (the re-skin) was already in the tree (commit `29b183b`). This session ran Task 2,
the blocking human walk, and applied one walk-driven kicker fix. **Approved in dark.**

**No commits created.** `./CLAUDE.md` holds the commit gate; the kicker edit is UNCOMMITTED.

## Task 1 code - verified in place (not re-run)

- `lib/screens/splash.dart` is a StatefulWidget: `Scaffold(bg: _kBootCanvas)` -> `GWMeshBackground(baseColor: _kBootCanvas)` -> `Stack` of a constrained centred logo and a bottom-anchored `STATUS` kicker + gradient rail, driving `BootSequence` (13-02).
- `_kBootCanvas = Color(0xFF06070B)` - a pinned-dark literal, explicitly passed to defeat `GWMeshBackground`'s mode-flipping `surfaceBase` default (D8). Note: this is the unified boot canvas synced with the native window (`MainFlutterWindow.swift`), NOT the plan's original `0xFF0B0D12`; a deliberate later refinement.
- Run gate starts once `subscribeToWalletStatus == loaded` AND `accountStatus` has SETTLED (loaded OR error) - so an account failure hands over to the dashboard's own retry branch rather than hanging the splash forever.
- Wallet-less branch routes straight to `/landing_screen` with no closing run.
- `getInitializationStatus()` appears nowhere (M3: it stalls at 52.5% forever).
- Gate re-verified this session: analyze clean on the file; additive-boundary **Check 1 = 0 FAIL**; no banned tokens on non-comment lines.

## Shadow-import boundary

`lib/screens/splash.dart` dropped its canonical `Loading` import when the spinner was replaced.
`LOADING_CANONICAL_EXPECTED` went **19 -> 18** and `03-SHADOW-NAMES.md`'s Loading row now reads
18, with a dated note attributing the reduction to phase 13 (a real caller leaving, not a
path-swap). Check 1 reports zero failures.

## Walk verdict (Task 2, dark)

| # | Item | Verdict | Evidence |
|---|------|---------|----------|
| 1 | Frozen ~9.6s window reads as *waiting*, not *hung* | **PASS** | Jakub: "raczej ok" - reads as waiting. Logo centred, `STATUS` + `Preparing your wallet…`, rail at zero, nothing feigning motion |
| 2 | Closing run: Wallets/Balances/Markets ready + rail sweep | **PASS** | Jakub: "spoko" - three confirmations in order, rail sweeps to full, hands to dashboard |
| 3 | H3 mesh resume jump (the roadmap's named unknown) | **NOT OBSERVED** | Jakub: "nie widać" - no visible blob pop at freeze-lift. The prediction ("masked") holds; no follow-up needed |
| 4 | Kicker legible over mesh (dark) | **PASS after fix** | 38% faded into bright blobs; raised to 85% (variant C). Now first-read |
| 8 | Console (every run) | **PASS** | 0 `RenderFlex overflowed`, 0 `EXCEPTION CAUGHT`, 0 `LateInitializationError`, 0 keyboard assertions across cold runs |

## Carried to 13-05 (recorded, NOT passed here)

13-05 is the full-phase walk (both themes, network-down cold start), so these belong there:

- **Item 5 - BOTH THEMES / mode-invariance.** The boot screen must render IDENTICALLY in light
  (dark canvas, white wordmark, same kicker). NOT walked this session (Jakub defers light until
  dark is complete). The code path is correct by construction (explicit `baseColor` literal), but
  it is UNVERIFIED live. Do NOT mark passed until walked.
- **Item 6 - narrow window.** Logo-clip / status-row overflow at phone width not walked.
- **Item 7 - wallet-less path.** Straight-to-`/landing_screen` with no closing run not walked
  (needs a cleared four-layer profile).

## Not a Phase 13 defect

The **black full-screen window for 2-3s before the splash** that Jakub observed is the known,
deferred pre-splash gap (`todos/pending/2026-07-22-boot-shows-an-empty-window-*.md`, measured
~4s there). Out of scope for 13-03.

## Walk-driven fixes

- `lib/screens/splash.dart`: kicker alpha `0.38 -> 0.85` (variant C). One line, mode-invariant,
  UNCOMMITTED. Re-analyze clean.
