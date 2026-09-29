# Phase 38: Account tree switcher - Research

**Researched:** 2026-09-29
**Domain:** Flutter state-tree UI restructuring over an existing bloc/cubit stack; no new library, no new network surface
**Confidence:** HIGH — every claim below is read directly from the files this phase touches, not inferred

## Summary

Phase 38 does not add a technology. It restructures `account_drawer.dart`'s two flat sections
("Sending from" / "Node running as") into one nested list, reusing `GWSelectRow`, `GWRowBadge`,
`SDKAccountRow`'s menu gates, and `ChildWalletsScreen`'s child-row menu verbatim. The 38-UI-SPEC.md
already specifies the component reuse in detail; this research answers the mechanical questions the
UI-SPEC assumes answered: what today's drawer actually renders (so nothing is lost), how a merged
row is computed today, whether `GeniusApi.getChildRegistrations` can be read for a non-running
account, and how to avoid spinning up N pollers for N own accounts.

**Key finding, directly answering the phase's hardest open question:** `GeniusApi.getChildRegistrations(mainAddress)`
takes `mainAddress` as a plain parameter and is gated only on `_isSdkInitialized` — it is **not**
restricted to the currently-selected/running account. `ChildWalletsCubit._findParentMain` already
calls it once per one of the user's *other* own SDK accounts on every 10s poll, proving this in
production code today. So the switcher's per-open registrations pre-read (D-07) can read every own
account's registrations regardless of which one the node runs as, exactly as `_findParentMain`
already does — forward instead of reverse, per the UI-SPEC's Component Inventory row.

