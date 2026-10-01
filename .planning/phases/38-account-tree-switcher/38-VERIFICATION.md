---
phase: 38-account-tree-switcher
verified: 2026-09-29T20:00:00Z
status: human_needed
score: 26/27 truths verified (1 failed on a phase-gate integrity check; 0 present-but-behavior-unverified)
behavior_unverified: 0
overrides_applied: 0
gaps:
  - truth: "New files created by this phase use LF line endings (explicit rule repeated in every 38-0N-PLAN.md context block, and 38-03's own Task 3 acceptance criterion: \"`git ls-files --eol` shows `i/lf` for every file this phase created\")"
    status: closed
    reason: >
      test/account/account_drawer_tree_test.dart and test/account/account_tree_test.dart were both
      created with pure LF endings in the commits that added them (8fa53f3c: 307 LF/0 CRLF;
      0f51ac98: 205 LF/0 CRLF, confirmed by reading the raw git blob at each commit). Both were
      silently rewritten to pure CRLF in 8318083d ("test(38-02): merged-row tests" — every line in
      both files, not just new ones) and have stayed CRLF through every later commit including the
      final 30cf1c5c. `git ls-files --eol` on the current tree reports `i/crlf w/crlf` for both
      files. 38-VALIDATION.md's 38-03-03 row and 38-03-SUMMARY.md both assert the phase-gate check
      passed ("every phase-created file `i/lf`"); that claim is false for 2 of the 6 files this
      phase created. This project has a documented precedent (a prior incident write-up) of a CRLF
      Dart file passing every local check yet failing CI's mawk-based brace-style check, so this is
      a live regression risk, not a cosmetic one — and, independent of that risk, it is a phase-gate
      claim in 38-VALIDATION.md/38-03-SUMMARY.md that does not match the codebase.
    artifacts:
      - path: test/account/account_drawer_tree_test.dart
        issue: "Committed as CRLF since 8318083d; the plan's stated 'New files use LF endings' rule and the Task 3 gate check are both violated"
      - path: test/account/account_tree_test.dart
        issue: "Same CRLF regression, introduced in the same commit"
    missing:
      - "Normalize both files to LF and recommit (e.g. re-save with an LF-only editor, or `git config core.autocrlf false` then rewrite and re-add — do not use a bulk sed across the repo, only these two files)"
      - "Re-run `git ls-files --eol test/account/account_drawer_tree_test.dart test/account/account_tree_test.dart` and confirm `i/lf` before re-asserting the phase-gate check is green"
---

# Phase 38: Account tree switcher Verification Report

