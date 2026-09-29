---
phase: 36
slug: child-wallet-bindings-read-only-view
status: draft
nyquist_compliant: true
wave_0_complete: false
created: 2026-09-29
---

# Phase 36 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | `flutter_test` (Flutter 3.41.9 at `C:/Users/User/Documents/Projects/GNUS/flutter/flutter/bin`, not on PATH) |
| **Config file** | none — `flutter test` from repo root |
| **Quick run command** | `flutter test test/child_wallets/ test/ffi/ test/account/` |
| **Full suite command** | `flutter test` |
| **Estimated runtime** | ~60 seconds |

---

## Sampling Rate

- **After every task commit:** quick run command
- **After every plan wave:** full suite (baseline 1968 passed / 5 skipped)
- **Before `/gsd-verify-work`:** full suite green, `flutter analyze lib test` 0 issues, `dart format` clean
- **Max feedback latency:** 120 seconds

---

## Per-Task Verification Map

Filled by the planner per task. Required coverage:

| Task | Requirement | Behavior | Test Type | Automated Command | File Exists |
|------|-------------|----------|-----------|-------------------|-------------|
| 36-01 T1 | CHILD-02 | Populated screen: header names the main, rows show name/'Unlinked', short address, balance, SDK order; minions → GNUS table | widget + unit | `flutter test test/child_wallets/` | ❌ created by the task |
| 36-01 T2 | CHILD-01 | `sizeOf` 392 / 664; registrations seam: empty is empty, non-OK is error, non-null array freed exactly once | unit (pure Dart, recording fake) | `flutter test test/ffi/` | ❌ created by the task |
| 36-01 T3 | CHILD-02 | Empty / node-not-running / error + Retry, lag note, 10 s poll + Refresh, menu gate + navigation | widget | `flutter test` | ✅ extends T1 + test/account |
| 36-02 T1 | CHILD-01 | All 12 symbols bound; enum member 7; exhaustive switch compiles | analyze + unit | `flutter analyze lib test && flutter test test/submit_job/ test/ffi/` | ✅ |
| 36-02 T2 | CHILD-01 | Metadata/amount boundary checks, raw-bit round trip, byte-safe reads | unit | `flutter test test/ffi/` | ✅ extends T2 file |
| 36-03 T1 | VER-01 | Every preset drives its screen state through the real cubit | unit + widget | `flutter test test/dev/dev_mock_child_wallets_test.dart test/child_wallets/` | ❌ created by the task |
| 36-03 T2 | VER-01 | Bubble section present; phase gate; Windows compile | full suite + build | `flutter test` | ✅ |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `test/ffi/child_wallet_ffi_test.dart` (layout + free contract; the struct-layout test named above lives here)
- [ ] `test/child_wallets/` screen + cubit tests
- [ ] `lib/dev/dev_mock_child_wallets.dart` (needed before widget tests can drive states)

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Real child list and balances | VER-02 | Needs the live testnet; node stuck in `INITIALIZING_BLOCKCHAIN` | From the switcher, open the running SDK account's "Child wallets"; confirm children and balances match the node |
| Dev-bubble presets | VER-01 | Bubble is a debug-only overlay | With `GW_DEV_TOOLS`, switch each CHILD WALLETS preset and watch the screen follow |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 120s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
