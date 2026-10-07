---
phase: 36-child-wallet-bindings-read-only-view
fixed_at: 2026-09-29T07:56:24Z
review_path: .planning/phases/36-child-wallet-bindings-read-only-view/36-REVIEW.md
iteration: 1
findings_in_scope: 2
fixed: 2
skipped: 0
status: all_fixed
---

# Phase 36: Code Review Fix Report

**Fixed at:** 2026-09-29T07:56:24Z
**Source review:** .planning/phases/36-child-wallet-bindings-read-only-view/36-REVIEW.md
**Iteration:** 1

**Summary:**
- Findings in scope: 2
- Fixed: 2
- Skipped: 0

## Fixed Issues

### WR-01: `_writeTokenId` throws on an odd-length hex `tokenId` instead of handling it

**Files modified:** `packages/genius_api/lib/src/genius_api.dart`, `test/ffi/child_wallet_ffi_test.dart`
**Commit:** 8d21710d
**Applied fix:** Extracted the odd-length-hex padding `getMinionsBalance` already had into a one-line shared helper (`_padHexEven`), so the fix lives in one place instead of being copied a third time. `_writeTokenId` now calls it and is renamed to `writeTokenId` with `@visibleForTesting` (matching the `writeTokenValue`/`uint64Arg` pattern already in the file) so it can be exercised directly. `getMinionsBalance` was updated to call the same helper instead of its own inline copy of the pad check — a free, behaviour-preserving dedup, not a new code path. Added two regression tests in `test/ffi/child_wallet_ffi_test.dart`: an odd-length hex id (`'abc'`) is padded and parsed instead of throwing, and a `null` id still writes the all-zero default token.

The pre-existing `mintTokens`/`transferTokens`/`payDev` callers (lines ~884, ~1393, ~1611) were left untouched, as scoped by the review — they reproduce the same crash-prone pattern but are out of scope for this phase and not "free" to change: they are already-tested, working code paths with no caller in this phase, and switching them to the new helper would be an unrequested, unscoped diff.

### IN-01: `/child-wallets` route casts `extra` straight to `String?`, no type guard

**Files modified:** `lib/navigation/router.dart`
**Commit:** d5b02184
**Applied fix:** Replaced the unchecked `state.extra as String?` cast with an `is String` guard (`(extra is String ? extra : null) ?? appBloc.state.selectedSDKAccount ?? ''`), exactly as the review suggested, so a future caller passing a non-`String` `extra` falls back to `selectedSDKAccount` instead of throwing a `TypeError`. No new test was added — this is a one-line null-safety guard with no reachable failing caller today (matching the review's own "not exploitable today" note), and building a full router harness to exercise this one branch would be a disproportionate diff for an info-level finding.

## Skipped Issues

None — all findings were fixed.

---

_Fixed: 2026-09-29_
_Iteration: 1_
