---
phase: 38-account-tree-switcher
fixed_at: 2026-09-29T00:00:00Z
review_path: .planning/phases/38-account-tree-switcher/38-REVIEW.md
iteration: 2
findings_in_scope: 2
fixed: 2
skipped: 0
status: all_fixed
---

# Phase 38: Code Review Fix Report

**Fixed at:** 2026-09-29
**Source review:** .planning/phases/38-account-tree-switcher/38-REVIEW.md
**Iteration:** 2

**Summary:**
- Findings in scope: 2 (critical_warning: WR-A, WR-B)
- Fixed: 2
- Skipped: 0

## Fixed Issues

### WR-A: All-accounts-failed read was silently indistinguishable from "no children"

**Files modified:** `lib/child_wallets/child_operations_cubit.dart`, `test/child_wallets/child_operations_cubit_test.dart`
**Commit:** 2bf5c43f
**Applied fix:** `ownRegistrations()` now tracks whether any own account's read actually succeeded (`anyOk`). It still returns the partial map when at least one account resolves (unchanged from iteration 1's WR-01 fix) and still returns `null` when the node isn't running, but now also returns `null` when every own account's read failed (the carve-out `appState.sdkAccounts.isEmpty` keeps an account-less user from seeing the node-down note). Added a test proving `ownRegistrations()` is `null` when both accounts in the fixture read non-OK.

### WR-B: Locked-row contrast fix didn't cover the selected+locked composite

**Files modified:** `lib/account/account_drawer.dart`, `test/account/account_drawer_locked_row_contrast_test.dart`
**Commit:** c19b39ab
**Applied fix:** Bumped the three locked-row `gw.textSecondary.withValues(alpha: 0.7)` instances (title, subtitle, leading icon) to `0.8`. Computed the WCAG contrast of the composited foreground against `GWSelectRow`'s own selection-tint gradient (both stops, both appearance modes) using the same alpha-blend math the codebase's existing `account_row_badge_contrast_test.dart` uses for the identical background: at 0.7 the worst case (dark mode, one gradient stop) came out to ~2.84:1, under the 3:1 non-text floor; at 0.8 the worst case clears 3.26:1 in dark mode and 3.54:1 in light mode. Extended `account_drawer_locked_row_contrast_test.dart` with a second test per appearance mode that blends the dimmed foreground over each selection-tint stop (copied from `GWSelectRow._selectionTint`, matching the existing precedent in `account_row_badge_contrast_test.dart`) and asserts 3:1. Verified the new test fails at 0.7 and passes at 0.8; verified `GWMenuItem`'s own 0.7 disabled-item colour is untouched since menu items never sit under this tint.

## Verification

Ran in the main checkout (`workflow.use_worktrees` is `false` in `.planning/config.json`; no isolated worktree was created, per the documented opt-out).

- `dart format` on every touched file: no changes needed after fixes (one file needed reformatting after the initial edit, applied and re-verified).
- `bash tool/check_brace_style.sh`: clean, no output.
- `flutter analyze lib test`: No issues found.
- Targeted tests after each fix: all passed (`child_operations_cubit_test.dart` 68/68, `account_drawer_locked_row_contrast_test.dart` 4/4, full `test/account/` directory 127/127, `gw_select_row_test.dart` 9/9, `account_row_badge_contrast_test.dart` 6/6).
- Full `flutter test`: **2233 passed, 5 skipped, 0 failed** (baseline was 2230 passed / 5 skipped; the increase is the 3 new regression tests from this iteration).

No app build or run was performed, per instructions.

---

# Phase 38: Code Review Fix Report (Iteration 1)

**Fixed at:** 2026-09-29
**Source review:** .planning/phases/38-account-tree-switcher/38-REVIEW.md
**Iteration:** 1

**Summary:**
- Findings in scope: 3 (critical_warning: WR-01, WR-02, WR-03; IN-01 out of scope)
- Fixed: 3
- Skipped: 0

## Fixed Issues

### WR-01: One failed per-account registrations read blanked the whole tree

**Files modified:** `lib/child_wallets/child_operations_cubit.dart`, `test/child_wallets/child_operations_cubit_test.dart`
**Commit:** 7d5372ef
**Applied fix:** `ownRegistrations()`'s loop now `continue`s past a single own account's non-OK registrations read instead of returning `null` for the whole map. `null` is still returned when the node isn't running and no dev preset is armed (the original early-exit guard is untouched). Updated the existing test that asserted `null` on any one bad read to assert the working accounts still resolve, and added a case proving only the failed account's entry is missing.

### WR-02: Foreign-child rows showed a stale name/link/balance snapshot after a rename

**Files modified:** `lib/account/account_drawer.dart`, `test/account/account_drawer_tree_test.dart`
**Commit:** 8ad16386
**Applied fix:** Added `appState.wallets` and `appState.sdkAccountLinks` to `_updateRegistrations`'s memoization key tuple. Bloc state keeps the same list/map instance across an emit that doesn't touch those fields, so this is an identity check, not a per-build deep compare, and still invalidates the cached `_registrations` on a rename or link change. Added a widget test (`foreign child rename` group) that renames a foreign child's linked wallet mid-session and confirms the drawer's `ChildWalletRow` picks up the new name; verified the test fails without the fix (2 widgets briefly showing the old name -> assertion mismatch after rename) and passes with it.

### WR-03: Locked-row dimming still used 0.5 alpha, under the 3:1 non-text floor

**Files modified:** `lib/account/account_drawer.dart`, `test/account/account_drawer_locked_row_contrast_test.dart` (new)
**Commit:** 4dfa5d9b
**Applied fix:** Bumped the three `gw.textSecondary.withValues(alpha: 0.5)` locked-row instances (title, subtitle, leading icon) to `0.7`, matching `GWMenuItem`'s own disabled-item fix and its stated reasoning. Added a new contrast test mirroring the existing `gw_menu_item_test.dart` / `account_row_badge_contrast_test.dart` pattern, checking the composited locked-row foreground against `surfaceElevated` (the row's real background) clears 3:1 in both appearance modes. Verified the test fails at the old 0.5 alpha (2.18:1 light / 2.34:1 dark) and passes at 0.7.

## Verification

Ran in the main checkout (`workflow.use_worktrees` is `false` in `.planning/config.json`; no isolated worktree was created for this run, per the documented opt-out).

- `dart format` on every touched file: no changes needed after fixes.
- `bash tool/check_brace_style.sh`: clean, no output.
- `flutter analyze lib test`: No issues found.
- Targeted tests after each fix: all passed (`child_operations_cubit_test.dart`, `account_drawer_tree_test.dart`, `account_drawer_locked_row_contrast_test.dart`, plus the sibling account-drawer/menu-item suites).
- Full `flutter test`: **2230 passed, 5 skipped, 0 failed** (baseline noted as 2202+ passed / 5 skipped in 38-03's SUMMARY; the increase is the 3 new regression tests plus one pre-existing test rewritten in place, not a net change in coverage direction).

No app build or run was performed, per instructions.

---

_Fixed: 2026-09-29_
_Fixer: Claude (gsd-code-fixer)_
_Iteration: 2_
