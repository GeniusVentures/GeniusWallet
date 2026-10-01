# Phase 36: Child wallet bindings & read-only view - Research

**Researched:** 2026-09-29
**Domain:** Dart FFI bindings to a native C SDK (GeniusSDK) + a read-only Flutter screen consuming them
**Confidence:** HIGH (header, ffi file, wrapper file, built exe, and the offline ffigen failure were all read/run directly this session)

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
D-01..D-18 in `36-CONTEXT.md` are binding. `/child-wallets` is a new top-level route (sibling of
`/network`), opened from a new "Child wallets" item in `SDKAccountRow`'s menu, enabled only on the
selected row. Each child row shows linked-wallet-name-or-"Unlinked" + short address + GNUS balance
(from `GeniusSDKGetChildBalanceAll`, integer-exact minions/1e6, via `formatTxAmount`). No
registration metadata shown. Row order is SDK order. States: empty / node-not-running / error (with
Retry) — header never hides. Poll every 10s + manual refresh. All 11 child functions +
`GeniusSDKGetPubSub` are bound and wrapped now (D-11/D-12); only 2 are called by this phase's UI.
`GetRegistrationsForMain` frees `*out_entries` with `GeniusSDKFree`; 0-count is empty, not error
(D-13). `GetPubSub`'s handle is never freed (D-14). All calls synchronous on the main isolate (D-15).
A unit test pins both new structs' `sizeOf` (D-16). `ChildWalletsCubit` under `lib/child_wallets/`
reads through `GeniusApi` only (D-17). `DevMockChildWallets` singleton with 5 presets + a CHILD
WALLETS dev-bubble section (D-18).

### Claude's Discretion
Exact widget/file names inside `lib/child_wallets/`. Whether minions→GNUS conversion lives as a
helper next to existing balance formatting or inside the cubit.

### Deferred Ideas (OUT OF SCOPE)
Showing which main a child is registered under (Phase 37 if CHILD-09 needs it). All write operations
and their pending states (Phase 37).
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| CHILD-01 | 11 child functions + `GeniusSDKGetPubSub` bound, structs match header, every SDK-allocated result freed | Exact declarations/Dart shapes/splice lines below; verified all 12 symbols are already linked into the current debug exe |
| CHILD-02 | User sees children of the current SDK wallet with GNUS balances | `GetRegistrationsForMain` + `GetChildBalanceAll` wrapper design, minions→GNUS helper, `36-UI-SPEC.md`'s screen contract |
| VER-01 | Dev mocks reproduce list and balances | `DevMockSgnus`/`dev_tools_bubble.dart` pattern, adapted per D-18 |
</phase_requirements>

## Summary

This phase is FFI plumbing plus one already-fully-specified UI screen (`36-UI-SPEC.md` is the
approved, binding visual contract — do not re-derive layout/copy/color from this document). The
milestone research (`STACK.md`, `FEATURES.md`, `PITFALLS.md`) already covers protocol and pitfalls in
depth; this document adds the exact header declarations with line numbers, the exact Dart shapes and
insertion line numbers for the existing hand-merged `genius_api_ffi.dart`, a **verified** confirmation
that all 12 symbols are already present in the currently-built `genius_wallet.exe`, an **empirically
confirmed** finding that `dart run ffigen` cannot run offline on this machine, and computed `sizeOf`
values for D-16's test.

**Primary recommendation:** Hand-splice the 12 bindings using the exact shapes below (ffigen cannot
run here — see Environment Availability). Bind and wrap all 12 in `GeniusApi`; call only
`GetRegistrationsForMain` and `GetChildBalanceAll` from `ChildWalletsCubit`. Give the registrations
wrapper a way to return "error" distinct from "empty list" — a plain `List<T>` return collapses D-13's
empty-is-success case into D-08's error case.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| FFI struct/function bindings | `genius_api_ffi.dart` | — | Raw native surface, no logic |
| Memory ownership (free `out_entries`, never free PubSub) | `genius_api.dart` wrapper | FFI bindings | Only the wrapper sees the pointer's full lifetime |
| minions→GNUS conversion, return-code mapping | `GeniusApi` wrapper / small helper | — | Same layer as `_mapNodeReturnValue`/`getSGNUSBalance` |
| Child list state, polling, dev-mock switch | `ChildWalletsCubit` (`lib/child_wallets/`) | — | D-17: no FFI/Hive in widgets |
| Screen layout, states, copy | `lib/child_wallets/` widgets | `GWScreen`/`GWEmptyState`/`GWErrorState` | Fully specified in `36-UI-SPEC.md` |
| Dev fixtures | `dev_mock_child_wallets.dart` + `dev_tools_bubble.dart` | `ChildWalletsCubit` (reads it) | Matches `DevMockSgnus` placement exactly |

