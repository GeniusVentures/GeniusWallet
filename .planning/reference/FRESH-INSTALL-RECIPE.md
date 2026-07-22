# Fresh-install recipe (Windows) — how to get a genuinely wallet-less profile

**Status:** this is the ACCEPTED approach. The proposed `GW_DATA_DIR` dev override was **rejected by
Jakub on 2026-07-22** — do not propose it again. A documented, verified manual recipe is the answer.

**Verified by direct measurement on this machine 2026-07-22.** Where this document disagrees with
`todos/pending/2026-07-21-four-independent-wallet-persistence-layers-with-no-documente.md`, this
document is right — that todo was written from a painful live session and two of its four layers do
not exist here.

---

## ⛔ Do this first: do NOT touch Windows Credential Manager

`flutter_secure_storage` **v9 on Windows stores in a FILE**, not the Credential Manager. A
`cmdkey`-based search finds nothing relevant to this app.

On 2026-07-21 this was guessed wrong and **13 unrelated `SGNUS*` Credential Manager entries were
irreversibly deleted** chasing that hypothesis. Nothing in this recipe touches Credential Manager.
If you find yourself typing `cmdkey`, stop.

---

## Step 0 — Are you already fresh? (check before deleting anything)

Deletion is irreversible for layer 3. Check first — it is often unnecessary.

```powershell
"wallet.hive bytes : " + (Get-Item "$env:USERPROFILE\Documents\wallet.hive" -EA SilentlyContinue).Length
"secure store bytes: " + (Get-Item "$env:APPDATA\com.example\genius_wallet\flutter_secure_storage.dat" -EA SilentlyContinue).Length
"node dirs         : " + @(Get-ChildItem "$env:USERPROFILE\Documents\SuperGNUSNode.Node.*" -EA SilentlyContinue).Count
```

Reading the result:

| Signal | Fresh | Has a wallet | Reliability |
|---|---|---|---|
| `wallet.hive` | **0 bytes** — no `selectedWalletKey` written | non-zero | **strong** |
| `SuperGNUSNode.Node.*` count | **0** | ≥1 (one per SDK init) | **strong** |
| `flutter_secure_storage.dat` | small (hundreds of bytes) | materially larger | **weak — see below** |

**Why a non-empty `.dat` is still "fresh":** `LocalWalletStorage.init()`
(`packages/local_secure_storage/lib/src/local_secure_storage_base.dart:72-77`) calls
`createNewAccount()` whenever no account exists, so an `__account__` entry
(`{balance: 0.0, name: 'Genius', lastBalanceRetrievalDate: null}`) is written on **every** launch
that finds none, wallet or not. The file is encrypted and binary — you cannot read entry names out
of it.

⚠️ **Do not treat the byte count as a threshold.** Measured 2026-07-22 across a single session: the
file was **310 bytes** before 06-02's walk and **486 bytes** after — with `wallet.hive` still at 0
and still zero node directories, i.e. **no wallet was ever created.** Ordinary account/preference
writes move this number. Use `wallet.hive` and the node-directory count as the real signals; treat
`.dat` size only as a rough sanity check, never as proof either way.

**The definitive test is cheaper than any of this:** launch the app. A wallet-less profile lands on
`/landing_screen` (the "Create new wallet / I already have a wallet" entry). If you land on the
dashboard, you have a wallet.

---

## The four layers

Only layers 1–3 exist on Windows. Layer 4 is recorded in the old todo and **is not real here.**

| # | Location | Holds | Present 2026-07-22? |
|---|---|---|---|
| 1 | `%USERPROFILE%\Documents\*.hive` + `*.lock` | Hive boxes — `wallet`, `preferences`, `network`, plus caches | yes, 9 boxes |
| 2 | `%USERPROFILE%\Documents\SuperGNUSNode.Node.*` | native SuperGenius RocksDB node identity | **no — zero present** |
| 3 | `%APPDATA%\com.example\genius_wallet\flutter_secure_storage.dat` | **seeds, private keys, PIN** — the one that matters | yes, 310 B |
| 4 | ~~`shared_preferences.json`~~ | — | **DOES NOT EXIST.** The only copies on this box belong to unrelated "NoPing" software. Do not delete those. |

> `%APPDATA%\com.example\` is the scaffold namespace — `windows/runner/Runner.rc` still ships
> Flutter's placeholder `CompanyName`. Filed as its own todo; changing it MOVES the data directory
> and needs a migration, so it is not a quick fix.

---

## The recipe

**Close the app first.** Hive takes a single-process container lock; a stale instance makes the next
launch die in `initHive` with `lock failed … coingeckocache.lock`, which has previously been
misread as a rendering regression.

```powershell
# 1. Confirm nothing is running
Get-Process genius_wallet -EA SilentlyContinue | Stop-Process -Force

# 2. DRY RUN — see exactly what would go. Change to $false to actually delete.
$DryRun = $true

$targets = @(
  "$env:USERPROFILE\Documents\*.hive"
  "$env:USERPROFILE\Documents\*.lock"
  "$env:USERPROFILE\Documents\SuperGNUSNode.Node.*"
  "$env:APPDATA\com.example\genius_wallet\flutter_secure_storage.dat"
  "$env:USERPROFILE\Documents\overrides"
  "$env:USERPROFILE\Documents\*_config.json"
)

foreach ($t in $targets) {
  foreach ($i in @(Get-ChildItem -Path $t -Force -EA SilentlyContinue)) {
    if ($DryRun) { "WOULD DELETE: $($i.FullName)" }
    else { Remove-Item $i.FullName -Recurse -Force; "DELETED: $($i.FullName)" }
  }
}
```

Run it once with `$DryRun = $true`, read the list, then flip to `$false`.

The last two targets (`overrides\`, `*_config.json`) are the SDK's generated config; they are
regenerated on launch and are safe to drop. They are included because leaving them behind has
previously produced a half-reset profile.

---

## After the walk: the profile is CONSUMED

Completing onboarding recreates the wallet. **Any walk that needs first-run state starts from this
recipe again.** Phase 06 has several such plans (06-03 and 06-06 both need one), so budget for a
re-run per walk rather than assuming one clean profile covers the phase.

This is the known cost of rejecting `GW_DATA_DIR`. It is accepted, not overlooked.

---

## Run command for the walk

Flutter is **not on PATH**: `C:\Users\User\Documents\Projects\GNUS\flutter\flutter\bin`

```
CMAKE_ARGUMENTS="-DCMAKE_BUILD_TYPE=Release -DGENIUS_DEPENDENCY_BRANCH=develop -Dc-ares_DIR=C:/Users/User/Documents/Projects/GNUS/thirdparty/build/Windows/Release/cares/lib/cmake/c-ares" flutter run -d windows --debug --dart-define=GW_DEV_TOOLS=true
```

`GW_DEV_TOOLS=true` gives you the dev bubble, which carries the in-place light/dark toggle the walk
needs for its LIVE FLIP check.
