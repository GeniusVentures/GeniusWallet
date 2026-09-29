---
phase: 38
slug: account-tree-switcher
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-09-29
---

# Phase 38 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | flutter_test (bundled with the Flutter SDK) |
| **Config file** | none (no dart_test.yaml) |
| **Quick run command** | `C:/Users/User/Documents/Projects/GNUS/flutter/flutter/bin/flutter test test/account/ test/child_wallets/` |
| **Full suite command** | `C:/Users/User/Documents/Projects/GNUS/flutter/flutter/bin/flutter test` |
| **Estimated runtime** | not measured; the quick run covers two directories, the full suite ~2150 tests |

---

## Sampling Rate

- **After every task commit:** Run the quick run command (plus `test/components/` for 38-02-01 and 38-03-02, `test/squid_router/swap_submit_test.dart` for 38-01-03)
- **After every plan wave:** Run the full suite command
- **Before `/gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** one quick run

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 38-01-01 | 01 | 1 | SWT-07 | T-38-02, T-38-03 | FFI reads only on key change; foreign leaves act through the shared registry | widget (tracer) | `flutter test test/account/ test/child_wallets/` | ✅ | ✅ green |
| 38-01-02 | 01 | 1 | SWT-07 | T-38-01, T-38-04 | walk terminates on any cycle; reads only own accounts | unit | `flutter test test/account/account_tree_test.dart test/child_wallets/child_operations_cubit_test.dart` | ✅ | ✅ green |
| 38-01-03 | 01 | 1 | SWT-07 | — | N/A | widget | `flutter test` | ✅ | ✅ green |
| 38-02-01 | 02 | 2 | SWT-07 | — | disabled look shared; no visible change | widget | `flutter test test/components/gw_menu_item_test.dart test/account/ test/child_wallets/` | ✅ | ✅ green |
| 38-02-02 | 02 | 2 | SWT-07 | T-38-05..T-38-09 | SDK items gated by On node only; phrase/QR only on the running row; row tap never switches the node | unit + widget | `flutter test` | ✅ | ✅ green |
| 38-03-01 | 03 | 3 | SWT-07 | T-38-10, T-38-11 | child actions only via start* flows and registry locks | unit + widget | `flutter test test/account/ test/child_wallets/` | ✅ | ✅ green |
| 38-03-02 | 03 | 3 | SWT-07 | T-38-12 | preset listener gated and removed on dispose | widget + contrast | `flutter test test/account/ test/components/` | ✅ | ✅ green (listener compiled out under `flutter test`'s `kShowDevTools=false`; source-level `grep -c` checks below stand in) |
| 38-03-03 | 03 | 3 | SWT-07 | — | ID, trailer, LF, key-logging gates | gate + Windows debug compile | `flutter test && flutter analyze lib test` | ✅ | ✅ green -- full suite 2227/5/0 (2202 baseline + 25 new); analyze/format/brace/raw-colour/key-logging clean; ID gate 0 (`BASE=22addb51`); trailer gate 0; every phase-created file `i/lf`; Windows debug build succeeded (`build\windows\x64\runner\Debug\genius_wallet.exe`) |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

Existing infrastructure covers the phase: flutter_test is installed and every task writes its tests first. New test files are created inside the tasks that need them:

- [ ] `test/account/account_drawer_tree_test.dart` — 38-01-01 (the tree through the real drawer)
- [ ] `test/account/account_tree_test.dart` — 38-01-02 (nesting, cycles, dedup)
- [ ] `test/components/gw_menu_item_test.dart` — 38-02-01 (the promoted menu item)

Existing tests that change with the drawer: `account_drawer_show_test.dart`, `account_drawer_network_section_test.dart`, `sdk_account_rows_test.dart`, `sdk_account_delete_coupling_test.dart`, `sdk_start_account_delete_test.dart`, `test/squid_router/swap_submit_test.dart`.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Real registrations nest correctly on a live node, desktop and phone | SWT-07 (VER-02 standing) | needs a live testnet node, currently stuck in INITIALIZING_BLOCKCHAIN | end of milestone: open the switcher on desktop and phone with a registered child; record a blocked gap if testnet is still stuck |
| Each CHILD WALLETS preset repaints an open switcher | SWT-07 | the preset listener is compiled only with GW_DEV_TOOLS, which `flutter test` cannot define | dev build with GW_DEV_TOOLS: open the switcher, press each preset in the bubble, watch the tree change |
| Light-mode visual pass of tags, chevron and indent | SWT-07 | contrast is measured by tests; the look is not | toggle appearance with the switcher open; check both modes at phone and desktop width |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Feedback latency measured during execution (quick run after every task commit, full suite at each plan's close)
- [ ] `nyquist_compliant: true` set in frontmatter (set by `/gsd-validate-phase`, not this executor)

**Approval:** {pending / approved YYYY-MM-DD}
