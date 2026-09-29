---
phase: 35
slug: unified-header-switcher
status: draft
nyquist_compliant: true
wave_0_complete: false
created: 2026-09-29
---

# Phase 35 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | `flutter_test` (Flutter 3.41.9 at `C:/Users/User/Documents/Projects/GNUS/flutter/flutter/bin`, not on PATH) |
| **Config file** | none — `flutter test` from repo root |
| **Quick run command** | `flutter test test/account/ test/components/desktop_top_bar_text_scale_test.dart test/components/mobile_header_brand_and_pill_test.dart` |
| **Full suite command** | `flutter test` |
| **Estimated runtime** | ~60 seconds quick, ~60 seconds full |

---

## Sampling Rate

- **After every task commit:** quick run command (plus the task's own new test file)
- **After every plan wave:** full suite
- **Before `/gsd-verify-work`:** full suite green, `flutter analyze lib test` 0 issues, `dart format` clean
- **Max feedback latency:** 120 seconds

---

## Per-Task Verification Map

Filled by the planner per task. Required coverage:

| Requirement | Behavior | Test Type | Automated Command | File Exists |
|-------------|----------|-----------|-------------------|-------------|
| SWT-01 | One chip in the desktop track; old SDK chip and wallet dropdown gone; text-scale safe | widget | 35-03 T1: `flutter test test/components/desktop_top_bar_text_scale_test.dart test/components/wallet_identity_test.dart`; 35-03 T2: full `flutter test` + grep for the deleted classes | ✅ extend |
| SWT-02 | Picking a "Sending from" row changes only the active wallet; picking a "Node running as" row changes only the SDK account | widget | 35-01 T2: `flutter test test/account/account_drawer_show_test.dart` (new group, written in the task) | ✅ in-task |
| SWT-03 | Mobile `WalletPill` opens the unified switcher | widget | 35-01 T1: `flutter test test/account/account_drawer_network_section_test.dart` (new WalletPill test); 35-03 T1 re-runs `mobile_header_brand_and_pill_test.dart` unedited | ✅ extend |
| SWT-04 | Add wallet, Add from phrase or key, and delete work from the switcher with Phase 34 rules | widget | 35-01 T3: `flutter test test/account/` (four SDK tests hosted by the real drawer) | ✅ re-point |
| SWT-05 | Send review "From" row names the wallet; Swap names the "From" wallet by its button; switcher labels both selections | widget | 35-02 T1: `flutter test test/components/gw_copy_row_test.dart test/send/send_screen_test.dart test/reown/approve_drawer_contract_test.dart`; 35-02 T2: `flutter test test/squid_router/`; labels in 35-01 T1 / 35-03 T1 | ✅ in-task |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] Independent-selection switcher test
- [ ] Send review "From" wallet-name test (check `test/reown/approve_drawer_contract_test.dart` stays green — dApp approval drawer unaffected)
- [ ] Swap "Sending from" line test
- [ ] Update the two tests that pin renamed strings (`account_drawer_show_test.dart`, `account_drawer_network_section_test.dart`) in the same commit as the copy change

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Switcher on a real node, desktop and mobile | VER-02 | Needs the live testnet; node currently stuck in `INITIALIZING_BLOCKCHAIN` | Open the switcher on desktop and mobile, change each selection, confirm the other stays; add, import and delete from it; confirm Send review and Swap name the "From" wallet |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 120s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
