---
phase: 37
slug: child-write-operations-pending-model
status: draft
nyquist_compliant: false
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

| Requirement | Behavior | Test Type | Automated Command | File Exists |
|-------------|----------|-----------|-------------------|-------------|
| CHILD-03/06/07/08 | Register / revoke / detach / move submit, then resolve on list membership | unit (cubit) | `flutter test test/child_wallets/` | ❌ W0 |
| CHILD-04/05 | Fund / recover amount: exact decimals, > 0, ≤ paying balance; resolve on balance delta vs baseline | unit | `flutter test test/child_wallets/` | ❌ W0 |
| CHILD-09 | Wrong-side action offers "Switch and continue", awaits the real switch, never switches silently | widget | `flutter test test/child_wallets/` | ❌ W0 |
| PEND-01 | Pending → resolved on signal; 2-minute timeout → "Not confirmed yet"; never "done" without the signal; non-OK submit fails immediately | unit (fake clock) | `flutter test test/child_wallets/` | ❌ W0 |
| PEND-02 | Same kind + target locked while pending; different targets independent | unit | `flutter test test/child_wallets/` | ❌ W0 |
| SWT-06 | Switcher "Node running as" rows refuse switching away while an op from the running account is pending; release on resolve/timeout; active wallet never locked | widget | `flutter test test/account/` | ✅ extend |
| VER-01 | Mock confirm / time-out / error modes drive each state | unit + widget | `flutter test test/dev/ test/child_wallets/` | ✅ extend |
| (address) | Manual main address accepts only `0x` + 128 hex | unit | `flutter test test/child_wallets/` | ❌ W0 |

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
