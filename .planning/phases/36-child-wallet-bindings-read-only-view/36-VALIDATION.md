---
phase: 36
slug: child-wallet-bindings-read-only-view
status: draft
nyquist_compliant: false
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

| Requirement | Behavior | Test Type | Automated Command | File Exists |
|-------------|----------|-----------|-------------------|-------------|
| CHILD-01 | New structs' `sizeOf` matches the header layout (392 / 664 bytes, MSVC x64) | unit | `flutter test test/ffi/child_wallet_struct_layout_test.dart` | ❌ W0 |
| CHILD-01 | Registration list wrapper: empty (RET_OK, null, 0) is an empty list; non-OK is an error, not an empty list | unit | wrapper tests with a fake native surface or the mock | ❌ W0 |
| CHILD-02 | Screen renders populated / empty / node-not-running / error; header names the main | widget | `flutter test test/child_wallets/` | ❌ W0 |
| CHILD-02 | Minions → GNUS conversion is integer-exact | unit | table test | ❌ W0 |
| VER-01 | Every dev-mock preset drives the matching screen state | widget | `flutter test test/child_wallets/` (mock presets) | ❌ W0 |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `test/ffi/child_wallet_struct_layout_test.dart`
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
