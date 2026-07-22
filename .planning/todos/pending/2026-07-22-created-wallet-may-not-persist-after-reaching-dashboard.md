---
created: 2026-07-22T00:00:00.000Z
title: A created wallet may not persist — dashboard reached, but no wallet on disk
area: general
severity: major
files:
  - lib/onboarding/new_wallet/routes/new_wallet_flow.dart
  - lib/onboarding/view/confirm_and_save_pin_screen.dart
  - packages/local_secure_storage/lib/src/local_secure_storage_base.dart
---

## The discrepancy — UNEXPLAINED, do not assume either way

During 06-05's walk (2026-07-22) the create-wallet flow was walked end to end and **the walker
reported reaching the dashboard**. But every persistence signal, checked minutes later with the app
still running and again after shutdown, says **no wallet exists**:

| Signal | After CREATE-wallet walk | After IMPORT walk (06-04, same day) |
|---|---|---|
| `SuperGNUSNode.Node.*` dirs | **0** | **1** |
| `transactions_0x*.hive` boxes | **0** | **2** |
| `flutter_secure_storage.dat` | **310 bytes** (account-only) | materially larger |
| `wallet.hive` | 0 bytes | 0 bytes (unreliable either way) |

The import path on the same machine, the same day, through the same PIN steps, **did** persist. The
create path did not.

The run log also contains `No suitable wallet found` and shows no dashboard/`getCoins`/balance
activity — though debug logging here is sparse enough that absence is weak evidence on its own.

## Why this matters

If it reproduces, a user can create a wallet, complete PIN setup, see the dashboard, restart the
app, and find no wallet — with their recovery phrase already dismissed. That is data loss on the
single most important flow in the product.

## What is NOT yet known

- Whether the wallet was genuinely never persisted, or persisted somewhere unchecked.
- Whether the walker reached a real dashboard or a transient post-onboarding state.
- Whether the ~9.6s SDK freeze / the known 52.5% `getInitializationStatus()` stall (Phase 13) leaves
  persistence half-done on the create path specifically — note the import path completes the same
  SDK init and DOES leave a node directory.

**No hypothesis above has been tested. None should be recorded as a cause.**

## First steps for whoever picks this up

1. Re-run the create-wallet flow on a cleared profile
   (`.planning/reference/FRESH-INSTALL-RECIPE.md`), reach the dashboard, then **without killing the
   app** check for `SuperGNUSNode.Node.*` and `transactions_0x*.hive`.
2. If still absent, restart the app and see whether it lands on onboarding or the dashboard. That
   single observation separates "not persisted" from "persisted somewhere unchecked".
3. Instrument `LocalWalletStorage.saveStoredKey` / the `PinConfirmPassed` handler — but note §3.3:
   **no logging may print key material.** Log the fact of a write, never the value.

## Effect on 06-05's record

`06-05-SUMMARY.md` initially recorded the create-wallet end-to-end as PASS and as closing ROADMAP
criterion 1's create half. **That claim has been downgraded** — the walker's observation is recorded
as made, alongside this contradicting filesystem evidence, and the criterion is NOT marked closed on
the create side. See the summary's "Unresolved" section.
