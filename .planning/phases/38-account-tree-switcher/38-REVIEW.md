---
phase: 38-account-tree-switcher
reviewed: 2026-09-29T00:00:00Z
depth: standard
files_reviewed: 8
files_reviewed_list:
  - lib/account/account_drawer.dart
  - lib/account/account_tree.dart
  - lib/account/sdk_account_manager.dart
  - lib/child_wallets/child_operations_cubit.dart
  - lib/child_wallets/child_wallets_screen.dart
  - lib/components/overlays/gw_menu_item.dart
  - lib/theme/genius_wallet_colors.dart
  - lib/theme/gw_colors.dart
findings:
  critical: 0
  warning: 3
  info: 1
  total: 4
status: issues_found
---

# Phase 38: Code Review Report

**Reviewed:** 2026-09-29
**Depth:** standard (with the deep, cross-file checks the workflow prompt called out explicitly)
**Files Reviewed:** 8
**Status:** issues_found

## Summary

Reviewed the merged "Accounts" switcher (`account_drawer.dart`, `account_tree.dart`), the extracted SDK-account dialogs (`sdk_account_manager.dart`), the new `ownRegistrations()` read on `ChildOperationsCubit`, the shared `GWMenuItem`, and the `ChildWalletsScreen` refactor to use it, plus the two colour-token files.

Diffed `lib/account/account_drawer.dart` and `lib/account/sdk_account_manager.dart` against `a0b21989` line by line: every menu action that existed pre-phase (Copy address, Rename, Delete on a plain wallet row; Set payout address, Copy recovery phrase, Show recovery QR, View balance, Child wallets, Delete account on an SDK row) is still present and still gated by the same `sdkRowActions` rule. "Run node as this" moved from the row's `onTap` into the row's menu, and "Selected" moved from the SDK row's own state onto whichever wallet is active — both per the phase's own D-04/D-05, not a regression. No unreachable action found.

Traced `buildAccountTree`/`visibleAccountRows` by hand against the merge, nesting, cycle-breaking and collapse rules in their own doc comments (D-07/D-09/D-10): the visited-set, three-pass placement (merged non-nested, unclaimed non-nested, cycle sweep) and depth-first collapse skip all hold up — no scenario found where an account is dropped or doubled. Confirmed tapping a row only ever calls `Navigator.pop(wallet)` (never touches the node account) and "Run node as this" only ever dispatches `SelectSDKAccount` (never pops a wallet), and that the running-account pending lock (`hasPendingFrom`) is computed once and applied uniformly to every non-running row, exempting the running row via `!onNode`.

Found no BLOCKER. Three WARNINGs, all inside the new tree/registrations plumbing, none of them in the parts already exercised by the pre-existing `ChildWalletRow`/`ChildOperationsCubit` code paths.

## Warnings

### WR-01: One failed per-account registrations read blanks the whole tree, unlike the Child wallets screen's per-main read

**File:** `lib/child_wallets/child_operations_cubit.dart:225-261`
**Issue:** `ownRegistrations()` loops every one of the user's own SDK accounts and calls `_api.getChildRegistrations(main)` for each; the moment any single account's read comes back non-OK, the whole method returns `null` (line ~239: `if (!registrations.isOk) { return null; }`). In `account_drawer.dart` this flows straight into `buildAccountTree(registrations: _registrations)`, and a `null` registrations map means the entire tree renders flat with the "Child wallets show while the node is running" note (D-11) — even for accounts whose own registrations read succeeded.

The Child wallets screen (`ChildWalletsScreen`/`ChildWalletsCubit`) reads registrations for one main at a time, scoped to whichever account is running. A transient FFI hiccup on account C's read has no effect on the screen showing account A's children correctly. In the switcher, the same transient hiccup on C hides A's nesting, A's "On node"/pending badges, and A's nested Fund/Recover/Revoke menu items too — a much larger blast radius for the same failure, and a direct divergence from "the same locks, pending badges" parity the phase context calls for (D-06).

**Fix:** Build the result map incrementally and skip (rather than abort) an individual main's entry on a non-OK read, or track per-main failure and only flatten the affected subtree:
```dart
Map<String, List<ChildWallet>>? ownRegistrations() {
  if (!_devMocked && runningAccount == null) {
    return null;
  }
  final appState = _readAppState();
  final result = <String, List<ChildWallet>>{};
  for (final main in appState.sdkAccounts) {
    final registrations = _devMocked ? ... : _api.getChildRegistrations(main);
    if (!registrations.isOk) {
      continue; // this main's own children are simply not resolved this pass
    }
    result[main.toLowerCase()] = [ ... ];
  }
  return result;
}
```
(Returning `null` only when the running account itself can't be read, not when an unrelated own account's read fails.)

