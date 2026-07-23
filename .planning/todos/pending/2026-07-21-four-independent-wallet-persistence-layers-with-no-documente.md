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

## Solution — RESOLVED 2026-07-22: documented recipe, NOT a code override

**`GW_DATA_DIR` was REJECTED by Jakub on 2026-07-22.** Do not propose it again. The accepted answer
is a documented, verified manual recipe:

### → `.planning/reference/FRESH-INSTALL-RECIPE.md`

That document supersedes the four-step list below, which was **measured wrong in two places** when
re-verified on 2026-07-22:

- **Layer 4 (`shared_preferences.json`) does not exist.** The only copies on this machine belong to
  unrelated "NoPing" software. There are three real layers on Windows, not four.
- **Layer 2 (`SuperGNUSNode.Node.*`) is currently absent** — zero directories, not the three this
  todo recorded. They accumulate one per SDK init, so the count is a function of how many wallets
  have been created since the last clear.

Also newly established: a **~310-byte `flutter_secure_storage.dat` is expected on a fresh profile**
and does not mean a wallet exists. `LocalWalletStorage.init()` writes an `__account__` entry on
every first launch regardless (`local_secure_storage_base.dart:72-77`). Size was previously read as
a wallet signal; it is not one on its own.

The accepted cost of rejecting the override: **the profile is consumed by every walk that completes
onboarding**, so the recipe re-runs per walk. That is a known, accepted trade, not an oversight.

---

<details>
<summary>Superseded four-step list (kept for the reasoning trail — use the recipe doc instead)</summary>

1. Delete `%USERPROFILE%\Documents\*.hive`
2. Delete `%USERPROFILE%\Documents\SuperGNUSNode.Node.*`
3. Delete `%APPDATA%\com.example\genius_wallet\flutter_secure_storage.dat`
4. Delete `%APPDATA%\com.example\genius_wallet\shared_preferences.json`

Note: `flutter_secure_storage` v9 on Windows stores in a file under `%APPDATA%`, not the Windows
Credential Manager — do not waste time searching Credential Manager (`cmdkey`) for this data.

</details>
