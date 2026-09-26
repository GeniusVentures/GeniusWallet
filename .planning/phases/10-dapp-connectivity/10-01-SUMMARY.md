---
phase: 10-dapp-connectivity
plan: 01
subsystem: dapp-connectivity
tags: [reown, walletkit, walletconnect_pay, flutter_secure_storage, windows]
requires: []
provides: [desktop WalletKit init that completes, reown_core 1.5.1 Windows relay fix, flutter_secure_storage v10 key store]
affects: [10-02, 10-03]
actuals: {tokens: 3500, tasks: 2, commits: 3}
tech-stack:
  added: [walletconnect_pay 1.1.0 (direct dep)]
  patterns: ["stubPayOnDesktop(): platform-interface override installed first in a singleton constructor"]
key-files:
  created: [test/reown/walletkit_init_test.dart]
  modified: [lib/reown/reown_walletkit_instance.dart, pubspec.yaml, packages/local_secure_storage/lib/src/local_secure_storage_base.dart, packages/local_secure_storage/pubspec.yaml, test/local_wallet_storage_test.dart]
key-decisions:
  - "D-09: bump reown_walletkit to ^1.5.1 now (option-a), guarded by resetOnError: false + migrateWithBackup: true"
requirements-completed: [SCR-06]
duration: 45min
completed: 2026-09-26
status: complete
---

# Phase 10 Plan 01: Desktop WalletKit Init Summary

**A no-op WalletconnectPayPlatform unblocks desktop WalletKit init, and reown_walletkit 1.5.1 lands the Windows relay fix with a v10 secure-storage key store.**

## Accomplishments
- `stubPayOnDesktop()` installs `_NoPayPlatform` on windows/macOS/linux before `ReownWalletKit` builds; mobile keeps `MethodChannelWalletconnectPay`. 11 tests pin both branches; live `flutter run -d windows` logs `✅ WalletKit initialized`, no `MissingPluginException`.
- reown_walletkit 1.5.1 (reown_core 1.5.1), walletconnect_pay 1.1.0, flutter_secure_storage 10.3.4; only version lines moved in the lock.
- `AndroidOptions` drops the deprecated `encryptedSharedPreferences` flag for `resetOnError: false, migrateWithBackup: true`.
- Windows key store backed up before/after; same wallet loaded post-bump, file untouched (no migration path on Windows); backup deleted per pass criterion.

## Task Commits
1. **Task 1: desktop Pay stub** - `e4c48ae6`
2. **Task 3: reown_walletkit 1.5.1 bump** - `699500d0` (Task 2 checkpoint:decision pre-decided: option-a, per D-09)

## Deviations from Plan
- `local_wallet_storage_test.dart`'s fake used `IOSOptions`/`MacOsOptions`; v10 merges both into `AppleOptions` (Rule 3). `dart format` wants to reformat all of `local_secure_storage_base.dart` — pre-existing drift confirmed present before this plan; left untouched, logged in `deferred-items.md`.
