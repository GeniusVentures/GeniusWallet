---
phase: 35-unified-header-switcher
reviewed: 2026-09-29T00:00:00Z
depth: standard
files_reviewed: 6
files_reviewed_list:
  - lib/account/account_drawer.dart
  - lib/squid_router/swap_cta_state.dart
  - lib/squid_router/swap_screen.dart
  - lib/send/send_screen.dart
  - test/squid_router/swap_submit_test.dart
  - test/squid_router/swap_cta_state_test.dart
findings:
  critical: 0
  warning: 1
  info: 1
  total: 2
status: clean
---

# Phase 35: Code Review Report (iteration 2)

**Reviewed:** 2026-09-29
**Depth:** standard
**Files Reviewed:** 6
**Status:** issues_found

## Summary

Re-review of `git diff 72d9fb5f..HEAD` (the iteration-1 fix commits) against the two Warnings
and one Info raised in iteration 1. Traced both fixes end to end rather than trusting the fix
report's own description.

## Resolved from iteration 1

**WR-01 (mislabeled "ACTIVE ON NODE"):** Confirmed fixed. `account_drawer.dart:584` now adds
`w.walletType == activeOnNode.walletType` to the `isActiveOnNode` comparison, the exact pair
`_matchesSelected` already checked a few lines above. A tracking wallet sharing an address with
an owned wallet can no longer both light up "ACTIVE ON NODE" — only the walletType that actually
matches `AppBloc.linkedWallet`'s result does.

**WR-02 (Swap has no gate against a non-signing wallet):** Confirmed fixed, and confirmed
correctly ordered. Traced the full precedence chain in `resolveSwapCtaState`:
`isSubmitting` → `!canSign` → `enterAmount` → `tooPrecise` → `routeError` →
`insufficientBalance` → `findingRoute`/`!hasRoute` → `ready`, matching the updated docstring
exactly. `canSign` defaults to `true`, so every pre-existing pure-Dart test in
`swap_cta_state_test.dart` (which never passes `canSign`) is unaffected — the new rung cannot
fire for a normal signing wallet. `_buildSwapCta` computes `canSign: canSendFrom(wallet, network)`
fresh on every build (via `context.read` inside a method re-invoked whenever the enclosing
`BlocListener` triggers `setState` on a wallet/network change), so a switch is picked up. Because
`_submitSwap` is wired to `onPressed` only in the branch gated on
`state == SwapCtaState.ready || state == SwapCtaState.routeError`, and `cannotSign` structurally
outranks `ready`, there is no code path by which a non-signing wallet's tap reaches
`widget.execute` — this isn't just a label, it is a real refusal, closing the exact gap iteration
1 found. The disabled/refused rendering reuses the pre-existing `gw.statusError` (fill, 12% alpha)
/ `gw.statusErrorText` (AA-safe foreground, per its own field doc) pair already used for
`insufficientBalance`/`tooPrecise` — no new color or pairing was introduced, so no new WCAG
exposure exists in either light or dark mode. `_SwapFromWallet` mirrors the same `canSend` check
independently (via `context.select`) and swaps its own label/color the same way. No regression
found in the `unavailable` (Squid not configured) precedence: that gate still sits above the
ladder and its label/styling is untouched by the new rung.

**IN-01 (untested "Switch ›" navigation):** Confirmed fixed. `swap_submit_test.dart` now has
`tapping Switch opens the account switcher`, which supplies a real `AppBloc`, taps
`find.widgetWithText(TextButton, 'Switch ›')`, and asserts `find.text('Accounts')` and
`find.text('SENDING FROM')` both appear — an actual navigation assertion, not just presence of
the link.

## Warnings

### WR-03: Neither iteration-1 fix shipped with a test that reproduces the bug it fixes

**File:** `lib/account/account_drawer.dart:582-586`, `lib/squid_router/swap_cta_state.dart:47-100`

**Issue:** Both fixes are structurally correct (confirmed above by tracing the code), but neither
is backed by a regression test that would fail if the fix were reverted or the new logic
regressed later:

- **WR-01:** No test anywhere in the suite constructs the scenario the original finding
  described — a tracking wallet and an owned wallet sharing one address, both present in
  `ownWallets`, with an SDK account linked to the owned one. `test/account/account_drawer_show_test.dart`'s
  `'the wallet linked to the active SDK account shows ACTIVE ON NODE'` test uses a single wallet
  with no address-twin, so it cannot distinguish the old (address-only) comparison from the new
  (address+walletType) one — it would pass identically either way. `walletSDKBadge` (a different
  function) has its own tracking-wallet test, but `isActiveOnNode` does not.
- **WR-02:** `swap_cta_state_test.dart`'s own header comment says it has "one expectation per
  behavior bullet... plus the precedence cases" for every other rung, but no case was added for
  `cannotSign` — nothing asserts `canSign: false` outranks `enterAmount`, `tooPrecise`,
  `routeError`, or `insufficientBalance`, and nothing in `swap_submit_test.dart` mounts
  `SwapScreen` with a `WalletType.tracking` or `WalletType.sgnus` wallet to prove the CTA actually
  renders disabled with "Can't sign with this wallet" (as opposed to, say, `canSendFrom` being
  wired to the wrong field, or a future edit reordering the precedence checks). The fix report
  states the pure-Dart suite "needed no changes" — true only because the new parameter defaults
  away the change, which also means nothing in CI would catch a regression here.

This project's own AGENTS.md is explicit that "non-trivial logic leaves ONE runnable check
behind, the smallest thing that fails if the logic breaks" — both of these are exactly that kind
of logic (a discriminator added to a wallet match; a new precedence rung with security-adjacent
consequences), and both shipped without one.

**Fix:** For WR-01, add a case (e.g. in `account_drawer_show_test.dart`) with a tracking wallet
and an owned wallet sharing an address, where only the owned one is `linkedWallet`, asserting
exactly one "ACTIVE ON NODE" badge appears and it is not on the tracking row. For WR-02, add a
`swap_cta_state_test.dart` case asserting `canSign: false` overrides every other input (mirroring
the existing "submitting outranks X" cases), and a `swap_submit_test.dart` case that mounts
`SwapScreen` with a `WalletType.tracking` wallet and asserts the CTA shows "Can't sign with this
wallet" disabled and `storage.writes` stays empty after a tap.

## Info

### IN-02: `_buildSwapCta` reads a possibly-null wallet/network through `canSendFrom`, so a
transient no-wallet state reads as "Can't sign with this wallet" rather than "Enter an amount"

**File:** `lib/squid_router/swap_screen.dart:751-754`

**Issue:** `canSendFrom(wallet, network)` returns `false` whenever either argument is `null`
(`lib/reown/utilities.dart:24-29`), and `WalletDetailsState.selectedWallet`/`selectedNetwork` are
both nullable and observed to start `null` in this cubit (`wallet_details_cubit.dart:247`). Before
this fix, that transient state resolved to `enterAmount` (since `hasBothTokens` is independently
false); after it, `cannotSign` outranks `enterAmount`, so the CTA would read "Can't sign with this
wallet" during that window instead. This isn't misleading in a harmful way (a wallet that isn't
selected yet indeed can't sign), and no test or production code path was found where the Swap
screen is actually reachable with no wallet selected (onboarding always seeds one first), so this
is unlikely to be user-visible. Noting it because it is a real, if narrow, behavior change from
the pre-fix ladder.

**Fix:** Optional — if ever reachable, guard `canSign` with `wallet != null` explicitly so a
"no wallet yet" state still reads `enterAmount` rather than the wallet-specific refusal.

---

_Reviewed: 2026-09-29_
_Depth: standard_

## Resolution

Iteration 2 findings (missing regression tests; no-wallet ladder reading) were fixed and proven by failing-then-passing tests; see 35-REVIEW-FIX.md "Iteration 2".
