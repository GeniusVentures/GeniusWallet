---
phase: 26-swap-that-actually-swaps
plan: 02
subsystem: swap/erc20
tags: [erc20, allowance, approve, web3, security]
status: complete
requires:
  - Web3 shared ERC-20 ABI, balanceOf/executeBridgeOutTransaction patterns
  - GeniusApi._secureStorage.getWallet + getDevPrivateKey (the dApp signing path)
provides:
  - "`decideApproval` - the pure rule: native / sufficient / approve-this-exact-amount"
  - "`Web3.allowance` and `Web3.rawBalanceOf` - raw BigInt base units, no decimals division"
  - "`Web3.approve` + `GeniusApi.approve` - exact-amount approval that returns its own error"
affects:
  - packages/genius_api/lib/web3/web3.dart (ABI +2 entries, 3 new methods)
  - packages/genius_api/lib/src/genius_api.dart (one wrapper)
tech-stack:
  added: []
  patterns:
    - "sealed class + private constructors, so an unlimited approval has no code path"
    - "pure free function beside the widget (sibling of swap_cta_state.dart)"
key-files:
  created:
    - lib/squid_router/swap_allowance.dart
    - test/squid_router/swap_allowance_test.dart
    - test/squid_router/erc20_abi_test.dart
    - test/squid_router/approve_error_test.dart
  modified:
    - packages/genius_api/lib/web3/web3.dart
    - packages/genius_api/lib/src/genius_api.dart
decisions:
  - "ApproveExactAmount's constructor is private and decideApproval is its only caller, so 'never uint256 max' is structural rather than a review note (T-26-03)"
  - "The dev key override (WALLET_PK) is applied INSIDE Web3.approve rather than in the GeniusApi wrapper as written. An approval signed by the stored wallet while the swap is signed by the dev key grants the allowance to the wrong owner. This also keeps the key String from crossing the layer boundary (T-26-04 not widened)"
  - "A failed allowance read returns zero, never a phantom allowance: the worst it costs is one redundant approval, and it can never skip a needed one"
  - "Added test/squid_router/approve_error_test.dart beyond the plan's file list - the returned error (T-26-06) is the one thing that must not silently regress"
metrics:
  tasks: 3
  files_touched: 6
  tests_added: 16
  test_baseline_before: 1216
  test_total_after: 1232
actuals:
  tokens: 21000
  tasks: 3
  commits: 5
---

# Phase 26 Plan 02: ERC-20 allowance and approve Summary

The wallet can now read an allowance and grant one for exactly the swap amount.

## What was built

`decideApproval` (pure, raw `BigInt` base units) answers one question: native sentinel -> no
approval; allowance covers it -> no call; otherwise approve **this exact amount**. The approve
outcome's constructor is private and the function is its only caller, so no caller can widen it to
`uint256.max` (T-26-03).

The shared ERC-20 ABI gained `allowance(address,address)` and `approve(address,uint256)`; the four
existing entries are asserted unchanged, because the asset list reads them. `Web3.allowance` and
`Web3.rawBalanceOf` are `balanceOf`'s read without the decimals division - raw units are what a
route's spend amount arrives in, and comparing them to a scaled double is off by 10^decimals.

`Web3.approve` copies `executeBridgeOutTransaction`'s shape but **not its bug**: that function
builds an `ApiResponse.error` and never returns it, so every bridge failure reads
`'Failed to bridge: unknown'`. This catch returns, and there is no generic string to fall
through to (T-26-06).

## Verification

- `flutter test --no-pub` -> **1232 passing, 3 skipped, 0 failing**, exit 0 (baseline 1216/3/0)
- `flutter analyze --no-pub` root -> "No issues found!", exit 0; same in `packages/genius_api`
- `bash tool/check_brace_style.sh --count` -> 0; `dart format` -> 0 changed
- No `print`/`log` near key material in `web3.dart`

## Deviations from Plan

1. **[Rule 2 - correctness] The dev key override moved one layer down**, into `Web3.approve`. In
   the wrapper as written it would have needed a key `String` across the boundary, and an approval
   signed by the stored wallet while the swap is signed by `WALLET_PK` grants to the wrong owner.
2. **[Rule 2 - security] One extra test file**, `approve_error_test.dart`, pinning the returned
   error and the missing-key message. Not in the plan's file list.
3. `Web3.approve` takes `StoredKeyWallet?`, mirroring `getPrivateKeyStr`'s own tolerance, and
   reports `'No signing key found for this wallet'`.

## Known Stubs

None. No caller yet - 26-04 and 26-05 wire this into the swap path; the one live `approve` that
costs gas is folded into 26-06's walk.

## Self-Check: PASSED
