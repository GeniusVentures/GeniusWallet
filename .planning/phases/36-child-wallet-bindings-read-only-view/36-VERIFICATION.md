---
phase: 36-child-wallet-bindings-read-only-view
verified: 2026-09-29T08:05:00Z
status: human_needed
score: 8/8 roadmap+plan truths verified (2 standing items need a live/dev-tools walk)
behavior_unverified: 0
overrides_applied: 0
---

# Phase 36: Child wallet bindings & read-only view Verification Report

**Phase Goal:** The 11 child SDK functions and `GeniusSDKGetPubSub` are bound and safe, and the user can see the children registered under their current SDK wallet with balances — before any write path exists.
**Verified:** 2026-09-29
**Status:** human_needed
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | All 11 child functions + `GeniusSDKGetPubSub` bound in `genius_api`, struct layouts match `GeniusSDK.h`, every SDK-allocated result freed (ROADMAP SC1) | ✓ VERIFIED | `packages/genius_api/lib/ffi/genius_api_ffi.dart`: all 12 symbols spliced with header-matching signatures (confirmed line-by-line against `GeniusSDK.h:85-108,505-720`); `GeniusRegistrationMetadata`/`GeniusRegistrationDiscoveryEntry` field order matches header; `test/ffi/child_wallet_ffi_test.dart` pins `sizeOf` at 392/664 and proves `collectChildRegistrations` copies before freeing, frees a non-null array exactly once, never frees null, never double-frees (6 dedicated tests, all passing) |
| 2 | User sees the children registered under the currently selected SDK wallet, each with its GNUS balance (ROADMAP SC2, CHILD-02) | ✓ VERIFIED | End-to-end wiring traced: `SDKAccountRow` menu "Child wallets" item (`sdk_account_manager.dart:162-176`) → `router.push('/child-wallets', extra: address)` → `GoRoute('/child-wallets')` (`router.dart:208-226`) builds `ChildWalletsCubit` → `GeniusApi.getChildRegistrations`/`getChildBalanceAll` → FFI. `ChildWalletsScreen` renders header (main name/address) + rows (linked name or "Unlinked", short address, exact GNUS balance) — widget tests in `test/child_wallets/child_wallets_screen_test.dart` (714 lines) exercise populated, shared-name-disambiguation, case-insensitive-link-match, and long-name-ellipsis cases |
| 3 | `minionsToGnus` is integer-exact at the stated boundaries (0, 1, 1234567, 2^64-1) | ✓ VERIFIED | `child_wallets_cubit.dart:12-17` (`BigInt` integer division, no float); `test/child_wallets/child_wallets_screen_test.dart:698-713` table-tests exactly these five values including `18446744073709.551615` |
| 4 | Rows keep SDK order, no client sort, no metadata/sequence shown | ✓ VERIFIED | `child_wallets_cubit.dart:152-173` maps `registrations.entries` in place with `.map(...).toList()` (no sort); screen never reads `sequence`/`metadata`; "fixture order" test at `child_wallets_screen_test.dart:623-658` asserts row Y-position order |
| 5 | Four states (empty/node-not-running/error/populated) render correctly, lag note gated correctly, 0 balance never guessed as "syncing" | ✓ VERIFIED | `child_wallets_screen.dart:64-90` exhaustive switch; lag note only under `populatedOrConnectedEmpty` (`:39-47`); zero-balance test at `child_wallets_screen_test.dart:335-363` |
| 6 | 10s poll re-reads, cancelled on close; Refresh/Retry re-read; no loading state (synchronous reads) | ✓ VERIFIED | `Timer.periodic` + `_pollTimer?.cancel()` in `close()` (`child_wallets_cubit.dart:81,186`); behavioral test `polls every 10 seconds while open, and stops once closed` (`child_wallets_screen_test.dart:398-427`) actually drives the timer forward and confirms the call count freezes after the provider is torn down — this is a real state-transition/cleanup proof, not presence-only |
| 7 | Menu gate: only the account the node runs as can open the screen; disabled elsewhere | ✓ VERIFIED | `sdkRowActions(... childWallets: isSelected)` (`sdk_account_manager.dart:522`); `test/account/sdk_row_actions_test.dart` matrix test; `test/account/sdk_account_rows_test.dart:230-300` widget tests prove enabled/disabled per row and that tapping navigates with the correct address and closes the drawer |
| 8 | Dev mocks (`GW_DEV_TOOLS`) reproduce the child list and balances so the phase is verifiable without live testnet (ROADMAP SC3, VER-01 as scoped to this phase) | ✓ VERIFIED (wiring); see Human Verification #2 for the runtime-gated branch | `lib/dev/dev_mock_child_wallets.dart`: 5 presets, sticky `ValueNotifier`, `arm`/`clear`; `ChildWalletsCubit` reads/toggles the listener behind `kDebugMode && kShowDevTools` (`child_wallets_cubit.dart:82-88,106-108,187-189`); `dev_tools_bubble.dart` CHILD WALLETS section between BANXA and NAVIGATE with all 6 buttons; every preset proven through the real cubit+screen via a delegating fake (`child_wallets_screen_test.dart:574-696`) and the fixture logic itself unit-tested (`test/dev/dev_mock_child_wallets_test.dart`, 24 tests). The one thing no automated test can reach: `kShowDevTools` is `bool.fromEnvironment`, `false` under `flutter test`, so the actual runtime-gated listener/branch inside the cubit is dead code in this environment — explicitly documented in the test file's own header comment |