**Second key finding:** `ChildWalletsCubit` is not an app-root singleton — it is created per-route
in `router.dart:218`, scoped to one main address, and starts its own `Timer.periodic(10s)` poller.
Creating one `ChildWalletsCubit` per own account to feed the tree would mean N independent 10s
pollers. The correct shape (and what the UI-SPEC's "Registrations pre-read" row already specifies)
is a **direct, cubit-free call** to `GeniusApi.getChildRegistrations`/`DevMockChildWallets.registrationsFor`
from `_AccountDrawerBody` itself — one one-shot pass per drawer-open and per `ChildOperationsCubit.justResolved`
signal, mirroring `_findParentMain`'s own direct-call pattern, not `ChildWalletsCubit`'s pattern.

**Primary recommendation:** Follow 38-UI-SPEC.md's Component Inventory exactly — it already
prescribes the pure-function tree model, the direct (non-cubit) registrations pre-read, and full
reuse of `GWSelectRow`/`ChildWalletRow`'s menu items. This research's job is to hand the planner the
exact call sites, signatures, and one dev-mock gotcha the UI-SPEC does not spell out (see Pitfall 1).

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Account tree construction (nesting, dedup, depth) | Frontend (pure Dart model, `lib/account/account_tree.dart`) | — | No SDK/BuildContext dependency by design (Claude's Discretion in CONTEXT.md) — a pure function is unit-testable without a live node |
| Registrations read (per own account) | Frontend → native SDK via `genius_api` FFI | — | `GeniusApi.getChildRegistrations` is a synchronous FFI call on the main isolate, already how `ChildWalletsCubit`/`_findParentMain` read it |
| Row rendering, menus, badges | Frontend (Flutter widgets) | — | `GWSelectRow`, `GWRowBadge`, `MenuAnchor` — all existing, reused unchanged per UI-SPEC |
| Pending-operation locks (SWT-06, child ops) | Frontend (`ChildOperationsCubit`, app-root singleton) | — | Already the one source of truth for locks; the tree's foreign-child leaf rows and "Run node as this" reuse it, not a new lock |
| Child balance / registration source of truth | Native SDK (via FFI) / dev mock in debug builds | — | No backend/server tier in this app; the SDK node IS the backend |

## Standard Stack

No new package. This phase composes existing `gw_*` primitives and existing cubits.

| Component | Location | Role in this phase |
|-----------|----------|---------------------|
| `GWSelectRow` | `lib/components/cards/gw_select_row.dart` | Every account row (own wallet, merged, unlinked, nested) — unchanged |
| `GWRowBadge` | `lib/components/data/gw_row_badge.dart` | "On node" (renamed from "ACTIVE ON NODE"), "SDK PENDING" — unchanged |
| `ChildOperationsCubit` | `lib/child_wallets/child_operations_cubit.dart` | Locks, `hasPendingFrom`, `labelFor`, `justResolved` signal — app-root singleton (`main.dart:429`), already reachable from the drawer |
| `GeniusApi.getChildRegistrations` / `getChildBalanceAll` | `packages/genius_api/lib/src/genius_api.dart:1629,1646` | Direct SDK reads, no cubit wrapper needed |
| `DevMockChildWallets` | `lib/dev/dev_mock_child_wallets.dart` | Dev-gated substitute for both calls above — see Pitfall 1 for its behavior on a non-running main |
| `startFund`/`startRecover`/`startRevoke` | `lib/child_wallets/child_operation_dialogs.dart:34,101,162` | Reused directly for foreign-child leaf rows, no new dialog |

**Installation:** none — no `pubspec.yaml` change.

## Package Legitimacy Audit

Not applicable. This phase adds zero external dependencies.

## Architecture Patterns

### Data flow for one drawer open (traced from the code, not assumed)

```
AccountDrawer.show(context)
  -> _AccountDrawerBody.build()
       -> BlocBuilder<AppBloc, AppState>            // wallets, sdkAccounts, sdkAccountLinks,
                                                     // selectedSDKAccount, defaultSDKAccount
       -> context.watch<ChildOperationsCubit?>()     // app-root singleton, nullable-typed today
       -> [NEW] per-account registrations pre-read:
            for each address in appState.sdkAccounts:
              if kDebugMode && kShowDevTools && DevMockChildWallets.instance.preset.value != null:
                  DevMockChildWallets.registrationsFor(preset, appState, address)
              else if appState.defaultSDKAccount != null:   // node running (any account)
                  api.getChildRegistrations(address)          // synchronous FFI, no await
              else:
                  skip -> flat list + D-11 note
       -> [NEW] buildAccountTree(ownWallets, sdkAccounts, sdkAccountLinks,
                                  defaultAccount, selectedWallet, selectedSDKAccount,
                                  registrationsByMain)          // pure function, lib/account/account_tree.dart
       -> render List<AccountTreeRow>, each -> GWSelectRow (+ chevron if isMain)
```

`AppBloc._mergeSgnusWallet()` (`lib/bloc/app_bloc.dart:813-833`) already runs independently, every
time the SDK connects: it builds one synthetic `Wallet(walletType: sgnus)` per `api.getAvailableAccounts()`
entry and prepends them to `_baseWallets`. `_AccountDrawerBody.build()` filters these back out
(`account_drawer.dart:511-513`, `w.walletType != WalletType.sgnus`) before building `ownWallets` —
the drawer today reaches an sgnus wallet's balance only via `SDKAccountRow`'s "View balance" menu
item, never as a row of its own. Phase 38 keeps this filter: sgnus wallets are never tree rows; an
SDK account's row is still resolved from `appState.sdkAccounts` (the address list), and its badge/
linkage is still `AppBloc.linkedWallet`/`sdkAccountName`, exactly as today.

### Pattern: resolving "does this SDK account already have a row" (today's mechanism, reused)

```dart
// lib/bloc/app_bloc.dart:745-762 — the ONE place "is this SDK account already
// shown on a wallet row" is decided today. Phase 38's `AccountTreeRow.kind`
// discriminator (mergedOwnAccount vs unlinkedOwnAccount) is this same check,
// just consumed by a tree builder instead of two independent loops.
static Wallet? linkedWallet(
  String sdkAddress,
  Map<String, SDKAccountLink> links,
  List<Wallet> wallets,
) {
  final link = links[sdkAddress.toLowerCase()];
  if (link == null) return null;
  for (final wallet in wallets) {
    if (wallet.walletType != WalletType.sgnus &&
        wallet.walletType != WalletType.tracking &&
        wallet.address.toLowerCase() == link.walletAddress) {
      return wallet;
    }
  }
  return null;
}
```

`SDKAccountLink` (`packages/local_secure_storage/lib/src/local_secure_storage_base.dart:18`) is
`typedef SDKAccountLink = ({String walletAddress, String walletName});` — a record, keyed by
lowercased SDK address in `Map<String, SDKAccountLink>`. `AppState.sdkAccountLinks` carries this map
(`lib/bloc/app_state.dart:93`).

### Pattern: the existing recursive-parent-lookup shape to mirror (not reuse directly)

`ChildWalletsCubit._findParentMain` (`lib/child_wallets/child_wallets_cubit.dart:211-228`) is the
exact shape D-07/D-09 want, just inverted (it looks for ONE parent of ONE account; the tree needs
to build the whole forest of the user's OWN accounts):

```dart
// child_wallets_cubit.dart:211-228 (read in full, HEAD)
String? _findParentMain(AppState appState, DevChildWalletsPreset? devPreset) {
  final subject = state.mainAddress.toLowerCase();
  for (final account in appState.sdkAccounts) {
    if (account.toLowerCase() == subject) continue;
    final registrations = _registrationsFor(account, appState, devPreset);
    if (!registrations.isOk) continue;
    if (registrations.entries.any(
      (entry) => entry.childAddress.toLowerCase() == subject,
    )) {
      return account;
    }
  }
  return null;
}
```

This is the file's own `ponytail:` comment: "one registrations read per own account per poll — fine
for a handful of SDK accounts; upgrade path is an SDK by-child query." The switcher's pre-read
inherits the identical cost shape and the identical ceiling (D-09 already states this as the phase's
own accepted ceiling).

### Anti-Patterns to Avoid

- **Do not instantiate `ChildWalletsCubit` per own account to feed the tree.** Each instance starts
  its own `Timer.periodic(10s)`-poller (`child_wallets_cubit.dart:90`) and its own `DevMockChildWallets`
  listener. N own accounts would mean N independent pollers doing the same FFI work the drawer could
  do once, synchronously, on open. Call `GeniusApi.getChildRegistrations`/`DevMockChildWallets.registrationsFor`
  directly instead, exactly as `_findParentMain` already does.
- **Do not re-derive "is this SDK account linked" with new logic.** `AppBloc.linkedWallet`/
  `sdkAccountName` are the one source of truth; `walletSDKBadge` (`account_drawer.dart:111-126`) is
  the one source for the SDK/SDK-PENDING distinction. A parallel implementation would drift the moment
  either changes.
- **Do not gate the registrations pre-read on `appState.selectedSDKAccount != null` alone.** That
  gate only proves the NODE is running as *some* account; `getChildRegistrations` will happily answer
  for any `mainAddress` argument once the SDK is initialized at all. Gating the whole pre-read on
  "is the node running" (per D-07/D-11), not on "is this specific account the one running," is
  correct and is what the existing `_findParentMain` does today.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Chevron expand/collapse | A new disclosure widget | Plain `IconButton` + local `Set<String> _collapsedMains` (per UI-SPEC) | D-10's lifetime is the open drawer only — no persistence, no new state management needed |
| Foreign-child leaf row + its menu | A new leaf row widget | `ChildWalletRow`'s existing shape, or a `ChildWallet` value built from the tree row and handed to the same `startFund`/`startRecover`/`startRevoke` | `child_wallets_screen.dart:266-409` already has every lock, badge and dialog wired; duplicating it risks the locks drifting apart from `/child-wallets`'s own |
| Menu-item dimming/disabled recipe | New disabled-item styling | `GWMenuItem` (UI-SPEC's Rule-of-Three promotion of `sdk_account_manager.dart`'s `_menuItem` + `child_wallets_screen.dart`'s `_ChildActionMenuItem`) | Both existing versions already solved icon/label dimming consistently (`sdk_account_manager.dart:236-`) |
| SWT-06 lock check | A new "is this account free to switch to" function | `ChildOperationsCubit.hasPendingFrom(running)` (`child_operations_cubit.dart:211-215`) | Already the exact check `account_drawer.dart:529-535` uses today for the pre-merge SDK section |

**Key insight:** every mechanism this phase needs already exists somewhere in `lib/account/` or
`lib/child_wallets/`. The work is composition (one tree model + one rendering pass) over reused
parts, not new logic — which is also why the UI-SPEC frames nearly every Component Inventory row as
"unchanged component."

## Runtime State Inventory

Not applicable — pure UI/state restructuring, no rename/rebrand/storage-key migration. No Hive
box, SOPS key, or OS registration changes name or schema; `SDKAccountLink`/`AppState` unchanged.

## Common Pitfalls

### Pitfall 1: `DevMockChildWallets` only returns fixture children for the RUNNING main

`DevMockChildWallets.registrationsFor` (`lib/dev/dev_mock_child_wallets.dart:184-217`) computes
`isRunningMain = app.selectedSDKAccount == null || app.selectedSDKAccount!.toLowerCase() ==
mainAddress.toLowerCase()` and only attaches fixture children (`oneChild`/`threeChildren`) when
`isRunningMain` is true — any OTHER own account still reads `RET_OK` but with an empty list. The
mock was built for `/child-wallets`, which only ever asks about one main. **Effect:** D-09's
recursive nesting under these presets can only ever be exercised one level deep (under whichever
account is running); deeper nesting needs a new preset (`DevChildWalletsPreset` is a plain enum,
already invites a sixth value). Document as an accepted test gap, or add the preset.

### Pitfall 2: node-down dev preset gives every own account the SAME fixture set

When `app.selectedSDKAccount == null`, `isRunningMain` is `true` for every `mainAddress` (the `||`
short-circuits on the null check alone) — a preset armed with the node down (a real, reachable path;
`devPreset` explicitly bypasses `ChildWalletsCubit.refresh`'s own not-running check, lines 111-128)
makes every own account appear to have identical fixture children. **How to avoid:** D-09's
"already placed" dedup rule absorbs this for free — only the first account processed (in
`appState.sdkAccounts` order) keeps the fixture children, the rest are deduped as already-placed.
Add a unit test seeded exactly this way (preset armed, `selectedSDKAccount: null`, 2+ own accounts)
to confirm `buildAccountTree` actually behaves this way rather than duplicating the row.

### Pitfall 3: don't drop a menu item during the SDK-row -> merged-row unification

`SDKAccountRow`'s menu has six items total (payout, phrase, qr, view balance, child wallets,
delete — `sdkRowActions` gates five of them); the wallet row's menu has three (copy, rename,
delete). The merged row's menu must keep all nine actions reachable from some row kind without
silently dropping one. "View balance" has no obvious home once a wallet's own balance already
shows inline on its merged row — flag for the planner/discuss-phase whether it stays (harmless) or
is dropped, rather than silently deciding either way. Before repointing any item, grep call sites of
`sdkRowActions`, `_confirmRenameWallet`, `_confirmDeleteWallet`, `_confirmDeleteSDKAccount` (each
called from exactly one place today) to confirm none end up orphaned.

### Pitfall 4: keep the two selection keys separate on a merged row

`_matchesSelected` (`account_drawer.dart:286-293`) matches `(address.toLowerCase(), walletType)`,
not name, specifically because two rows can share a name. A merged row must expose two DIFFERENT
identity keys: the owning wallet's `(address, walletType)` for the "Selected" comparison against
`WalletDetailsCubit`'s `selectedWallet`, and the SDK address itself for the "On node" comparison
against `selectedSDKAccount` — collapsing these into one key breaks D-03's independence guarantee.

## Code Examples

`startFund`/`startRecover`/`startRevoke` (`child_operation_dialogs.dart:34,101,162`) each take a
`ChildWallet` value (`address`, `name`, `linkedWallet`, `balanceGnus`), not raw strings, and each
opens with `ensureRunningAs(context, mainAddress)` (the switch-and-continue dialog D-06 reuses) —
a foreign-child leaf row must construct a `ChildWallet` from its own already-resolved tree-row
fields, exactly as the UI-SPEC's Component Inventory specifies. `sdkRowActions`
(`sdk_account_manager.dart:542-553`) is the one function gating the six-item SDK menu (payout,
phrase, qr, view balance, child wallets, delete) and must be called unchanged, fed `isSelected:
isActiveOnNode` per the UI-SPEC, not re-derived.

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|---------------|--------|
| Two independent flat sections ("Sending from" / "Node running as") | One "Accounts" tree, two independent tags per row | This phase | Fewer scrolls to see a full account picture; no behavior change to the two underlying selections (D-04 keeps them independent) |
| "ACTIVE ON NODE" badge label | "On node" badge label | This phase (D-03) | Every test string-matching `'ACTIVE ON NODE'` breaks; see Verification section |

**Deprecated/outdated:** none — this is a same-milestone UI evolution (Phase 35 → 38), not a
migration off an old library or pattern.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | "View balance" becomes dead/redundant once an SDK account merges onto its own wallet's row | Pitfall 3 | Low — worst case the planner keeps the item as a harmless no-op-looking duplicate; flagged explicitly as a question for the planner/discuss step rather than asserted as fact |

Every other claim in this document was read directly from a file opened this session (see Sources)
or run through a grep confirming a call site — none are `[CITED]` (no external docs were consulted;
this is a wholly in-repo research task) and none beyond A1 are `[ASSUMED]`.

## Open Questions

1. **Does "View balance" survive on a merged own-wallet row, or only on the unlinked-SDK row?**
   - What we know: today it is one of `SDKAccountRow`'s six menu items, ungated (`onPressed: balanceWallet != null`), and exists specifically because the SDK section and the wallet section were SEPARATE — tapping it selected the sgnus wallet whose balance the SDK row's own wallet doesn't otherwise show inline.
   - What's unclear: once a merged row already shows its own wallet's balance inline (as every `_buildDrawerRow` today does), does "View balance" still do useful work, or does it become a menu item that points back at the row it's already on?
   - Recommendation: the plan should keep it on the merged row's menu (cheapest, zero behavior loss, matches D-13's "never lose a row/menu action") unless discuss-phase decides it's confusing.

2. **Does the tree need to guard against an own account that is a main to itself transitively through a cycle of 3+ accounts (A registers B, B registers C, C registers A)?**
   - What we know: D-09 already specifies "a cycle... stops at the first placement," and the tree is walked over a small, finite `appState.sdkAccounts` list.
   - What's unclear: whether a 3-cycle is reachable at all given `ChildOperationsCubit.submit`'s own `selfReferential` guard (`child_operations_cubit.dart:320-329`) only blocks a DIRECT self-reference (A registering itself, or a move to the main it already has) — it does NOT block a 3-hop cycle at submit time.
   - Recommendation: since D-09 already specifies the defensive behavior (first placement wins, no duplication, no infinite loop) regardless of cycle length, `buildAccountTree`'s recursion should track a "seen" set across the whole walk, not just per-branch — this naturally covers any cycle length with no extra design needed. Flagged so the planner writes a test for a 3-cycle, not just a 2-cycle.

## Environment Availability

Not applicable — this phase touches only Dart/Flutter code already present in the repo (no new CLI,
service, or runtime dependency). The live-testnet walk this phase's success criteria call for is
explicitly deferred per the run constraints for this research pass (no build/run performed) and per
the project's standing VER-02 precondition (testnet currently stuck in `INITIALIZING_BLOCKCHAIN`,
recorded as a blocked gap in other v3.0 phases already).

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | `flutter_test` (bundled with the Flutter SDK) |
| Config file | none — no `dart_test.yaml`; tests run via `flutter test` |
| Quick run command | `flutter test test/account/account_drawer_show_test.dart test/account/account_drawer_network_section_test.dart` |
| Full suite command | `flutter test` (full repo baseline; Flutter SDK is not on `PATH` by default in this environment per project memory) |

### Existing tests that WILL break on this phase's rename (must be updated, not just re-run)

| File | What breaks | Why |
|------|-------------|-----|
| `test/account/account_drawer_show_test.dart` (942 lines) | `find.text('ACTIVE ON NODE')` assertions at lines 791, 875, 888, 895 | D-03/UI-SPEC rename the badge to "On node" |
| `test/account/account_drawer_show_test.dart` | Any test asserting on `_AccountSectionHeader` titles "Sending from" / "Node running as" (both currently rendered per `account_drawer.dart:555-556,580-581`) | D-01 collapses both into one "Accounts" header |
| `test/account/account_drawer_network_section_test.dart` (612 lines) | Same header-title assertions, if any target the two section titles rather than the network section | Same D-01 collapse |

### Tests that stay green (reused component, not touched)

| File | Why unaffected |
|------|-----------------|
| `test/child_wallets/child_wallets_screen_test.dart` (1092 lines) | `/child-wallets` screen itself is explicitly kept per CONTEXT.md's Phase Boundary; its menu/lock logic is REUSED, not modified |
| `test/dev/dev_mock_child_wallets_test.dart` | `DevMockChildWallets` itself is unmodified by this phase; only a new consumer (the drawer's pre-read) is added |

### Phase Requirements -> Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| SWT-07 (D-01/D-02) | One "Accounts" list; SDK account shown once on its wallet's row; unlinked SDK gets its own row; watch-only never offers "On node" | widget | `flutter test test/account/account_drawer_show_test.dart` | Partial — existing file needs new cases, not a new file |
| SWT-07 (D-04/D-05) | Tap selects "Selected" only; "Run node as this" in menu, refused under SWT-06 | widget | same file | Partial — existing SWT-06 lock test (`account_drawer_show_test.dart` `hasPendingFrom` coverage) needs a companion case for the renamed menu item |
| SWT-07 (D-07/D-08/D-09) | Nesting, dedup, cycle-safety, foreign-child leaves | unit | new `test/account/account_tree_test.dart` against pure `buildAccountTree` | ❌ Wave 0 — new file, matches CONTEXT.md's "pure function... testable without the SDK" discretion |
| SWT-07 (D-06) | Child-row menu (Fund/Recover/Revoke) reachable from a nested foreign-child leaf | widget | extend `account_drawer_show_test.dart` or a new focused file | ❌ Wave 0 |
| SWT-07 (D-11) | Flat list + note when node down / registrations fail | widget | same file, using `DevChildWalletsPreset.nodeNotRunning`/`queryError` | Partial — presets already exist, new assertions needed |

### Sampling Rate

- **Per task commit:** `flutter test test/account/ test/child_wallets/`
- **Per wave merge:** full `flutter test`
- **Phase gate:** full suite green before `/gsd-verify-work`, plus the live-testnet walk (VER-02),
  recorded as a blocked gap if testnet is still stuck.

### Wave 0 Gaps

- [ ] `test/account/account_tree_test.dart` — new file, covers the pure `buildAccountTree` model
  (D-07/D-08/D-09): normal nesting, zero-own-accounts-registered, a 2-cycle, a 3-cycle (Open
  Question 2), and the dev-preset-with-no-selected-account duplicate-fixture case (Pitfall 2).
- [ ] Update `test/account/account_drawer_show_test.dart`'s `'ACTIVE ON NODE'` assertions (4 sites)
  to `'On node'`.
- [ ] Update or add section-header assertions for the collapsed "Accounts" header replacing "Sending
  from"/"Node running as".
- [ ] Framework install: none — `flutter_test` is already the project's only test framework.

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|----------------|---------|-------------------|
| V2 Authentication | no | This phase adds no auth surface |
| V3 Session Management | no | No session concept touched |
| V4 Access Control | yes | Menu-item gating (`sdkRowActions`, `ChildOperationsCubit.hasPendingFrom`, `_isChildSide`) — reused unchanged; the tree must not introduce a new path that bypasses these gates (e.g., a nested row rendering a menu item its un-nested counterpart would have disabled) |
| V5 Input Validation | no (reused) | No new user-entered value; amounts/addresses still validated by `parseGnusAmount`/`isEvmAddress` in the reused dialogs |
| V6 Cryptography | no | No key material touches this surface; mnemonic/QR flows are reused unchanged from `SDKAccountRow` |

### Known Threat Patterns for this stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|----------------------|
| A nested own-account row rendering an action its un-nested counterpart would gate off (e.g., showing "Delete account" on the running account's nested row) | Elevation of Privilege | UI-SPEC's own rule: "nesting is position only, never available actions" — the merged menu's gates (`can.delete`, `can.payout`, etc.) must be computed identically regardless of `depth`, never re-derived from tree position |
| A foreign-child leaf row exposing Fund/Recover/Revoke against a `ChildWallet` value constructed from stale tree data (address/balance captured at drawer-open, used minutes later) | Tampering (stale-state) | `startFund`/`startRecover`/`startRevoke` already call `registry.resolve()` before acting and re-read balances live inside their own dialogs (`_AmountDialog`) — the tree only supplies address/name for display and menu routing, never a balance the write itself trusts |
| Registrations pre-read exposing another own account's children to a wallet screen that never asked for them | Information Disclosure | Not applicable — all accounts queried are the user's OWN SDK accounts (`appState.sdkAccounts`), same trust boundary as `/child-wallets` already crosses for the running account |

## Sources

### Primary (HIGH confidence) — every file read this session, HEAD

`lib/account/account_drawer.dart` (799 lines, full), `lib/account/sdk_account_manager.dart` (822
lines, full), `lib/account/account_switcher.dart` (78 lines, full), `lib/child_wallets/child_wallets_cubit.dart`
(238 lines, full), `lib/child_wallets/child_wallets_screen.dart` (451 lines, full),
`lib/child_wallets/child_operations_cubit.dart` (585 lines, full), `lib/child_wallets/child_operation_dialogs.dart`
(first 100 lines + signature grep for the rest), `lib/dev/dev_mock_child_wallets.dart` (337 lines,
full), `lib/bloc/app_bloc.dart:630-860` (targeted: `linkedWallet`, `sdkAccountName`,
`_mergeSgnusWallet`, `sdkDeleteBlock`, `canDeleteWallet`), `lib/bloc/app_state.dart` (219 lines,
full), `lib/components/cards/gw_select_row.dart` (185 lines, full), `lib/components/data/gw_row_badge.dart`
(39 lines, full), `packages/genius_api/lib/src/genius_api.dart:100-220,1560-1670` (`ChildRegistrations`,
`getChildRegistrations`, `getChildBalanceAll`, `getSelectedAccountMnemonic`),
`packages/local_secure_storage/lib/src/local_secure_storage_base.dart:18` (`SDKAccountLink` typedef),
`packages/genius_api/lib/types/wallet_type.dart` (full), `lib/main.dart:429` (`ChildOperationsCubit`
app-root singleton), `lib/navigation/router.dart:218` (`ChildWalletsCubit` route-scoped),
`test/account/account_drawer_show_test.dart`/`account_drawer_network_section_test.dart`/
`test/child_wallets/child_wallets_screen_test.dart` (structure + string-site grep),
`.planning/phases/38-account-tree-switcher/38-CONTEXT.md`+`38-UI-SPEC.md`, `.planning/REQUIREMENTS.md`,
`.planning/ROADMAP.md`, `.planning/config.json`, `AGENTS.md`.

### Secondary / Tertiary

None — no web search or external documentation was needed; this is a closed, in-repo restructuring
task and every claim traces to a file opened this session.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — no new library; every component cited was opened and read this session
- Architecture: HIGH — data flow traced through actual call sites (`main.dart:429`, `router.dart:218`, `_findParentMain`), not inferred from the UI-SPEC's prose alone
- Pitfalls: HIGH for Pitfalls 1/2 (traced through `DevMockChildWallets`'s actual conditional logic); MEDIUM for Pitfall 3/Open Question 1 (a genuine design judgment call, correctly logged as `[ASSUMED]`/open rather than asserted)

**Research date:** 2026-09-29
**Valid until:** indefinite for the architectural findings (read from code only this phase's own
plan will change); re-verify the two `DevMockChildWallets` pitfalls if that file changes first.