**Phase Goal:** The switcher shows one list of the user's accounts, each wallet row carrying its linked SDK account, with children nested under their main. Two tags mark the independent selections: "Selected" (wallet features) and "On node" (the account the node runs as).
**Verified:** 2026-09-29
**Status:** human_needed (the one code gap, CRLF test files, was closed by normalizing them to LF; `git ls-files --eol test/account test/bloc` shows only `i/lf`)
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths — ROADMAP Success Criteria

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | "Sending from"/"Node running as" replaced by one list; a linked SDK account appears once on its wallet's row; an unlinked account gets its own row; a watch-only wallet never offers "On node" | ✓ VERIFIED | One `_AccountSectionHeader(title: 'Accounts', ...)` (`account_drawer.dart:502`), no other section header for accounts; `buildAccountTree`'s `merged`/`wallet`/`account` kinds (`account_tree.dart:72-218`) enforce one row per linked account (tests: `account_tree_test.dart:236-350`); a `wallet`-kind row's menu (tracking wallets are never merged, since `AppBloc.linkedWallet` never returns one) offers only Copy address/Rename/Delete — no "Run node as this" item exists for that kind (`account_drawer.dart:948-968`) |
| 2 | Tapping a row selects it ("Selected"); "Run node as this" lives in the row menu, is refused with a reason while a child op from the running account is pending, never changes "Selected" | ✓ VERIFIED | Row `onTap` only pops a `Wallet` via `Navigator.of(context).pop(target)` (`account_drawer.dart:659-669`); `SelectSDKAccount(` has exactly 1 call site in the file, inside the menu's "Run node as this" `onPressed` (`:979-987`), gated `onNode \|\| _locked ? null : ...`; `_locked` reads `lockedReason` computed from `operations.hasPendingFrom(running)` (`:463-469`) |
| 3 | While the node runs, own children nest under their main instead of duplicating; a non-own child is an unselectable row; node down = flat list with a one-line note | ✓ VERIFIED | `buildAccountTree`'s depth-first walk with one `visited` set (`account_tree.dart:118-215`), cycle/self-listing/second-main tests (`account_tree_test.dart:150-234`); the wallet-order bug (a linked child never nesting when its wallet came first) is fixed and regression-tested (`account_tree_test.dart:352-375`, commit `d40050e4`); foreign children render as `ChildWalletRow` (not selectable, only the Child-actions menu) (`account_drawer.dart:523-527`); `_registrations == null` renders `_AccountSectionNote('Child wallets show while the node is running.')` (`:512-515`) |
| 4 | Child rows' menus offer Fund, Recover and Revoke through the same pending registry/locks as the Child wallets screen, which stays | ✓ VERIFIED | Nested own rows (depth ≥ 1 with a `ChildWallet` entry) add Fund/Recover/Revoke via `startFund`/`startRecover`/`startRevoke` after a divider, gated by `balanceLockReason`/`isPending` (`account_drawer.dart:1060-1110`); `lib/child_wallets/child_wallets_screen.dart` is untouched in structure (still present, still the canonical child-ops screen) |
| 5 | Desktop and mobile use the same list; both appearance modes meet WCAG AA; dev-bubble presets drive the tree | ✓ VERIFIED | One `_AccountDrawerBody` renders for both breakpoints (no separate mobile/desktop widget); `account_row_badge_contrast_test.dart` (12 tests, both modes) and `account_drawer_locked_row_contrast_test.dart` prove 4.5:1/3:1 floors, including the selected+locked composite found in code review and fixed (`c19b39ab`); `preset.addListener`/`removeListener` gated `kDebugMode && kShowDevTools` (`account_drawer.dart:199-211`), 1 add + 1 remove, matching `ChildWalletsCubit`'s own idiom |

**Score (roadmap-level):** 5/5 verified in code and by passing tests. (The CRLF gap below is a phase-gate integrity issue, not a failure of any of these 5 criteria.)

### Observable Truths — Plan-level must_haves

