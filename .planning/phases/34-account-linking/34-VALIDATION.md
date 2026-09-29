---
phase: 34
slug: account-linking
status: draft
nyquist_compliant: true
wave_0_complete: false
created: 2026-09-29
---

# Phase 34 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | `flutter_test` (Flutter 3.41.9 SDK at `C:/Users/User/Documents/Projects/GNUS/flutter/flutter/bin`, not on PATH) |
| **Config file** | none — `flutter test` from repo root |
| **Quick run command** | `flutter test test/account/ test/local_wallet_storage_test.dart` |
| **Full suite command** | `flutter test` |
| **Estimated runtime** | ~60 seconds quick, several minutes full |

---

## Sampling Rate

- **After every task commit:** quick run command
- **After every plan wave:** full suite
- **Before `/gsd-verify-work`:** full suite green, `flutter analyze` clean, `dart format` clean
- **Max feedback latency:** 120 seconds

---

## Per-Task Verification Map

Filled by the planner per task. Required coverage:

| Requirement | Plan-Task | Behavior | Test Type | Automated Command | File Exists |
|-------------|-----------|----------|-----------|-------------------|-------------|
| LINK-01 | 01-T1 | Link map round-trips lowercased public addresses + name; capture feeds wallet-menu names | unit + bloc | `flutter test test/local_wallet_storage_test.dart test/account/sdk_account_links_test.dart` | ❌ created in 01-T1 |
| LINK-01/D-20 | 01-T2, 01-T3 | Start-account rename; links reach AppState at every SDK emit | unit + bloc | `flutter test` | ✅ extend |
| LINK-02 | 02-T1 | SDK rows: name / address + status / order / empty / same-name | widget | `flutter test test/account/sdk_account_rows_test.dart` | ❌ created in 02-T1 |
| LINK-02/D-19 | 02-T2 | SDK and SDK PENDING badges; address-based selection | unit + widget | `flutter test test/account/account_drawer_show_test.dart` | ✅ extend |
| D-20 | 02-T3 | Compute panel "Not the default account" | unit + widget | `flutter test test/dashboard/` | ✅ extend |
| LINK-03 | 03-T1, 03-T2 | Backfill links provable pairs only, stops on a jump >1, runs after SDK start | unit + bloc | `flutter test test/account/sdk_link_backfill_test.dart` | ❌ created in 03-T1 (TDD) |
| LINK-01/D-01..D-07 | 04-T1, 04-T2 | SDK form saves the wallet; added / already there / pending / failed; no selection change | widget | `flutter test test/account/sdk_add_account_test.dart` | ✅ extend (04-T1 is analyze + grep: StoredKey needs the native lib) |
| D-08..D-12 | 05-T1..T3 | Name snapshot; SDK delete takes its wallet, refused for the active/last wallet; both wallet deletes via AppBloc | unit + bloc + widget | `flutter test test/account/sdk_account_delete_coupling_test.dart test/components/wallet_information_delete_test.dart test/account/account_drawer_show_test.dart` | ❌ created in 05-T2/T3 |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] Extend `test/local_wallet_storage_test.dart` with link-map storage coverage
- [ ] Extend `test/account/sdk_add_account_test.dart` fake for the `_registerWallet`-routed SDK-form add
- [ ] New label-derivation test (`_mergeSgnusWallet` relabel)
- [ ] New `wallet_information.dart` delete-path widget test
- [ ] Test doubles: hand-rolled `implements GeniusApi` fakes (project convention; no new mocking framework)

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Linked/unlinked labels on a real node | VER-02 | Needs the live testnet; node currently stuck in `INITIALIZING_BLOCKCHAIN` | Build Windows debug, open SDK Accounts and the wallet menu, confirm each SDK account shows its wallet name + short address, old accounts linked or "Unlinked" |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Feedback latency < 120s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** approved 2026-09-29 (plan-checker)