## Standard Stack

No new dependency. `ffigen ^20.1.1` (dev-only) and `package:ffi 2.2.0` are already in
`packages/genius_api/pubspec.yaml` `[VERIFIED: packages/genius_api/pubspec.yaml]`. Every capability
the 12 new bindings need (struct-by-value params, `Pointer<Pointer<T>>` out-params,
`calloc`/`GeniusSDKFree`) is already exercised elsewhere in `genius_api.dart`.

## Package Legitimacy Audit

Not applicable — no new package is installed this phase.

## Architecture Patterns

### Exact C declarations (verified by direct read this session)

`[VERIFIED: GeniusSDK/build/Windows/Release/GeniusSDK/include/GeniusSDK.h]`

```c
#define GENIUS_SDK_MAX_METADATA_STRING_SIZE 128
typedef struct {
    char     game_id[GENIUS_SDK_MAX_METADATA_STRING_SIZE];
    char     publisher_id[GENIUS_SDK_MAX_METADATA_STRING_SIZE];
    char     dev_wallet[GENIUS_SDK_MAX_METADATA_STRING_SIZE];
    uint64_t peers_cut;
} GeniusRegistrationMetadata;          // h:91-97

typedef struct {
    GeniusAddress              child_address;
    GeniusAddress              main_address;
    uint64_t                   sequence;
    GeniusRegistrationMetadata metadata;
} GeniusRegistrationDiscoveryEntry;    // h:102-108
```
`GENIUS_NODE_ERROR_REGISTRATION` is enum value **7** (h:127-129, after `GENIUS_NODE_ERROR_PAY_DEV=6`).
`GeniusAddress.address` is `char[131]`, confirmed identical to the already-generated Dart struct
`[VERIFIED: genius_api_ffi.dart:934-939]` (`@ffi.Array.multi([131])`).

| C signature (h:505-720) | Returns | Notes |
|---|---|---|
| `void *GeniusSDKGetPubSub()` | `void*` | Node-owned; **never** `GeniusSDKFree` it |
| `GeniusSDKRegisterChild(const char*, GeniusRegistrationMetadata)` | ret code | struct **by value** |
| `GeniusSDKGetRegistrationsForMain(const char*, GeniusRegistrationDiscoveryEntry**, uint64_t*)` | ret code | out-params; 0-count on success is valid |
| `uint64_t GeniusSDKGetChildBalance(const char*, GeniusTokenID)` | balance | not called by this phase's UI |
| `uint64_t GeniusSDKGetChildBalanceAll(const char*)` | balance | called by CHILD-02 |
| `GeniusSDKFundChild(uint64_t, const char*, GeniusTokenID)` | ret code | bind+wrap now, no caller (Phase 37) |
| `GeniusSDKFundChildGNUS(const GeniusTokenValue*, const char*)` | ret code | bind+wrap now, no caller |
| `GeniusSDKRecoverFromChild(uint64_t, const char*, GeniusTokenID)` | ret code | bind+wrap now, no caller |
| `GeniusSDKRecoverFromChildGNUS(const GeniusTokenValue*, const char*)` | ret code | bind+wrap now, no caller |
| `GeniusSDKDetachChild(GeniusRegistrationMetadata)` | ret code | struct by value, no address param |
| `GeniusSDKReplaceMain(const char*, GeniusRegistrationMetadata)` | ret code | |
| `GeniusSDKRevokeChild(const char*)` | ret code | |

### Exact splice points in `genius_api_ffi.dart` (1391 lines, read this session)