| Plan | Truth (paraphrased) | Status | Evidence |
|------|----------------------|--------|----------|
| 01 | An own child registered under another own account nests one level under it, never duplicated at top level | ✓ VERIFIED | `account_tree_test.dart:66-107`; drawer-level proof `account_drawer_tree_test.dart` tracer group |
| 01 | A foreign child shows as a non-selectable leaf with Fund/Recover/Revoke via the shared registry | ✓ VERIFIED | `ChildWalletRow(wallet: row.child!, mainAddress: row.parentMain!)` (`account_drawer.dart:524-527`); reuses `/child-wallets`' own locks/badges |
| 01 | Any cycle length, self-listing, or double registration places each account once; walk terminates | ✓ VERIFIED | `account_tree_test.dart:150-234` (2-cycle, 3-cycle, double-registration, self-listing) |
| 01 | Indentation caps at two levels | ✓ VERIFIED | `left: min(row.depth, 2) * GeniusWalletConsts.space12` (`account_drawer.dart:521`) |
| 01 | One "Accounts" section; flat+note when registrations unavailable; "No wallets yet." when empty | ✓ VERIFIED | `account_drawer.dart:502-517`; `grep -c "Child wallets show while the node is running."` = 1; the two old "Sending from"/"Node running as" notes are gone (`grep -ciE "sending from\|node running as"` = 0) |
| 01 | An armed CHILD WALLETS preset drives nesting through DevMockChildWallets; no SDK read while armed | ✓ VERIFIED | `ownRegistrations()`'s `_devMocked ? DevMockChildWallets.registrationsFor(...) : _api.getChildRegistrations(...)` branch (`child_operations_cubit.dart:230-236`) |
| 01 | Registrations read on open and again only on running-account/account-list/registry-state/preset change | ✓ VERIFIED | `_updateRegistrations`'s key tuple, widened by WR-02 to also include `wallets`/`sdkAccountLinks` (`account_drawer.dart:226-245`) |
| 01 | (backstop) First-main-wins nesting, cycle-safe | ✓ VERIFIED | Same tests as above; not left on backstop-only trust |
| 02 | Linked account merges onto its wallet's row only; unlinked/removed-wallet gets its own row; watch-only never merges | ✓ VERIFIED | `account_tree_test.dart:236-350` |
| 02 | Tapping any row never switches the node; "Run node as this" does, disabled on the On-node row | ✓ VERIFIED | See roadmap SC2 evidence |
| 02 | "Selected"/"On node" tags, independently computed, both on one row or split across two | ✓ VERIFIED | `_rowSelected`/`_rowOnNode` (separate address/wallet comparisons); `account_drawer_tree_test.dart` phone-width test asserts both tags on Main C's row simultaneously |
| 02 | "Run node as this" disabled + tooltip while a child op from the running account is pending | ✓ VERIFIED | `lockedReason` plumbed into `GWMenuItem(lockedReason: ...)` |
| 02 | Every old menu action still reachable, gated the same way | ✓ VERIFIED | `sdkRowActions(isSelected: onNode, ...)` reused verbatim (`sdk_account_manager.dart:306-316`); grep counts for `showSetPayoutAddressDialog`/`copyRecoveryPhrase`/`showRecoveryQr`/`confirmDeleteSDKAccount` all = 4 |
| 02 | Tag colours are AA-passing GWColors tokens | ✓ VERIFIED | `brandPrimaryBadgeText`/`statusSuccessText`; contrast tests pass in both modes |
| 02 (prohibition) | MUST NOT dispatch `SelectSDKAccount` from a row tap | ✓ VERIFIED | `grep -c "SelectSDKAccount("` = 1, and that 1 site is inside the menu, not `onTap` |
| 02 (prohibition) | MUST NOT enable phrase/QR/payout on a non-On-node row | ✓ VERIFIED | `sdkRowActions(isSelected: onNode, ...)`; mnemonic itself is only read (`appBloc.api.getSelectedAccountMnemonic()`) when `onNode` is true |
| 03 | Nested own rows keep Fund/Recover/Revoke with the same locks/badges/timeout/switch dialog | ✓ VERIFIED | `account_drawer_tree_test.dart` "nested own row child actions" group (multiple tests: lock text, pending badge, switch-dialog path) |
| 03 | Mains show a chevron, start expanded, collapse hides the whole subtree for the switcher's lifetime only | ✓ VERIFIED | `account_drawer_tree_test.dart` "collapsible mains" group, including the reopen-forgets-collapse test |
| 03 | An account that is both child and main nests with its own chevron one level deeper | ✓ VERIFIED | `account_tree_test.dart:86-107` (grandchild, hasChildren true on both ancestors) |
| 03 | Live refresh re-nests without reopening; preset changes repaint an open switcher | ✓ VERIFIED | `account_drawer_tree_test.dart` "live refresh and phone width" group — revoke resolves and removes its row with no reopen |
| 03 | 360px 4-deep chain: no overflow, consistent indent | ✓ VERIFIED | Same group's phone-width test asserts `right <= 360` for all 4 rows and equal indent for the deepest pair |
| 03 | AA in both modes for tags and disabled menu items | ✓ VERIFIED | `account_row_badge_contrast_test.dart`, `gw_menu_item_test.dart`; two real gaps (badge-on-tint, disabled-item-on-surfaceMenu) found and fixed with new tokens (`brandPrimaryBadgeText`, disabled alpha 0.7) |
| 03 | No loading state by construction (synchronous read) | ✓ VERIFIED | No `FutureBuilder`/`CircularProgressIndicator`/`isLoading` anywhere in `account_drawer.dart` |

