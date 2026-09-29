---
phase: 35
fixed_at: 2026-09-29T05:51:00Z
review_path: .planning/phases/35-unified-header-switcher/35-REVIEW.md
iteration: 2
findings_in_scope: 2
fixed: 2
skipped: 0
status: all_fixed
---

# Phase 35: Code Review Fix Report

**Fixed at:** 2026-09-29T05:39:27Z
**Source review:** .planning/phases/35-unified-header-switcher/35-REVIEW.md
**Iteration:** 1

**Summary:**
- Findings in scope: 2 (WR-01, WR-02; no Critical findings existed)
- Fixed: 2
- Skipped: 0

Also added the tap/navigation test IN-01 asked for (Info tier, outside `critical_warning`
scope by default, but requested explicitly since it covers WR-02's fix surface).

## Fixed Issues

### WR-01: A watch-only wallet sharing the linked wallet's address is mislabeled "ACTIVE ON NODE"

**Files modified:** `lib/account/account_drawer.dart`
**Commit:** `570ae07e`
**Applied fix:** `isActiveOnNode` now matches on `walletType` as well as address, the same
pair `_matchesSelected` already checks a few lines above. A watch-only (tracking) wallet
sharing an address with an owned wallet no longer lights up "ACTIVE ON NODE" when the owned
wallet is what the node is actually linked to.

### WR-02: Swap's new "Sending from" line has no gate against a wallet that cannot actually sign

**Files modified:** `lib/squid_router/swap_cta_state.dart`, `lib/squid_router/swap_screen.dart`
**Commit:** `10c6fb50`
**Applied fix:** Reused Send's existing guard (`canSendFrom`, `lib/reown/utilities.dart`)
rather than inventing a new rule, per the fix guidance:

- `SwapCtaState` gained a `cannotSign` rung, checked immediately after `submitting` in
  `resolveSwapCtaState` (a new `canSign` parameter, default `true` so the existing pure-Dart
  test suite needed no changes). A wallet that cannot sign can never reach `ready`, regardless
  of amount, route, or balance.
- `_buildSwapCta` now computes `canSendFrom(wallet, network)` from `WalletDetailsCubit` and
  passes it in as `canSign`; the `cannotSign` rung renders through the same disabled/refused
  (`statusErrorText`) treatment already used for `insufficientBalance`/`tooPrecise`.
- `_SwapFromWallet` (the "Sending from" line) now reads the network too and shows "Can't sign
  from {wallet}" in `statusErrorText` when the wallet can't sign here, instead of quietly
  claiming "Sending from {wallet}" — plain words, an existing `GWColors` token already used
  for this exact refusal semantics elsewhere in the same file, no new color introduced.
- No confirm step was added (kept out of scope per 35-CONTEXT.md D-13, explicit).

### IN-01 (requested alongside WR-02, not independently in scope): the "Switch ›" link's navigation was not exercised by any test

**Files modified:** `test/squid_router/swap_submit_test.dart`
**Commit:** `4e3dadd8`
**Applied fix:** Added `AppBloc? appBloc` as an optional parameter to the shared `_mountReady`
harness (wired into the `MultiBlocProvider` only when supplied, so every existing case is
unaffected), then added a case that builds a minimal `AppBloc` + `WalletDetailsCubit`, mounts
the Swap screen, taps `find.widgetWithText(TextButton, 'Switch ›')`, and asserts the drawer
actually opens (`find.text('Accounts')`, `find.text('SENDING FROM')`) rather than only that the
link exists. Mirrors the disposal pattern `test/account/account_drawer_show_test.dart` uses for
`AppBloc`'s real 3-second poll timer (`tester.runAsync(() => appBloc.close())` in a `finally`).

## Skipped Issues

None — all in-scope findings were fixed.

## Verification

Ran in the main checkout (no worktree — `workflow.use_worktrees` is `false` in
`.planning/config.json`, honored per the documented opt-out):

- `dart format` on every changed file: 0 changes needed after the fix.
- `bash tool/check_brace_style.sh`: pass.
- `bash tool/check_raw_colors.sh`: pass.
- `flutter analyze lib test`: 0 issues.
- `flutter test`: 1959 passed / 5 skipped / 0 failed (baseline was 1958 passed / 5 skipped /
  0 failed; the +1 is the new IN-01 navigation test — no regressions).

---

_Fixed: 2026-09-29T05:39:27Z_
_Iteration: 1_

# Phase 35: Code Review Fix Report — Iteration 2

**Fixed at:** 2026-09-29T05:51:00Z
**Source review:** .planning/phases/35-unified-header-switcher/35-REVIEW.md (iteration 2)
**Iteration:** 2

**Summary:**
- Findings in scope: 2 (WR-03, IN-02; no Critical findings existed)
- Fixed: 2
- Skipped: 0

## Fixed Issues

### WR-03: Neither iteration-1 fix shipped with a test that reproduces the bug it fixes

**Files modified:** `test/account/account_drawer_show_test.dart`,
`test/squid_router/swap_cta_state_test.dart`, `test/squid_router/swap_submit_test.dart`
**Commits:** `021551c2`, `5b89eacc`, `786db6d6`
**Applied fix:** Three regression tests, each confirmed to fail against a manually reverted
copy of its fix before being committed against the real code:

- `account_drawer_show_test.dart` gained a case with a tracking wallet and an owned wallet
  sharing one address, linking the SDK account to the owned one. It asserts exactly one
  "ACTIVE ON NODE" badge appears, and that it sits on the owned row (via
  `find.descendant`/`find.ancestor` on `GWSelectRow`), not the tracking row — reverting the
  `walletType` comparison in `isActiveOnNode` makes this fail.
- `swap_cta_state_test.dart` gained a `cannotSign` rung group: a base case plus one
  precedence case per rung it outranks (`enterAmount`, `tooPrecise`, `routeError`,
  `insufficientBalance`), and a `submitting outranks cannotSign` case alongside the existing
  precedence tests.
- `swap_submit_test.dart` gained a case mounting `SwapScreen` with a `WalletType.tracking`
  wallet, asserting the CTA renders "Can't sign with this wallet" (not the `GWButton` the
  ready rung uses) and that `storage.writes` stays empty after a tap in that area.

### IN-02: `_buildSwapCta` read a possibly-null wallet through `canSendFrom`, misreading a transient no-wallet state as a signing refusal

**Files modified:** `lib/squid_router/swap_screen.dart`, `test/squid_router/swap_submit_test.dart`
**Commit:** `316d1ab6`
**Applied fix:** `_buildSwapCta` now short-circuits `canSign` to `true` when
`walletState.selectedWallet` is `null`, per the fix guidance — a wallet that was never
selected keeps the pre-existing `enterAmount` reading instead of falling through
`canSendFrom`'s null-argument `false`. `resolveSwapCtaState` itself is untouched; the guard
lives at the one call site that has the "was a wallet actually chosen" information. Added a
test mounting `SwapScreen` with a fresh, unseeded `WalletDetailsCubit` (no wallet, no
network) and asserting the CTA reads "Enter an amount", not "Can't sign with this wallet" —
confirmed to fail against a manually reverted copy of the guard before being committed
against the real code.

## Skipped Issues

None — all in-scope findings were fixed.

## Verification

Ran in the main checkout (no worktree — `workflow.use_worktrees` is `false` in
`.planning/config.json`, honored per the documented opt-out):

- `dart format` on every changed file: 0 changes needed after the fix.
- `bash tool/check_brace_style.sh`: pass.
- `bash tool/check_raw_colors.sh`: pass.
- `flutter analyze lib test`: 0 issues.
- `flutter test`: 1968 passed / 5 skipped / 0 failed (iteration-1 baseline was 1959 passed /
  5 skipped / 0 failed; the +9 are the new WR-03/IN-02 regression tests — no regressions).
- Each new test was proven to fail against a manually reverted copy of its own fix, then
  restored, before being committed — not just proven to pass against the fixed code.

---

_Fixed: 2026-09-29T05:51:00Z_
_Iteration: 2_
