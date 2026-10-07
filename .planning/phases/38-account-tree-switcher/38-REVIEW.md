---
phase: 38-account-tree-switcher
reviewed: 2026-09-29T18:18:54Z
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
  warning: 2
  info: 0
  total: 2
status: resolved
---

# Phase 38: Code Review Report (Iteration 2)

**Reviewed:** 2026-09-29
**Depth:** standard
**Files Reviewed:** 8
**Status:** issues_found

## Summary

Re-review of the three fixes from `38-REVIEW-FIX.md` (`7d5372ef`, `8ad16386`, `4dfa5d9b`), verified against `git diff bb9a51fe..HEAD`, plus a fresh pass over the rest of the phase's files.

**WR-01 (`continue` instead of `return null` on a failed per-account registrations read)** is correct. Traced through `buildAccountTree`: a main whose read failed simply has no entry in the `registrations` map, so `buildAccountTree` treats it as "no children" for that main only (`registrations?[lower] ?? const []`), and `nestedUnderOwnMain` (built only from mains that DID succeed) correctly leaves that main's real children unnested rather than misplacing or duplicating them. No wrong nesting, no duplicate rows. One residual gap is noted below (WR-A).

**WR-02 (widened `_updateRegistrations` cache key to include `appState.wallets` and `appState.sdkAccountLinks`)** does not introduce a polling storm. `AppState.copyWith` is `x ?? this.x` on every field (`lib/bloc/app_state.dart:123-172`), and every `AppState` emit site in `app_bloc.dart` goes through `copyWith` (the only direct `AppState(...)` construction is the initial `super(const AppState())`). The 1-second processing-status ticker (`_onProcessingStatusTicked`) never passes `wallets:` or `sdkAccountLinks:` to `copyWith`, so both fields keep the same List/Map instance across every tick, and the record's `==` (identity-based, since neither `List` nor `Map` override `==`) sees no change. `wallets`/`sdkAccountLinks` only get new instances on account-mutating events (rename, delete, add/select SDK account) — exactly the cases the fix targets. Verified safe.

**WR-03 (locked-row alpha 0.5 -> 0.7)** is correct for the case its own new test covers (a resting, unselected row over `surfaceElevated`, matching `ResponsiveDrawer`'s real panel background at both `responsive_drawer.dart:142` and `:172/232`). One gap is noted below (WR-B): the fix and its test don't cover the combined selected+locked state.

Two warnings from this pass, both residual gaps around the three fixes rather than defects in the fixes themselves. No blockers.

## Warnings

### WR-A: All-accounts-failed read is now silently indistinguishable from "no children"

**File:** `lib/child_wallets/child_operations_cubit.dart:226-262` (interacts with `lib/account/account_drawer.dart:512-515`)

**Issue:** `ownRegistrations()` now `continue`s past each own account whose read fails instead of returning `null` for the whole map. That's correct when *some* accounts succeed (WR-01's fix). But when the node is running and *every* own account's read comes back non-OK (a real, if narrow, scenario — e.g. a momentary FFI hiccup right after start, or all reads racing a resync), the loop still returns a non-null, merely *empty* map (`<String, List<ChildWallet>>{}`), never `null`.

`_AccountDrawerBody` only shows its explanatory note ("Child wallets show while the node is running.") when `_registrations == null` (`account_drawer.dart:512`). An empty-but-non-null map renders identically to "the node genuinely reports zero registered children" — the one case this note exists to distinguish from a failed read is now the one case where the read failed completely. No test in `child_operations_cubit_test.dart`'s `ownRegistrations` group exercises "every account fails."

**Fix:** Distinguish "nothing read successfully" from "nothing to read" in the return value, e.g.:
```dart
Map<String, List<ChildWallet>>? ownRegistrations() {
  if (!_devMocked && runningAccount == null) {
    return null;
  }
  final appState = _readAppState();
  final result = <String, List<ChildWallet>>{};
  var anyOk = false;
  for (final main in appState.sdkAccounts) {
    final registrations = ...;
    if (!registrations.isOk) {
      continue;
    }
    anyOk = true;
    result[main.toLowerCase()] = [...];
  }
  return anyOk || appState.sdkAccounts.isEmpty ? result : null;
}
```
(The `appState.sdkAccounts.isEmpty` carve-out keeps a genuinely account-less user from seeing the note.)

### WR-B: Locked-row contrast fix and its regression test don't cover the selected+locked composite

**File:** `lib/account/account_drawer.dart:677-693, 805-814`; `test/account/account_drawer_locked_row_contrast_test.dart`

**Issue:** `selected` (this row's wallet is the active send/swap wallet) and `_locked` (this row's SDK account isn't the one currently running the node, while another account has a pending child operation) are independent flags — a merged row can be both at once (e.g. the user's default wallet is selected for sends, while a *different* SDK account is running the node with a fund/recover/revoke in flight). When `selected` is true, `GWSelectRow` paints its `_selectionTint` gradient (`gw_select_row.dart:80-84, 111`) instead of leaving the row transparent over `surfaceElevated` — a different, lighter background in dark mode than the one the new `account_drawer_locked_row_contrast_test.dart` measures against.

Working the same WCAG relative-luminance math the new test uses, but against the tint-over-`surfaceElevatedDark` background instead of bare `surfaceElevatedDark`, the composited `textSecondary@70%` foreground comes out to roughly **2.9:1** in dark mode — back under the 3:1 non-text floor this fix exists to clear, in the one state (selected *and* locked) the fix's own test doesn't exercise. Light mode is not at similar risk (the tint over a white `surfaceElevated` stays close to white).

**Fix:** Add a case to `account_drawer_locked_row_contrast_test.dart` (or a new test) that blends `textSecondary@0.7` over `Color.alphaBlend(_selectionTint sampled at some x, gw.surfaceElevated)` in dark mode, and if it doesn't clear 3:1, either bump the locked alpha further for this combination or drop the selection tint under the locked state (a locked row's own `lock_outline` icon and "Selected" badge already carry that signal).

---

_Reviewed: 2026-09-29T18:18:54Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
