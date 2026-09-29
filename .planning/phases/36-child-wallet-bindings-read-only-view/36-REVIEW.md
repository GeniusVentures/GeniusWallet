---
phase: 36-child-wallet-bindings-read-only-view
reviewed: 2026-09-29T00:00:00Z
depth: standard
files_reviewed: 14
files_reviewed_list:
  - lib/account/sdk_account_manager.dart
  - lib/child_wallets/child_wallets_cubit.dart
  - lib/child_wallets/child_wallets_screen.dart
  - lib/dev/dev_mock_child_wallets.dart
  - lib/dev/dev_tools_bubble.dart
  - lib/navigation/router.dart
  - lib/submit_job/cubit/submit_job_cubit.dart
  - packages/genius_api/lib/ffi/genius_api_ffi.dart
  - packages/genius_api/lib/src/genius_api.dart
  - test/account/sdk_account_rows_test.dart
  - test/account/sdk_row_actions_test.dart
  - test/child_wallets/child_wallets_screen_test.dart
  - test/dev/dev_mock_child_wallets_test.dart
  - test/ffi/child_wallet_ffi_test.dart
findings:
  critical: 0
  warning: 1
  info: 1
  total: 2
status: clean
---

# Phase 36: Code Review Report

**Reviewed:** 2026-09-29
**Depth:** standard
**Files Reviewed:** 14
**Status:** issues_found

## Summary

This phase hand-splices 11 new GeniusSDK child-wallet bindings plus `GeniusSDKGetPubSub` into `genius_api_ffi.dart`, wraps them in `GeniusApi`, and adds a read-only `ChildWalletsCubit`/`ChildWalletsScreen` reachable from a new "Child wallets" row-menu item and `/child-wallets` route, with a dev-mock fixture set.

I checked every native signature and struct against `GeniusSDK.h` line by line (`GeniusRegistrationMetadata`, `GeniusRegistrationDiscoveryEntry`, `GeniusSDKGetRegistrationsForMain`, `GeniusSDKGetChildBalance[All]`, `GeniusSDKFundChild[GNUS]`, `GeniusSDKRecoverFromChild[GNUS]`, `GeniusSDKDetachChild`, `GeniusSDKReplaceMain`, `GeniusSDKRevokeChild`, `GeniusSDKGetPubSub`) — argument order, pointer-vs-by-value struct passing, and `const char*`/`uint64_t` typing all match. Struct field order/sizes match the header, and the new `child_wallet_ffi_test.dart` pins both struct sizes (392 / 664 bytes) against it directly, so a future header drift fails loudly as intended.

The `collectChildRegistrations` free contract is correct and test-proven: the out-array is copied into Dart objects before any free, is freed exactly once only when non-null, and a `GENIUS_NODE_GetPubSub` handle is never passed to `GeniusSDKFree`. The new `_CharArrayToDartString.toDartString(maxLength)` reader is bounded (never reads past `maxLength`), masks each byte with `& 0xFF` before UTF-8 decoding (so a negative signed-char value round-trips correctly), and is byte-identical to the old reader for ASCII data (verified against every call site: addresses use 131, metadata strings use 128, the mnemonic uses 216, `GeniusTokenValue` uses 22 — all match their declared array sizes). `uint64Arg`/`getChildBalance[All]`'s `BigInt.from(raw).toUnsigned(64)` correctly restores the unsigned interpretation of a `Uint64` return value that dart:ffi hands back as a possibly-negative signed 64-bit int. `ChildWalletsCubit`'s poll timer and the dev-preset listener are both torn down in `close()`, and `refresh()` is fully synchronous, so there is no emit-after-close path (also proven by the "stops once closed" widget test). Dev mocks are correctly gated behind `kDebugMode && kShowDevTools`, and `kShowDevTools` is a `bool.fromEnvironment` compile-time constant, so the gate is dead-code-eliminated in release builds. No AGENTS.md violations (brace-every-if, no `_buildFoo` widget helpers, GWColors-only tokens, no plan/decision-ID comments) were introduced by this diff.

One real gap: a newly-written helper reproduces a pre-existing crash-prone hex-parsing pattern instead of the correct one already sitting in the same file, three functions away.

## Warnings

### WR-01: `_writeTokenId` throws on an odd-length hex `tokenId` instead of handling it

**File:** `packages/genius_api/lib/src/genius_api.dart:275-289`

**Issue:** `_writeTokenId` is new code (this phase) used by `getChildBalance`, `fundChild`, and `recoverFromChild`:

```dart
for (var i = 0; i < 32 && i * 2 < cleanTokenId.length; i++) {
  final hexByte = cleanTokenId.substring(i * 2, (i + 1) * 2);
  out.ref.data[i] = int.parse(hexByte, radix: 16);
}
```

If `cleanTokenId.length` is odd (e.g. a caller passes a 63-hex-digit token id, or one with a stray trailing nibble), the loop condition `i * 2 < cleanTokenId.length` stays true one iteration past the point where a full 2-character slice fits, and `substring(i * 2, (i + 1) * 2)` throws a `RangeError` (`end` exceeds the string length) — an uncaught exception that will crash the caller. This is not reachable from any UI in this phase (every current call site passes `tokenId: null`), but it is a public `GeniusApi` method that Phase 37's write-flow UI will call directly with a real `tokenId`.

The same file already has the *correct* fix for this exact problem three functions away, in `getMinionsBalance` (line ~1239): pad an odd-length hex string with a leading zero before parsing. `_writeTokenId` should do the same instead of reproducing the crash-prone pattern used by the older, out-of-scope `mintTokens`/`transferTokens`/`payDev` (lines 884, 1393, 1611).

**Fix:**
```dart
void _writeTokenId(ffi.Pointer<GeniusTokenID> out, String? tokenId) {
  if (tokenId == null) {
    for (var i = 0; i < 32; i++) {
      out.ref.data[i] = 0;
    }
    return;
  }
  var cleanTokenId = tokenId.startsWith('0x')
      ? tokenId.substring(2)
      : tokenId;
  if (cleanTokenId.length.isOdd) {
    cleanTokenId = '0$cleanTokenId';
  }
  final maxBytes = (cleanTokenId.length ~/ 2).clamp(0, 32);
  for (var i = 0; i < maxBytes; i++) {
    final hexByte = cleanTokenId.substring(i * 2, i * 2 + 2);
    out.ref.data[i] = int.parse(hexByte, radix: 16);
  }
}
```

## Info

### IN-01: `/child-wallets` route casts `extra` straight to `String?`, no type guard

**File:** `lib/navigation/router.dart:212-213`

**Issue:**
```dart
final mainAddress =
    state.extra as String? ?? appBloc.state.selectedSDKAccount ?? '';
```
If any future caller pushes this route with a non-`String`, non-null `extra` (e.g. a `Map`, as several sibling routes in this same file accept), the `as String?` cast throws a `TypeError` instead of falling back to `selectedSDKAccount`. The only current caller (`sdk_account_manager.dart`'s "Child wallets" menu item) always passes a `String`, so this is not exploitable today. This mirrors an existing idiom already in this file (`/logs`'s `state.extra as String?`), so it's not a new anti-pattern, but worth a `is String?` guard (`state.extra is String ? state.extra as String : null`) if a second caller with structured `extra` is ever added.

**Fix:** Guard the cast, e.g. `final extra = state.extra; final mainAddress = (extra is String ? extra : null) ?? appBloc.state.selectedSDKAccount ?? '';`

---

_Reviewed: 2026-09-29_
_Depth: standard_

## Resolution

WR-01 and IN-01 fixed with a regression test for the odd-length token id; see 36-REVIEW-FIX.md.
