---
phase: 34
slug: account-linking
status: draft
nyquist_compliant: false
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

| Requirement | Behavior | Test Type | Automated Command | File Exists |
|-------------|----------|-----------|-------------------|-------------|
| LINK-01 | `_registerWallet` captures the SGNUS↔ETH link on create/import; link storage round-trips public addresses only | unit | `flutter test test/local_wallet_storage_test.dart` | ❌ W0 (extend) |
| LINK-01 | SDK-form add also saves the wallet; re-entering an existing wallet links without duplicating | widget | `flutter test test/account/sdk_add_account_test.dart` | ❌ W0 (extend) |
| LINK-02 | `_mergeSgnusWallet` and SDK Accounts rows label linked accounts by wallet name + short address; "(wallet removed)" and "Unlinked" cases | unit + widget | new test under `test/bloc/` or `test/account/` | ❌ W0 |
| LINK-03 | Backfill links matchable old accounts without growing the account list; unmatched read "Unlinked" | unit | new backfill test against a hand-rolled `GeniusApi` fake | ❌ W0 |
| D-10..D-12 | All wallet deletes route through `AppBloc`; SDK-account delete removes the linked wallet; blocked for the active wallet | widget | new `test/components/wallet_information_delete_test.dart` | ❌ W0 |

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

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 120s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