**Score:** 26/27 (5 roadmap SCs + 22 plan-level truths, all independently checked against current HEAD source and passing tests) — 1 failed (phase-gate LF claim), 0 present-but-behavior-unverified.

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `lib/account/account_tree.dart` | `AccountRowKind`, `AccountTreeRow`, `buildAccountTree`, `visibleAccountRows` | ✓ VERIFIED | 250 lines; pure, no Flutter/BuildContext import (`grep -cE "package:flutter/(material\|widgets)"` = 0) |
| `lib/child_wallets/child_operations_cubit.dart` `ownRegistrations()` | Keyed SDK/dev-mock read, null on node-down/all-fail | ✓ VERIFIED | Lines 218-262; partial-failure and all-failure cases both tested |
| `lib/components/overlays/gw_menu_item.dart` | `GWMenuItem` | ✓ VERIFIED | Promoted per Rule of Three; used by wallet, SDK and child menus alike |
| `lib/account/sdk_account_manager.dart` public dialogs | `showSetPayoutAddressDialog`, `copyRecoveryPhrase`, `showRecoveryQr`, `confirmDeleteSDKAccount` | ✓ VERIFIED | 4 top-level `Future<void>` functions, called from the merged row menu |
| `test/account/account_tree_test.dart` | Nesting, cycle, dedup, merge unit tests | ✓ VERIFIED (content); ✗ FAILED (line-ending gate) | 444 lines, comprehensive; but committed as pure CRLF since `8318083d`, violating the phase's own new-file LF rule |
| `test/account/account_drawer_tree_test.dart` | Tree through the real drawer, collapse, live refresh, phone width, contrast | ✓ VERIFIED (content); ✗ FAILED (line-ending gate) | 1012 lines, comprehensive; same CRLF regression |
| `.planning/phases/38-account-tree-switcher/38-VALIDATION.md` | Per-task verification map, phase gate | ⚠️ Contains a false claim | Row 38-03-03 asserts "every phase-created file `i/lf`" — false for the two files above |

### Key Link Verification

| From | To | Via | Status | Details |
|------|-----|-----|--------|---------|
| `account_drawer.dart` | `child_operations_cubit.dart` | `operations?.ownRegistrations()` | ✓ WIRED | `account_drawer.dart:245` |
| `account_drawer.dart` | `account_tree.dart` | `buildAccountTree(...)` / `visibleAccountRows(...)` | ✓ WIRED | `:473-482`, 1 call site each |
| `account_drawer.dart` | `child_wallets_screen.dart` | `ChildWalletRow(...)` for foreign leaves | ✓ WIRED | `:524-527`, 1 call site |
| `account_drawer.dart` | `sdk_account_manager.dart` | `sdkRowActions(...)` gates | ✓ WIRED | `:950`, 1 call site |
| `account_drawer.dart` | `lib/bloc/app_bloc.dart` | `SelectSDKAccount(...)` from "Run node as this" only | ✓ WIRED | `:980`, 1 call site, inside the menu not `onTap` |
| `child_wallets_screen.dart` | `gw_menu_item.dart` | `GWMenuItem(...)` for child actions | ✓ WIRED | 3 call sites, matches acceptance criterion |
| `account_drawer.dart` | `child_operation_dialogs.dart` | `startFund`/`startRecover`/`startRevoke(...)` on nested own rows | ✓ WIRED | `:1075-1103` |
| `account_drawer.dart` | `dev_mock_child_wallets.dart` | gated `preset.addListener`/`removeListener` | ✓ WIRED | `:204, 211` |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
|----------|---------------|--------|---------------------|--------|
| Tree rows | `treeRows` | `buildAccountTree(wallets: appState.wallets, sdkAccounts: appState.sdkAccounts, links: appState.sdkAccountLinks, registrations: _registrations)` — all four inputs from live `AppState`/`ChildOperationsCubit` | Yes | ✓ FLOWING |
| `_registrations` | keyed read | `operations?.ownRegistrations()`, itself backed by `_api.getChildRegistrations` or the dev mock | Yes | ✓ FLOWING |
| "Selected"/"On node" tags | `_rowSelected`/`_rowOnNode` | Compared against `WalletDetailsCubit.state.selectedWallet` and `appState.selectedSDKAccount` | Yes | ✓ FLOWING |
| Nested-row Fund/Recover/Revoke pending badges | `pendingOps` | `operations.operationsFor(sdkAddress)` reading live `ChildOperationsCubit.state.operations` | Yes | ✓ FLOWING |

