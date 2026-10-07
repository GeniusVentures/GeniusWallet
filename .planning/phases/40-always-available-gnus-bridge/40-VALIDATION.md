---
phase: 40
slug: always-available-gnus-bridge
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-10-07
---

# Phase 40 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | flutter_test (Flutter 3.41.9, not on PATH) |
| **Config file** | none; `analysis_options.yaml` for lints |
| **Quick run command** | `export PATH="/c/Users/User/Documents/Projects/GNUS/flutter/flutter/bin:$PATH"; flutter test test/dashboard/bridge/ test/tokens/ test/banxa/buy_entry_points_test.dart` |
| **Full suite command** | `flutter test`, then `flutter analyze` (check `$?`), `bash tool/check_brace_style.sh`, `bash tool/check_raw_colors.sh`, `dart format --set-exit-if-changed lib test` |
| **Estimated runtime** | ~60 s quick, ~10 min full |

## Sampling Rate

- **After every task commit:** quick run command
- **After every plan wave:** `flutter test test/dashboard/ test/components/ test/theme/ test/wallets/ test/tokens/ test/banxa/`
- **Before `/gsd-verify-work`:** full suite green, analyze exits 0
- **Max feedback latency:** 120 s

## Per-Task Verification Map

Filled by the planner per task. The requirement-to-test map is in `40-RESEARCH.md` § Validation Architecture.

| Req | Behavior | Test Type | Command | File Exists |
|-----|----------|-----------|---------|-------------|
| BRDG-02/03/05/06 | gate resolver states, precedence, captions | unit | `flutter test test/dashboard/bridge/bridge_gate_test.dart` | W0 |
| BRDG-02/03/06 | cubit recompute on switch/wallet/network, probes | unit | `flutter test test/dashboard/bridge/bridge_gate_cubit_test.dart` | W0 |
| BRDG-01/04/07 | entry on 3 surfaces, caption, tap-time re-read | widget | `flutter test test/dashboard/bridge/bridge_entry_test.dart` | W0 |
| BRDG-01 | compute panel fits slot at 320/290 | widget | `flutter test test/dashboard/compute_panel_height_test.dart` | extend |
| BRDG-04 | coin page 360px both modes, no overflow | widget | `flutter test test/banxa/buy_entry_points_test.dart` | extend |
| D-13 | BridgeScreen refuses submit when gate is not enabled | widget | planner names the file | W0 |
| BRDG-07 | no `isGnusWalletConnected` left in `lib/` | source scan | `grep -rn isGnusWalletConnected lib` | n/a |

## Wave 0 Requirements

- [ ] `test/dashboard/bridge/bridge_gate_test.dart`
- [ ] `test/dashboard/bridge/bridge_gate_cubit_test.dart`
- [ ] `test/dashboard/bridge/bridge_entry_test.dart`
- [ ] Seeded `BridgeGateCubit` helper for widget tests
- [ ] Update the 4 test files that construct `TokenInfoScreen`

## Manual-Only Verifications

| Behavior | Why Manual | Test Instructions |
|----------|------------|-------------------|
| Real bridge from the earning wallet; disabled with reason after switching earning | Needs a running node and testnet (currently blocked on the validator registry) | Walk on Windows: select earning wallet → Bridge enabled; switch earning → caption "switching", then "not earning wallet" |

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 120 s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
