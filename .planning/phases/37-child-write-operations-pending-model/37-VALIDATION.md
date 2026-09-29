---
phase: 37
slug: child-write-operations-pending-model
status: draft
nyquist_compliant: true
wave_0_complete: false
created: 2026-09-29
---

# Phase 37 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | `flutter_test` + hand-written fakes (Flutter 3.41.9 at `C:/Users/User/Documents/Projects/GNUS/flutter/flutter/bin`, not on PATH); timers via `testWidgets`' fake-async clock |
| **Config file** | none — `flutter test` from repo root |
| **Quick run command** | `flutter test test/child_wallets/ test/account/ test/dev/` |
| **Full suite command** | `flutter test` (baseline 2034 passed / 5 skipped) |
| **Estimated runtime** | ~60 seconds |

---

## Sampling Rate

- **After every task commit:** quick run command
- **After every plan wave:** full suite
- **Before `/gsd-verify-work`:** full suite green, `flutter analyze lib test` 0 issues, `dart format` clean
- **Max feedback latency:** 120 seconds

---

## Per-Task Verification Map

Filled by the planner per task. Required coverage:

| Requirement | Plan / Task | Behavior | Test Type | Automated Command | File Exists |
|-------------|-------------|----------|-----------|-------------------|-------------|
| CHILD-04, PEND-01 | 01 / T1 (tracer) | Fund from the row menu -> pending badge -> resolve on balance >= baseline + amount -> one toast | widget | `flutter test test/child_wallets/` | ❌ created by 01-T1 |
| PEND-01, PEND-02, CHILD-04 | 01 / T2 | 2:00 timeout -> "Not confirmed yet" + Check again; never done without the signal; per kind+target lock; amount table | unit (injected clock) + widget | `flutter test test/child_wallets/` | ❌ created by 01-T2 |
| CHILD-05, CHILD-06 | 02 / T1 | Recover capped at the child's balance, resolves on <= baseline - amount; revoke resolves only on an OK read without the child | unit + widget | `flutter test test/child_wallets/` | ✅ extend |
| CHILD-09 | 02 / T2 | "Switch and continue" names the account, dispatches only on tap, waits for the real switch; refused while the running account has a pending op | widget | `flutter test test/child_wallets/` | ❌ created by 02-T2 |
| CHILD-07 | 03 / T1 | "This account" card own position; detach resolves when the old main's OK read drops it | unit + widget | `flutter test test/child_wallets/` | ✅ extend |
| CHILD-03, (address) | 03 / T2 | Picker; manual main accepts only `0x` + 128 hex; register resolves when the chosen main lists it | unit + widget | `flutter test test/child_wallets/` | ❌ created by 03-T2 |
| CHILD-08 | 04 / T1 | Move resolves only when both halves are observed | unit + widget | `flutter test test/child_wallets/` | ✅ extend |
| SWT-06 | 04 / T2 | "Node running as" rows locked with the reason while an op from the running account is pending; release on resolve/timeout; active wallet never locked | widget | `flutter test test/account/` | ✅ extend |
| VER-01 | 05 / T1 | Mock confirm / time-out / fail modes drive each state for all six kinds | unit + widget | `flutter test test/dev/ test/child_wallets/` | ✅ extend |
| (phase gate) | 05 / T2 | Full suite, analyze, format, scripts, Windows debug build (not run) | suite | `flutter test` | ✅ |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] Pending-registry / operations cubit tests (CHILD-03..08, PEND-01, PEND-02)
- [ ] Switch-side dialog widget test (CHILD-09)
- [ ] SWT-06 cases in `test/account/sdk_account_rows_test.dart`
- [ ] Write-mode cases in `test/dev/dev_mock_child_wallets_test.dart`

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| All six operations on the live testnet | VER-02 | Needs the live node; currently stuck in `INITIALIZING_BLOCKCHAIN` | Register a child, fund it, recover from it, revoke it; register again, detach; register, move to another main — each shows pending then resolves or "Not confirmed yet" |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 120s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