### WR-02: Foreign-child rows (and nested own rows' Fund/Recover/Revoke payload) show a stale name/link/balance snapshot after a rename

**File:** `lib/account/account_drawer.dart:181-241` (`_registrationsKey`/`_updateRegistrations`), `lib/account/account_tree.dart:40-43` (`AccountTreeRow.child`), `lib/child_wallets/child_operations_cubit.dart:242-259` (`ChildWallet` construction inside `ownRegistrations()`)
**Issue:** `_updateRegistrations` only recomputes `_registrations` when `(selectedSDKAccount, sdkAccounts.join(','), operations?.state, devPreset)` changes. `appState.sdkAccountLinks` and `appState.wallets` are **not** part of that key, yet `ownRegistrations()` bakes `AppBloc.sdkAccountName(...)`, `AppBloc.linkedWallet(...)` and a balance read into each `ChildWallet` at read time.

Own rows (`AccountRowKind.merged`/`.account`) are unaffected — their title in `_AccountRowTile.build` is recomputed fresh from `appBloc.state` every build, not from the cached `ChildWallet`. But every `AccountRowKind.foreignChild` row renders via `ChildWalletRow(wallet: row.child!, ...)` (`account_drawer.dart:518-522`), and `row.child` **is** the cached snapshot. Rename the wallet linked to someone else's registered child (or watch its balance move) while the switcher's registrations haven't otherwise been invalidated, and the row keeps showing the old name/avatar/balance until some unrelated key component changes (an account switch, a dev-preset flip, or a `ChildOperationsCubit` state emission).

The same stale `ChildWallet` is also what gets passed as `child:` to `startFund`/`startRecover`/`startRevoke` for a **nested own** row (`account_drawer.dart:1059-1101`, via `row.child!`), so a Fund/Recover/Revoke confirmation launched from the tree can carry a stale name/balance into that flow too, not just the read-only display.

**Fix:** Add `appState.sdkAccountLinks` (or a cheap hash of it) and a marker for `appState.wallets` identity to the `_updateRegistrations` key, or — simpler — always re-derive `name`/`linkedWallet` for a `ChildWallet` at render/menu-build time from current `AppState` rather than baking them in at read time, keeping only the address (and balance, which is genuinely expensive) in the cached snapshot.

### WR-03: Locked-row dimming still uses 0.5 alpha, sub-3:1, right next to a sibling fix in the same phase that bumped the identical token to 0.7 for exactly this reason

**File:** `lib/account/account_drawer.dart:675, 684, 805`
**Issue:** `GWMenuItem` (new in this phase, `lib/components/overlays/gw_menu_item.dart:38-44`) explicitly moved its disabled-item colour from `alpha: 0.5` to `alpha: 0.7`, with a comment stating 0.5 "clears only 2.10:1 (light) / 2.32:1 (dark) -- under the 3:1 non-text floor." The `_AccountRowTile`'s own locked-row title (`675`), subtitle (`684`) and leading icon (`805`) still use `gw.textSecondary.withValues(alpha: 0.5)` — the exact combination just proven to fail 1.4.11/1.4.3 in the sibling component. This is carried over verbatim from the pre-phase `SDKAccountRow`, but the phase's own D-13 ("both appearance modes meet WCAG AA... including disabled menu items") and the fact that this exact file just fixed the same token elsewhere make it a live, provable contrast defect this phase touched without closing.
**Fix:** Use the same 0.7-alpha (or a dedicated `textMutedOnSunken`/similar AA-safe token) for the three locked-row instances that `GWMenuItem` now uses for its disabled items, so the row and its own menu agree on what "locked" looks like.

## Info

### IN-01: `AccountOperations`/`ChildOperationsState` has no `Equatable`/`==` override, relied on for cache-key identity

**File:** `lib/child_wallets/child_operations_cubit.dart:107-115`, consumed at `lib/account/account_drawer.dart:230-234`
**Issue:** `_updateRegistrations`'s memoization key includes `operations?.state` (a `ChildOperationsState`). Because that class has no `==`/`hashCode` override, the key comparison is really "is this the same emitted instance," which happens to be correct today because `resolve()`/`submit()` only ever emit a genuinely new instance on a real change and return early otherwise (`resolve()`'s `if (!changed) return;`). This works, but it is fragile: any future edit that emits a new `ChildOperationsState` instance without an actual content change (e.g. a defensive re-emit) would silently start invalidating `_registrations` on every rebuild. Not a current bug, just worth a comment or an `Equatable` mixin so the correctness doesn't depend on an implicit invariant in a different file.
**Fix:** Either mix in `Equatable` on `ChildOperationsState`/`ChildOperation`, or add a one-line comment on the `_registrationsKey` tuple noting it depends on `ChildOperationsCubit` never emitting a same-content instance.

---

_Reviewed: 2026-09-29_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