**Score:** 8/8 truths verified (0 present-but-behavior-unverified; 2 items below are standing manual-only requirements the plan itself always deferred, not gaps)

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `lib/child_wallets/child_wallets_cubit.dart` | `ChildWalletsCubit`, `ChildWalletsState`, `ChildWallet`, `minionsToGnus` | ✓ VERIFIED | Present, substantive, wired into router and screen |
| `lib/child_wallets/child_wallets_screen.dart` | Header, rows, four states, lag note | ✓ VERIFIED | Present, substantive, `scroll: false` confirmed |
| `packages/genius_api/lib/src/genius_api.dart` | `ChildRegistration`, `collectChildRegistrations`, `getChildRegistrations`, `getChildBalanceAll`, 10 write wrappers, `getPubSubHandle` | ✓ VERIFIED | All present; `getPubSubHandle` body contains no `GeniusSDKFree` call (grepped) |
| `packages/genius_api/lib/ffi/genius_api_ffi.dart` | 12 child bindings + `GENIUS_NODE_ERROR_REGISTRATION` | ✓ VERIFIED | All 12 symbol names present exactly once each; enum member present, `fromValue` maps `7` |
| `lib/dev/dev_mock_child_wallets.dart` | `DevChildWalletsPreset`, `DevMockChildWallets` | ✓ VERIFIED | Present, 5 presets, `ponytail:` comment present per D-18 discretion |
| `test/ffi/child_wallet_ffi_test.dart` | Struct layout + free-contract tests | ✓ VERIFIED | 389 lines, 18 tests, all passing, covers layout/free/metadata/tokenValue/uint64Arg/writeTokenId |
| `test/dev/dev_mock_child_wallets_test.dart` | Preset lifecycle + fixture tests | ✓ VERIFIED | 256 lines, 24 tests, honest header comment on the untestable gate |

### Key Link Verification

