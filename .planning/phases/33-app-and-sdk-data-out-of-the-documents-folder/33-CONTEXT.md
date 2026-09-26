# Phase 33: App and SDK data out of the Documents folder - Context

**Gathered:** 2026-09-26
**Status:** Ready for planning

<domain>
## Phase Boundary

On Windows and Linux, NEW installs keep all app and SDK data in the app's own local data folder
instead of loose in the user's Documents. EXISTING installs are left exactly where they are. No
data is moved, copied or deleted. Android, iOS and macOS are untouched (their "Documents" is
already app-private).

Three places choose the folder today, all via `getApplicationDocumentsDirectory()`:
- `packages/genius_api/lib/src/genius_api.dart:374` `prepareConfigFiles()`: SDK base path (node
  store `SuperGNUSNode.Node.*`, `secure_storage_id`, `my_tasks.json`, `ipfs_cache/`, config JSONs,
  `sgnslog*.log`, `overrides/`)
- `lib/hive/init.dart:27` `Hive.initFlutter()`: every Hive box, including per-wallet `transactions_<addr>`
- `lib/main.dart:42` `_attachSdkLogsToHint`: reads the SDK logs for Sentry

SDK private keys are not in Documents (Credential Manager / Keychain / KeyStore), only the
public-key account list. This phase is about data location, not key custody.

</domain>

<decisions>
## Implementation Decisions

### No migration
- **D-01:** New installs use the new folder; existing installs keep using Documents indefinitely.
  Nothing is moved, copied or deleted. This removes the rename/lock/partial-failure/rollback
  problems entirely. — **Reversibility:** reversible — a later phase could still migrate old installs.

### Existing vs new install
- **D-02:** Decided at every start with one rule: if the Documents folder already holds the app's
  data (the Hive wallet box `wallet.hive`, or the SDK account list `secure_storage_id`), this is an
  existing install and ALL three consumers use Documents. Otherwise all three use the new folder. A
  reinstall on a machine that still has old wallets in Documents therefore keeps finding them.
- **D-03:** One resolver decides the folder, and all three consumers read it (SDK base path, Hive,
  Sentry log attachment), so they can never disagree. It runs before Hive opens.

### New folder
- **D-04:** Windows: `%LOCALAPPDATA%\GeniusVentures\GeniusWallet`. It's machine-local (the node
  databases must not roam between PCs), and deliberately NOT Flutter's default
  `%APPDATA%\com.example\genius_wallet` (roaming, and the leftover scaffold name). Linux:
  `$XDG_DATA_HOME/GeniusWallet`, falling back to `~/.local/share/GeniusWallet`. Created on first use.

### Claude's Discretion
- How the resolver finds `%LOCALAPPDATA%` / XDG paths (env vars vs a path_provider call), as long
  as the result is exactly D-04.
- Updating `.planning/reference/FRESH-INSTALL-RECIPE.md` so its deletion steps cover both locations.

</decisions>

<canonical_refs>
## Canonical References

- `packages/genius_api/lib/src/genius_api.dart` `prepareConfigFiles()`: SDK base path
- `lib/hive/init.dart`: Hive initialisation
- `lib/main.dart` `_attachSdkLogsToHint`: Sentry log attachment
- `.planning/reference/FRESH-INSTALL-RECIPE.md`: the documented reset procedure; lists the Documents paths
- `.planning/todos/pending/2026-07-21-com-example-scaffold-namespace-ships-as-the-secure-storage-d.md`: related `com.example` naming debt (out of scope here)

</canonical_refs>

<code_context>
## Existing Code Insights

- Hive is opened through `Hive.initFlutter()` with no path; `Hive.init(path)` takes an explicit folder.
- The SDK takes its whole working tree from the base path passed in `prepareConfigFiles()`.
- `path_provider` is already a dependency.

</code_context>

<specifics>
## Specific Ideas

- One runnable check: the resolver picks Documents when `wallet.hive` or `secure_storage_id` exists
  there, and the new folder otherwise (temp directories, no real user data).

</specifics>

<deferred>
## Deferred Ideas

- Migrating existing installs out of Documents: explicitly not wanted now (D-01).
- Renaming the `com.example` namespace / secure-storage data directory: its own todo.

</deferred>

---

*Phase: 33-app-and-sdk-data-out-of-the-documents-folder*
*Context gathered: 2026-09-26*