No hardcoded/static fallback found in any traced value.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Full targeted suite (`test/account/`, `test/child_wallets/`, `test/components/gw_menu_item_test.dart`) | `flutter test test/account/ test/child_wallets/ test/components/gw_menu_item_test.dart` | `+282: All tests passed!` | ✓ PASS |
| `flutter analyze lib test` | (run directly by this agent) | `No issues found!` | ✓ PASS |
| Full suite (established independently, not narrated from SUMMARY) | `flutter test` | `+2233 ~5: All tests passed!` (2233 passed, 5 skipped, 0 failed — matches 38-REVIEW-FIX.md iteration 2's quoted count exactly) | ✓ PASS |
| Line-ending gate on phase-created files | `git ls-files --eol <6 phase-created files>` | 4 `i/lf`, 2 `i/crlf` (`account_tree_test.dart`, `account_drawer_tree_test.dart`) | ✗ FAIL |
| Brace-style script (local) | `bash tool/check_brace_style.sh` | clean, exit 0 | ✓ PASS (locally — does not prove CI's mawk parses the CRLF files the same way; see gap) |

### Probe Execution

Not applicable — no `scripts/*/tests/probe-*.sh` convention in this project; this phase is a Flutter UI phase verified by `flutter test`/`flutter analyze`, per BLD-02's standing condition.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|--------------|--------|----------|
| SWT-07 | 01, 02, 03 (all three) | Accounts as one list, children nested under their main, "Selected"/"On node" tags | ✓ SATISFIED | All 5 roadmap SCs and 22 plan-level truths verified above |

**No orphaned requirements.** REQUIREMENTS.md maps only SWT-07 to Phase 38 (`.planning/REQUIREMENTS.md:321`), and all three plans declare exactly that ID in frontmatter. No other v3.0 requirement is claimed by this phase.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `test/account/account_drawer_tree_test.dart` | whole file | Committed with CRLF line endings, contradicting the phase's own stated "New files use LF endings" rule | 🛑 Blocker (gate integrity) | 38-VALIDATION.md/38-03-SUMMARY.md assert this check passed; it did not. Documented project precedent (a prior incident) ties CRLF Dart files to CI-only brace-check failures that never reproduce locally |
| `test/account/account_tree_test.dart` | whole file | Same CRLF regression, same introducing commit (`8318083d`) | 🛑 Blocker (gate integrity) | Same as above |

No `TBD`/`FIXME`/`XXX`/`TODO`/`HACK`/`PLACEHOLDER` markers, no "coming soon"/"not yet implemented" wording, and no hardcoded-empty stub patterns found in any of the 8 files this phase touched (`lib/account/account_drawer.dart`, `lib/account/account_tree.dart`, `lib/account/sdk_account_manager.dart`, `lib/child_wallets/child_operations_cubit.dart`, `lib/child_wallets/child_wallets_screen.dart`, `lib/components/overlays/gw_menu_item.dart`, `lib/theme/genius_wallet_colors.dart`, `lib/theme/gw_colors.dart`). The one `ponytail:` comment present (`ownRegistrations`'s one-read-per-account note, `child_operations_cubit.dart:222-223`) is an accepted, named ceiling with a stated upgrade path, matching D-09 — not debt.

The two ID-pattern matches found in `account_drawer.dart` (`D-06` at line 327, `04-02 D-02` at line 1237) both predate this phase (introduced by `21a7f4f8` and `d3f1122c` respectively, both from earlier phases) — not a phase 38 leak. `git diff 8fa53f3c~1..HEAD -U0 -- lib test | grep '^+' | grep -cE 'D-[0-9]{2}|(CHILD|PEND|SWT|VER|LINK)-0[0-9]|3[4-8]-0[0-9]|[Pp]hase 3[4-8]'` returns 0, confirmed independently.

### Human Verification Required

These are standing, cross-phase VER-02 items already recorded in `38-VALIDATION.md`'s "Manual-Only Verifications" and consistent with phases 34-37's own human-needed status — listed here for completeness, not counted as phase 38's blocking gap (the CRLF finding is):

### 1. Live-testnet walk with a real registered child, desktop and phone

**Test:** Open the switcher with a live node and at least one registered child.
**Expected:** The child nests under its main exactly as the unit/widget tests predict.
**Why human:** Testnet is recorded stuck in `INITIALIZING_BLOCKCHAIN`; this agent cannot run the app or reach a live node.

### 2. Each CHILD WALLETS dev preset against an open switcher

**Test:** In a `GW_DEV_TOOLS` debug build, open the switcher and press each preset in the dev bubble.
**Expected:** The tree repaints to match the preset without closing the switcher.
**Why human:** The preset listener is compiled out under `flutter test`'s `kShowDevTools=false`; only a real debug build exercises it. (The gating logic itself — add/remove under the same `kDebugMode && kShowDevTools` check — is verified by source inspection.)

### 3. Light-mode visual pass

**Test:** Toggle appearance with the switcher open at both phone and desktop width.
**Expected:** Tags, chevron and indentation read correctly; nothing looks wrong that a contrast *ratio* wouldn't catch (spacing, alignment, icon weight).
**Why human:** Contrast is machine-proven; visual quality is not.

### Gaps Summary

The switcher's actual behavior — one "Accounts" list, children nested under their main (including the wallet-order edge case fixed by `d40050e4`), independent "Selected"/"On node" tags, child actions on nested rows, collapse, live refresh, phone-width and AA contrast — is fully implemented, wired end-to-end, and covered by 282 passing targeted tests plus a clean 2233/5/0 full suite and a clean `flutter analyze`. Every one of the 5 ROADMAP success criteria and all 22 plan-level must-have truths trace to real code and real passing tests, not narration.

The one gap is a phase-gate integrity issue, not a functional defect in the switcher: two of the six files this phase created (`test/account/account_tree_test.dart`, `test/account/account_drawer_tree_test.dart`) were silently rewritten from LF to CRLF partway through the phase (commit `8318083d`), which violates the phase's own explicit "new files use LF" rule and means 38-VALIDATION.md's and 38-03-SUMMARY.md's claim that this check passed is false. This is a small, mechanical fix (normalize the two files' line endings and recommit), but it is a real discrepancy between what was claimed and what the codebase shows, and this project has a documented history of exactly this kind of CRLF file passing every local check while failing CI. Fixing it and re-verifying `git ls-files --eol` is the only thing standing between this phase and the same `human_needed` status phases 34-37 already carry for the standing live-testnet walk.

---

_Verified: 2026-09-29_
_Verifier: Claude (gsd-verifier)_