| From | To | Via | Status | Details |
|------|-----|-----|--------|---------|
| `sdk_account_manager.dart` | `router.dart` | menu item pushes route with address | ✓ WIRED | `router.push('/child-wallets', extra: address)` at `:173` |
| `router.dart` | `child_wallets_cubit.dart` | route builds the cubit | ✓ WIRED | `BlocProvider(create: (_) => ChildWalletsCubit(...))` at `:217-224`, with IN-01's `is String` guard applied |
| `child_wallets_cubit.dart` | `genius_api.dart` | reads only through `GeniusApi` | ✓ WIRED | No FFI/Hive imports in `lib/child_wallets/` (grepped, confirmed empty) |
| `genius_api.dart` | `genius_api_ffi.dart` | native tear-offs handed to the seam | ✓ WIRED | `sgnsLib.GeniusSDKGetRegistrationsForMain`/`GeniusSDKFree` passed into `collectChildRegistrations` |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
|----------|---------------|--------|---------------------|--------|
| `ChildWalletsScreen` rows | `state.children` | `ChildWalletsCubit.refresh()` → `_api.getChildRegistrations`/`getChildBalanceAll` → real FFI call (or dev preset when armed) | Yes, real SDK query when not in dev mode | ✓ FLOWING |
| Balance text | `wallet.balanceGnus` | `minionsToGnus(_api.getChildBalanceAll(address))`, `BigInt.from(raw).toUnsigned(64)` | Yes | ✓ FLOWING |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Full test suite | `flutter test` (re-run by verifier) | 2034 passed, 5 skipped, 0 failed | ✓ PASS |
| Static analysis | `flutter analyze lib test` (re-run by verifier) | "No issues found!", exit 0 | ✓ PASS |
| Package analyze | `flutter analyze lib/src/genius_api.dart lib/ffi/genius_api_ffi.dart` (re-run) | 109 issues, all pre-existing unused-constant warnings in the generated header tail, none in `genius_api.dart` | ✓ PASS |
| 12 FFI symbols reach the linked Windows binary | `grep -a` each symbol name against `build/windows/x64/runner/Debug/genius_wallet.exe` | All 12 found | ✓ PASS |
| Timer cancellation invariant | Named test `polls every 10 seconds while open, and stops once closed` | Passes; call count freezes at 2 after provider teardown + 10s pump | ✓ PASS |
| Free-contract invariant | `test/ffi/child_wallet_ffi_test.dart` `registrations free contract` group | All 6 cases pass (copy-before-free, free-once, never-free-null, never-double-free) | ✓ PASS |
| Debt markers | `grep -nE "TBD|FIXME|XXX|TODO|HACK|PLACEHOLDER"` across all phase 36 files | No matches | ✓ PASS |
| ID-identifier leakage | `grep -rnE 'D-[0-9]{2}|CHILD-0[0-9]|VER-0[0-9]|36-0[0-9]|Phase 3[5-7]'` across all phase 36 files | Only pre-existing matches from phases 04/09/34/35 (not phase 36's own diff) | ✓ PASS |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|------------|-------------|--------|----------|
| CHILD-01 | 36-01, 36-02 | 11 child functions + `GeniusSDKGetPubSub` bound, struct layouts match header, every SDK-allocated result freed | ✓ SATISFIED | All 12 bindings present and header-matching; struct sizes pinned; free contract test-proven; `getPubSubHandle` never frees |
| CHILD-02 | 36-01 | User sees children registered under current SDK wallet, each with GNUS balance | ✓ SATISFIED | Screen reachable, wired, tested end-to-end (static; live-node confirmation is the standing VER-02 walk) |
| VER-01 | 36-03 | Full requirement text: dev mocks cover child list, balances **and every child operation including pending/timeout states**. **Phase 36's roadmap scope (SC3) is narrower**: "Dev mocks reproduce the child list and balances so this phase is verifiable without live testnet" — write-operation mocks (register/fund/recover/revoke/detach/replace-main, pending/timeout states) are explicitly out of scope for Phase 36 per `36-CONTEXT.md` Deferred Ideas and ROADMAP Phase 37's own requirement list (CHILD-03..09, PEND-01/02) | ✓ SATISFIED against Phase 36's scoped SC3 | 5 read-path presets exist, gated, wired, gap correctly deferred to Phase 37 (not orphaned — ROADMAP's requirements-map table lists VER-01 only against Phase 36, and Phase 37's own goal explicitly owns "pending model" / every write). No orphaned requirement: CHILD-01, CHILD-02, VER-01 all declared across the three plans' `requirements:` frontmatter, matching REQUIREMENTS.md's Phase 36 mapping exactly |

No orphaned requirements found — REQUIREMENTS.md's requirements-map table lists exactly CHILD-01, CHILD-02, VER-01 against Phase 36, and all three appear in plan frontmatter (`36-01`: CHILD-01, CHILD-02; `36-02`: CHILD-01; `36-03`: VER-01).

### Anti-Patterns Found

None. No `TBD`/`FIXME`/`XXX`/`TODO`/`HACK`/`PLACEHOLDER` markers, no empty-return stubs, no hardcoded empty data flowing to render, no raw `Colors.*`, no `_buildX()` widget helpers, no plan/decision-ID leakage in phase 36's own diff. Code review (`36-REVIEW.md`) found 2 issues (1 warning: `_writeTokenId` odd-length-hex crash risk; 1 info: unguarded `extra` cast in router) — both fixed with a regression test for the warning (`36-REVIEW-FIX.md`, commits `8d21710d`, `d5b02184`), independently confirmed present in the current source (`writeTokenId`/`_padHexEven` in `genius_api.dart`, `is String` guard in `router.dart`).

### Human Verification Required

### 1. VER-02: Live-testnet child list and balance walk

**Test:** From the switcher, open the running SDK account's "Child wallets" screen against a live testnet node with at least one real child registration.
**Expected:** The child list and each balance match the node's actual registration/balance state; no client-side data is substituted.
**Why human:** Requires a live testnet connection; the node has previously been stuck in `INITIALIZING_BLOCKCHAIN` per this phase's own `36-VALIDATION.md`, and this environment must never load the native library or touch wallet data directories per the verifier's standing constraints. This is also ROADMAP Phase 36 Success Criterion 4, explicitly "standing" (recorded as pending/blocked gap if testnet cannot reach a usable state).

### 2. Dev-bubble preset walk

**Test:** Launch the app with `GW_DEV_TOOLS=true` in a debug build, open the dev tools bubble, expand CHILD WALLETS, and step through None / One child / Three children / Query error / Node not running / Clear while the `/child-wallets` screen is open.
**Expected:** Each button immediately drives the open screen to the matching state (empty copy, one row, three mixed rows in fixture order, error+Retry, "Node not running", back to whatever the real SDK state is on Clear) without needing to close and reopen the screen.
**Why human:** `kShowDevTools` is a `bool.fromEnvironment` compile-time constant that is `false` under `flutter test`, so the actual gated `DevMockChildWallets.instance.preset.addListener(refresh)` branch inside `ChildWalletsCubit` is dead code in the automated test environment — this is explicitly documented in `test/dev/dev_mock_child_wallets_test.dart`'s header comment, and the plan's own `<verification>` section defers this to "the end-of-milestone human test." Everything the branch depends on (the fixture data, the gate boolean, the listener add/remove code, the bubble wiring) is present, wired and unit/widget-tested individually — only the live runtime toggle end-to-end has never actually executed.

### Gaps Summary

No gaps. Every must-have truth across all three plans (36-01, 36-02, 36-03) is backed by passing, behaviorally meaningful tests (not just presence/grep), the free-memory contract and struct-layout pinning are proven under test, the code review's two findings were fixed with a regression test, and the full suite (2034/5/0), `flutter analyze` (0 issues), package-scoped analyze (109 pre-existing, none new), and the Windows debug build (all 12 symbols linked) all check out independently re-run by this verification. The two outstanding items are both explicitly-scoped standing manual-only checks the phase's own plans always deferred to a human/live-node walk, not implementation gaps — hence `human_needed` rather than `gaps_found`.

---

_Verified: 2026-09-29_