`[VERIFIED: genius_api_ffi.dart]`
- **New function bindings**: insert immediately **before line 772** (the `NativeLibrary` class's
  closing `}`, right after `_GeniusSDKGetTaskResult`'s block ends at line 771). Copy the style at
  lines 343-348 (simple), 554-567 (multi-arg with a struct-by-value param).
- **New structs**: insert after line 1153 (`GeniusMnemonicAndInitPath`'s closing `}`), before the
  `const int _STDINT_H = 1;` block at line 1155.
- **Enum member**: extend `GeniusNodeReturnValue` (lines 971-993) — add
  `GENIUS_NODE_ERROR_REGISTRATION(7)` and `7 => GENIUS_NODE_ERROR_REGISTRATION,` in `fromValue`.
  `_mapNodeReturnValue` `[VERIFIED: genius_api.dart:1434-1441]` needs **no change** — it already
  catches unmapped ints via try/catch.

Every new `Pointer<...>`/`Pointer<Pointer<...>>` shape is ffigen's standard, mechanical lowering of a
C pointer — there is no ambiguity to resolve by running ffigen (see Environment Availability for why
it can't run here anyway).

### Computed `sizeOf` values for D-16's test (MSVC x64, `char[N]` has `alignof=1`)

Hand-computed from the verbatim fields above (a cross-check attempt with a compiled C probe stalled
in this sandbox's `vcvars64.bat` — see Environment Availability; **not** compiler-verified):
- `GeniusRegistrationMetadata`: `128+128+128` (no padding, already 8-aligned) `+ 8` (`peers_cut`,
  offset 384 already a multiple of 8) = **392 bytes**.
- `GeniusRegistrationDiscoveryEntry`: `child_address`@0 (131) + `main_address`@131 (131, ends@262) +
  2 bytes pad to align `sequence`@264 (8, ends@272) + `metadata`@272 (already 8-aligned, 392, ends@664).
  Struct align=8; 664 already a multiple of 8. = **664 bytes**. Write D-16's test as a pure-Dart
  `ffi.sizeOf<T>()` assertion (no C compile needed) — see Code Examples.

### Binding verification — all 12 symbols confirmed already linked

Ran this session: `grep -a -c "<symbol>" build/windows/x64/runner/Debug/genius_wallet.exe` for all 12
symbol names — every one found `[VERIFIED: genius_wallet.exe, run this session]`. The exe
(`Sep 28 23:57`) is newer than `GeniusSDK.lib` (`Sep 25 17:24`), and **no `GeniusSDK_shared.dll` sits
beside `genius_wallet.exe`** — confirming the SDK is statically linked (`DynamicLibrary.executable()`),
not a separate shared library. `_lookup<...>('GeniusSDKRegisterChild')` etc. will **not** throw at
`NativeLibrary` construction time on this build.

### Routing, screen chrome, conversion, name lookup

`/network`'s `GoRoute` shape (`builder:` returning a widget wrapped in `BlocProvider.value`)
`[VERIFIED: lib/navigation/router.dart:197-205]` is the routing precedent for `/child-wallets` — copy
the shape, not `network_page.dart`'s raw-`Colors.*` body (`36-UI-SPEC.md` already resolved this in
favor of `SettingsScreen`'s `GWScreen(appBar: ...)`). `GWScreen.scroll` defaults `true`
`[VERIFIED: lib/components/scaffold/gw_screen.dart:24]` — the UI-SPEC's `scroll: false` override is
required for the variable-length list.

D-05 forbids a float divide. Use integer division + zero-padded remainder into a string
`formatTxAmount` (`[VERIFIED: lib/dashboard/home/widgets/transaction_utils.dart:116-134]`, takes/returns
`String`) can consume directly:
```dart
String minionsToGnusString(int minions) =>
    '${minions ~/ 1000000}.${(minions % 1000000).toString().padLeft(6, '0')}';
```
For the linked-name lookup, reuse `AppBloc.linkedWallet`/`AppBloc.sdkAccountName`
`[VERIFIED: lib/bloc/app_bloc.dart:769-801]` exactly as `SDKAccountRow`/`AccountSwitcher` already do.
`AccountSwitcher`'s "Node not running" copy comes from `state.selectedSDKAccount == null`
`[VERIFIED: lib/account/account_switcher.dart:41-44]` — use the same test for this screen's
node-not-running state. These functions only resolve the user's own SDK accounts — an unrelated
child address correctly falls through to "Unlinked" per D-04.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Struct/pointer marshaling | A hand-typed guess at ffigen's output | Copy the exact shapes above, modeled on the file's own patterns (lines 343-348, 554-567, 920-956) | ffigen cannot run offline here; the existing file's idioms are the only verifiable reference |
| Registrations-list error/empty distinction | A `bool hasError` bolted onto the cubit | A wrapper return carrying both the mapped return code and the list, e.g. `({GeniusNodeReturnValue result, List<ChildRegistration> entries})` — the same record idiom `sdkRowActions` uses (`sdk_account_manager.dart:496-505`) | D-13 (0-count success) and D-08 (error+Retry) can't both be read off a bare `List<T>` |
| GNUS amount formatting | A second number formatter | `formatTxAmount` | One formatting source of truth already exists |

**Key insight:** every hard part of this phase (memory ownership, enum mapping, name resolution,
number formatting) already has a working precedent in this codebase — the work is disciplined
copying, not invention.

## Common Pitfalls

See `.planning/research/PITFALLS.md` for the full milestone list. Relevant to this phase's read-only
scope (write-op pitfalls 3/4/6/7/8/11 belong to Phase 37):
- **Pitfall 1** (stale/hand-typed bindings): mitigated by copying the exact shapes above.
- **Pitfall 2** (`out_entries` freed wrong): the zero-registrations case returns
  `out_entries=null, out_count=0, RET_OK` — success, not "nothing to free vs. call failed." Free
  `*out_entries` (not the out-param pointer) with `.cast<ffi.Void>()`, only if non-null, exactly once,
  mirroring `getAvailableAccounts()` (`genius_api.dart:1237-1252`).
- **Pitfall 5** (balance 0 is ambiguous): `GetChildBalanceAll` returning 0 means empty OR not-synced.
  D-09's lag note is the only mitigation this phase ships — do not invent a "syncing" heuristic.
- **Pitfall 9** (isolate blocking): bind both read calls synchronously (D-15), matching
  `transferTokens`/`mintTokens`, not `selectGeniusAccountAsync`'s isolate.
- **Pitfall 10** (no live testnet): build `DevMockChildWallets` first; VER-02's live walk is a
  separately-flagged, possibly-deferred criterion.

## Code Examples

### `GeniusSDKGetRegistrationsForMain` binding + wrapper free pattern
```dart
// Splice into NativeLibrary, before line 772:
int GeniusSDKGetRegistrationsForMain(
  ffi.Pointer<ffi.Char> main_address,
  ffi.Pointer<ffi.Pointer<GeniusRegistrationDiscoveryEntry>> out_entries,
  ffi.Pointer<ffi.Uint64> out_count,
) => _GeniusSDKGetRegistrationsForMain(main_address, out_entries, out_count);

late final _GeniusSDKGetRegistrationsForMainPtr = _lookup<
  ffi.NativeFunction<
    GeniusNodeReturnValue_t Function(
      ffi.Pointer<ffi.Char>,
      ffi.Pointer<ffi.Pointer<GeniusRegistrationDiscoveryEntry>>,
      ffi.Pointer<ffi.Uint64>,
    )
  >
>('GeniusSDKGetRegistrationsForMain');
late final _GeniusSDKGetRegistrationsForMain =
    _GeniusSDKGetRegistrationsForMainPtr.asFunction<
      int Function(ffi.Pointer<ffi.Char>,
          ffi.Pointer<ffi.Pointer<GeniusRegistrationDiscoveryEntry>>,
          ffi.Pointer<ffi.Uint64>)
    >();

// genius_api.dart wrapper, mirrors getAvailableAccounts() (:1237-1252):
final mainPtr = mainAddress.toNativeUtf8().cast<Char>();
final entriesPtrPtr = calloc<ffi.Pointer<GeniusRegistrationDiscoveryEntry>>();
final countPtr = calloc<ffi.Uint64>();
try {
  final rv = _ffiBridgePrebuilt.sgnsLib.GeniusSDKGetRegistrationsForMain(
    mainPtr, entriesPtrPtr, countPtr,
  );
  final mapped = _mapNodeReturnValue(rv);
  if (mapped != GeniusNodeReturnValue.GENIUS_NODE_RET_OK) {
    return (result: mapped, entries: <ChildRegistration>[]);
  }
  final count = countPtr.value;
  final entries = entriesPtrPtr.value;
  final list = <ChildRegistration>[];
  if (entries != nullptr) {
    for (var i = 0; i < count; i++) {
      final e = entries[i];
      list.add(ChildRegistration(
        childAddress: e.child_address.address.toDartString(131),
        mainAddress: e.main_address.address.toDartString(131),
        sequence: e.sequence,
      ));
    }
    _ffiBridgePrebuilt.sgnsLib.GeniusSDKFree(entries.cast<ffi.Void>());
  }
  return (result: mapped, entries: list);
} finally {
  malloc.free(mainPtr);
  calloc.free(entriesPtrPtr);
  calloc.free(countPtr);
}
```

### New structs (append after `GeniusMnemonicAndInitPath`, line 1153) + D-16 test
```dart
final class GeniusRegistrationMetadata extends ffi.Struct {
  @ffi.Array.multi([128]) external ffi.Array<ffi.Char> game_id;
  @ffi.Array.multi([128]) external ffi.Array<ffi.Char> publisher_id;
  @ffi.Array.multi([128]) external ffi.Array<ffi.Char> dev_wallet;
  @ffi.Uint64() external int peers_cut;
}

final class GeniusRegistrationDiscoveryEntry extends ffi.Struct {
  external GeniusAddress child_address;
  external GeniusAddress main_address;
  @ffi.Uint64() external int sequence;
  external GeniusRegistrationMetadata metadata;
}

// test/ffi/child_wallet_struct_layout_test.dart — values computed above, this session
test('GeniusRegistrationMetadata matches GeniusSDK.h layout', () {
  expect(ffi.sizeOf<GeniusRegistrationMetadata>(), 392);
});
test('GeniusRegistrationDiscoveryEntry matches GeniusSDK.h layout', () {
  expect(ffi.sizeOf<GeniusRegistrationDiscoveryEntry>(), 664);
});
```

`GeniusSDKGetPubSub` binds the same simple-lookup way as `GeniusSDKGetVersion`
(`genius_api_ffi.dart:397-402`), returning `ffi.Pointer<ffi.Void> Function()` — never paired with a
free call.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Computed `sizeOf` values (392 / 664 bytes) are correct MSVC x64 layout | Architecture Patterns | D-16's own test catches this immediately at `flutter test` time — low risk, self-correcting |
| A2 | A record type is the right shape for the registrations wrapper (vs. a sealed class) | Don't Hand-Roll | Cosmetic — either satisfies D-08/D-13; this is Claude's Discretion, not locked |

## Open Questions (RESOLVED)

1. **Registrations wrapper: record vs. sealed class for the error/empty distinction?**
   - What we know: D-13 needs 0-count-success to read as empty; D-08 needs a distinguishable
     query-failure state with Retry — no existing wrapper needs to report both a code and a list.
   - Recommendation: use the record shape in Code Examples — smallest change from the existing
     free/wrapper pattern, no new class.

## Environment Availability

| Dependency | Required By | Available | Fallback |
|------------|------------|-----------|----------|
| Flutter SDK | Build/test | Yes (not on `PATH`) | `export PATH="C:/Users/User/Documents/Projects/GNUS/flutter/flutter/bin:$PATH"` |
| LLVM/clang (libclang) | `dart run ffigen` | **No** — confirmed by running it | Hand-splice bindings using the shapes above |
| MSVC (`cl.exe`) | Compiling a native size probe | Yes (`2022 BuildTools 14.44.35207`) | Not needed — D-16's test is pure-Dart `ffi.sizeOf<T>()` |

**ffigen offline run — actual error, this session:**
```
$ dart run ffigen --config <scratch>.yaml
Unhandled exception: ProcessException: The system cannot find the file specified
  Command: clang -print-file-name=libclang.dll
    at findDylibAtDefaultLocations (package:ffigen/src/config_provider/spec_utils.dart:419)
```
No `clang`/`clang-cl` on `PATH`, no LLVM under `C:\Program Files\LLVM`. Do not re-attempt
`dart run ffigen` without installing LLVM first — it fails identically.

## Validation Architecture

| Property | Value |
|----------|-------|
| Framework | `flutter_test` (root `test/`); no dedicated `packages/genius_api/test/` dir exists |
| Quick run | `flutter test test/child_wallets/ test/ffi/` |
| Full suite | `flutter test` (baseline 1968 passed / 5 skipped) |

| Req ID | Behavior | Test Type | Command | Exists? |
|--------|----------|-----------|---------|---------|
| CHILD-01 | Struct `sizeOf` matches header layout | unit | `flutter test test/ffi/child_wallet_struct_layout_test.dart` | ❌ Wave 0 |
| CHILD-01 | `GetRegistrationsForMain`'s out-param freed once, no leak on repeat calls | unit | wrapper called twice against `DevMockChildWallets`, assert no crash | ❌ Wave 0 |
| CHILD-02 | Cubit renders populated/empty/node-not-running/error from mock presets | widget | `flutter test test/child_wallets/child_wallets_screen_test.dart` | ❌ Wave 0 |
| CHILD-02 | minions→GNUS conversion is integer-exact | unit | table test of `minionsToGnusString` | ❌ Wave 0 |
| VER-01 | Every mock preset reachable from the dev bubble | manual | exercised during the app walk | ❌ Wave 0 |

**Sampling:** quick run per task commit; full suite per wave merge; full suite green before
`/gsd-verify-work`. VER-02 (live testnet walk) stays a pending/deferred item per the milestone's
standing testnet blocker (`PITFALLS.md` Pitfall 10).

**Wave 0 gaps:** `test/ffi/child_wallet_struct_layout_test.dart`, `test/child_wallets/*_test.dart`,
`lib/dev/dev_mock_child_wallets.dart` (needed before the widget tests can drive states without a live
node). No new test framework install needed.

## Security Domain

| ASVS Category | Applies | Control |
|---|---|---|
| V4 Access Control | Yes | The new menu item's enable gate is UI-only (`can.childWallets: isSelected`), matching the existing `payout`/`phrase`/`qr` gates — no server-side authorization needed for a local read |
| V5 Input Validation | No | No text input this phase — addresses/balances are SDK-returned, not typed (metadata-field validation, Pitfall 3, belongs to Phase 37) |
| V6 Cryptography | No | No key material touched |

**Threat pattern:** use-after-free/double-free on `out_entries` (Tampering) — mitigated by freeing
exactly once, only on non-null, immediately after copying fields into Dart objects (see Pitfall 2 and
the Code Examples free pattern). Mnemonic/key leaking into Cubit state (Pitfall 11) is not triggered
by this phase's `ChildWalletsCubit` (addresses/names/balances only, per D-17).

## Sources

### Primary (HIGH — read/run directly this session)
- `GeniusSDK.h` lines 1-140, 480-727 — struct/function declarations
- `genius_api_ffi.dart` lines 340-1200 — existing binding style; confirms no child symbols exist yet
- `genius_api.dart` lines 1-90, 940-1440 — wrapper conventions, free patterns, `_mapNodeReturnValue`
- `sdk_account_manager.dart`, `account_switcher.dart`, `app_bloc.dart` — menu/name/node-status patterns
- `router.dart:180-220`, `gw_screen.dart` — routing/screen chrome
- `dev_mock_sgnus.dart`, `dev_tools_bubble.dart:1060-1280` — dev-mock singleton and `_Section`/`_devButton`
- `test/account/sdk_account_rows_test.dart` — `implements GeniusApi` + `noSuchMethod` fake pattern
- Run this session: `dart run ffigen` against the real header — confirmed offline failure (no libclang)
- Run this session: `grep -a -c "<symbol>"` on `genius_wallet.exe` for all 12 symbols — all present

### Secondary (MEDIUM)
- `.planning/research/STACK.md`, `FEATURES.md`, `PITFALLS.md` (2026-09-28) — cross-checked against this session's header read, consistent

### Tertiary (LOW)
- Computed struct `sizeOf` values (392 / 664) — hand-derived, not cross-checked with a compiled C probe (attempt stalled in this sandbox); D-16's own test will catch any error

## Metadata

**Confidence breakdown:** Standard stack HIGH (no new dep, tooling presence/absence confirmed by
direct run); Architecture HIGH (every declaration/splice point read from source this session);
Pitfalls HIGH (inherited from milestone research, cross-checked against this session's header read).

**Research date:** 2026-09-29
**Valid until:** Stable until `GeniusSDK.h` changes again or `genius_wallet.exe` is rebuilt from a
different SDK commit — re-run the symbol-presence grep if either happens.
