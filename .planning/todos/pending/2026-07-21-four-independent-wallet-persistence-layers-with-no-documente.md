---
created: 2026-07-21T17:46:37.483Z
title: Four independent wallet persistence layers with no documented reset
area: general
severity: major
files:
  - packages/genius_api/lib/src/genius_api.dart:362-367
---

## Problem

GeniusWallet persists a wallet across **four independent stores**, and clearing any subset leaves the
wallet intact. There is no documented reset. Established empirically today: it took **four attempts**
to reach a genuine fresh install, each failing because another layer restored the wallet.

| # | Location | Holds |
|---|---|---|
| 1 | `%USERPROFILE%\Documents\*.hive` | Hive boxes (wallet, transactions, prefs, caches) |
| 2 | `%USERPROFILE%\Documents\SuperGNUSNode.Node.*` | Native SuperGenius RocksDB node identity — **three** had accumulated (07-11, 07-16, 07-18) |
| 3 | `%APPDATA%\com.example\genius_wallet\flutter_secure_storage.dat` | **seeds, private keys, PIN** |
| 4 | `%APPDATA%\com.example\genius_wallet\shared_preferences.json` | preferences |

**The critical detail that cost three of the four attempts:** `flutter_secure_storage` v9 on Windows
stores in a **FILE** under `%APPDATA%`, *not* the Windows Credential Manager. A `cmdkey`-based search
finds nothing relevant. (13 `SGNS*` Credential Manager entries were deleted on a wrong hypothesis
before the real store was found — record that so nobody repeats it.)

**Why it matters:** `06-06`'s walk explicitly requires a cleared profile **per run**, and five Phase 6
walks remain. Doing this by hand is slow, error-prone and — for layer 3 — irreversible.

## Solution

Propose a dev-only `GW_DATA_DIR` override (dart-define, gated `kDebugMode && kShowDevTools` so it
constant-folds out of release) pointing all four layers at a scratch directory, making a fresh
install equal deleting one folder. Note layer 2 is set by the **native** SDK via the base path, so
the override must reach `genius_api`'s `prepareConfigFiles()`
(`packages/genius_api/lib/src/genius_api.dart:362-367`) and not just the Dart side.

Also record the manual four-step recipe as the interim fallback:
1. Delete `%USERPROFILE%\Documents\*.hive`
2. Delete `%USERPROFILE%\Documents\SuperGNUSNode.Node.*`
3. Delete `%APPDATA%\com.example\genius_wallet\flutter_secure_storage.dat`
4. Delete `%APPDATA%\com.example\genius_wallet\shared_preferences.json`

Note: `flutter_secure_storage` v9 on Windows stores in a file under `%APPDATA%`, not the Windows
Credential Manager — do not waste time searching Credential Manager (`cmdkey`) for this data.
