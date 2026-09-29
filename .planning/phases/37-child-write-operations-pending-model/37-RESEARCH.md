# Phase 37: Child write operations & pending model - Research

**Researched:** 2026-09-29
**Domain:** Flutter/Dart FFI wallet UI — fire-and-forget SDK writes, an app-level pending-operation registry, a switcher lock, all layered on Phase 35/36 code already on this branch
**Confidence:** HIGH — every wrapper, cubit and dialog idiom cited is code read this session

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- **D-01:** Main-side ops: fund, recover, revoke. Child-side ops: register, detach, replace-main. Never lets an op run from the wrong side.
- **D-02:** All actions live on the Phase 36 `/child-wallets` screen (no new route).
- **D-03:** Child rows get a row menu: "Fund", "Recover", "Revoke".
- **D-04:** A "This account" card describes the running account's own position — "Child of {main}" (found via `GetRegistrationsForMain` on each other SDK account) with "Detach"/"Move to another main", or "Not registered as a child" with "Register as a child of…". A main registered by someone else's account is undiscoverable; a failed/duplicate registration reads "Not confirmed yet".
- **D-05:** Main picker lists other SDK accounts (linked name + short address) plus "Enter an address" validated against the SGNUS format. Running account never offered.
- **D-06:** Wrong-side action → dialog names the required account, offers "Switch and continue" (dispatch `SelectSDKAccount`, await landing, reopen the action) or "Cancel" — never silent. If SWT-06 applies, refuse with its reason instead.
- **D-07:** Fund/Recover take a GNUS amount (≤6 decimals, exact, no floats), >0 and ≤ the paying side's balance. Uses `FundChildGNUS`/`RecoverFromChildGNUS`.
- **D-08:** Every action confirms, naming both accounts. Revoke/Detach/Move worded irreversible ("Revoke {child}? It will no longer be a child of {main}."). Fund/Recover confirm amount, from, to.
- **D-09:** Registration metadata sent as empty strings, `peers_cut = 0`.
- **D-10:** One app-level pending-operations registry cubit (above the router) owns every in-flight op: kind, from-account, target(s), amount, submitted-at, baseline. Never lives only in a screen's State.
- **D-11:** Resolution, re-checked on the Phase 36 10s poll + on demand: Register → appears under chosen main's list. Fund → balance rises by amount vs. baseline. Recover → falls by amount. Revoke/Detach → disappears from main's list. Move → disappears from old main, appears under new.
- **D-12:** Timeout 2min unresolved → "Not confirmed yet" (never "done"), "Check again", stops blocking. A non-OK submit return is immediate failure with the SDK's reason, not pending.
- **D-13:** Pending state is in-memory, app-lifetime only. `ponytail:` accepted; upgrade is persistence.
- **D-14:** Pending/done/not-confirmed show on the affected row (and card) via the Phase 34 badge pattern, plain words.
- **D-15 (PEND-02):** While a (kind,target) is pending, that action is disabled on that target with a reason. Different targets independent.
- **D-16 (SWT-06):** While any op submitted from the running account is pending, "Node running as" rows are disabled for switching away, with a reason. Timed-out ops don't lock. Active-wallet switching never locked.
- **D-17:** `DevMockChildWallets` gains write simulation: OK submit + list/balance changes after a delay (confirm), never changes (timeout), or submit errors (fail) — selectable in the dev bubble. Real SDK writes never run while a mock preset is active.

### Claude's Discretion
Exact widget/file names; whether the registry lives in `lib/child_wallets/`; timeout constant placement; copy wording beyond the UI-SPEC examples.

### Deferred Ideas (OUT OF SCOPE)
Persisting pending ops across restarts; discovering a main belonging to someone else (no by-child query); registration metadata UI.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| CHILD-03 | Register a child under a chosen main | `GeniusApi.registerChild`; D-01/D-05/D-06 flow; main picker reuses `_AddAccountDialog`'s toggle idiom |
| CHILD-04 | Fund a child from its main | `GeniusApi.fundChildGnus`; amount field reuses `send_screen.dart`/`send_cubit.dart` |
| CHILD-05 | Recover funds from a child | `GeniusApi.recoverFromChildGnus`; same amount pattern, child-side balance cap |
| CHILD-06 | Revoke a child | `GeniusApi.revokeChild`; destructive `GWDialog` idiom from `_confirmDeleteSDKAccount` |
| CHILD-07 | Detach a child | `GeniusApi.detachChild`; self-only, no D-06 needed |
| CHILD-08 | Move a child to a new main | `GeniusApi.replaceMain`; main picker reused, self runs the call |
| CHILD-09 | Offer to switch when wrong side | D-06 dialog; `AppBloc._onSelectSDKAccount`/`selectGeniusAccountAsync` await-the-real-signal pattern |
| PEND-01 | Pending → done/"not confirmed yet", never false-done | D-10..D-14; registry design below |
| PEND-02 | No double submit while pending | D-15; per-(kind,target) lock |
| SWT-06 | No switch mid-pending; switcher says why | D-16; `SDKAccountRow.lockedReason` extension |
| VER-02 | Live testnet walk | Deferred per Pitfall (testnet stuck `INITIALIZING_BLOCKCHAIN`); dev-mock walk substitutes, live walk recorded as blocked, not skipped |
</phase_requirements>

## Summary

Every SDK piece this phase needs already exists and is bound: all six write wrappers
(`registerChild`, `fundChildGnus`, `recoverFromChildGnus`, `revokeChild`, `detachChild`,
`replaceMain`) are in `packages/genius_api/lib/src/genius_api.dart`, boundary-checked, shipped by
Phase 36 Plan 02, with zero UI callers today. There is no new FFI work — it is pure Dart/Flutter:
wire six dialogs to six tested wrappers, build one in-memory pending registry cubit, and extend two
existing widgets (`SDKAccountRow`, `_ChildWalletRow`) with lock/badge state.

The hard part is honesty about the return value: every one of the six returns `GENIUS_NODE_RET_OK`
on **submission**, before consensus (`.planning/research/PITFALLS.md` Pitfall 4). None returns a tx
hash, so the only truth signal is re-reading `GetRegistrationsForMain`/`GetChildBalanceAll` and
noticing a change — exactly what D-11 specifies. The second hard part is the account-switch race
SuperGenius itself had to patch node-side (Pitfall 6: `e1b81120`/`5b9254c1`) — D-06/D-16 exist so the
Dart layer never fires `SelectSDKAccount` while a call from the current account is unresolved.

**Primary recommendation:** One `ChildOperationsCubit` (D-10), provided in `main.dart`'s root
`MultiBlocProvider` right after `AppBloc` (`lib/main.dart:408-421`), holding
`List<ChildOperation>` (kind, fromAccount, target, newMain?, amountGnus?, submittedAt,
baselineBalance?). Every dialog's submit calls one `GeniusApi` wrapper; on `RET_OK` it calls
`registry.start(...)` — never touches `ChildWalletsCubit` state directly. The registry's
`resolve()` reuses the exact `GeniusApi` reads `ChildWalletsCubit` already polls every 10s
(`child_wallets_cubit.dart:81`), piggybacking on that cadence rather than adding a second timer.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Six write calls | API/Backend (`GeniusApi`) | — | Already-bound FFI wrappers; UI never touches FFI directly (Phase 36 pattern) |
| Pending-op state | App-root Cubit (`ChildOperationsCubit`) | — | Must outlive the screen and be visible to the switcher — a screen-local State can't satisfy D-10/SWT-06 |
| Resolution polling | Same cubit | API/Backend (reads) | Pure Dart comparison against already-fetched reads; reuses Phase 36's timer, no new isolate |
| PEND-02 lock | Row widget (query) | App-root cubit (answers) | Pure in-memory lookup from `build()` |
| SWT-06 lock | `SDKAccountRow` (dim/tooltip) | App-root cubit (answers "pending from X?") | Same shape as PEND-02, never a widget→FFI call |
| Amount validation | Dialog-local (pure Dart) | — | Reuses `send_cubit.dart`'s regex/BigInt idiom, no SDK round-trip |
| Address validation | Dialog-local (`isEvmAddress`) | — | Existing pure function in `lib/utils/wallet_utils.dart` |
| Dev-mock write sim | `DevMockChildWallets` extension | — | Same dev-gated pattern as Phase 36 |

## Standard Stack

No new package is introduced — every dependency needed is already in `pubspec.yaml` and already
used by the exact code this phase extends (`flutter_bloc` for the new cubit, `dart:async` `Timer`
for the poll, both already exercised by `ChildWalletsCubit`). **Installation:** none.

## Package Legitimacy Audit

Not applicable — zero new dependencies added to `pubspec.yaml`.

## Architecture Patterns

### Data flow
```
Dialog submit → GeniusApi.<wrapper>(...)
   ├─ non-OK  → ToastType.error naming result.name — NOTHING pending (D-12)
   └─ RET_OK  → ChildOperationsCubit.start(kind, from, target, amount?, baseline, submittedAt)
                    │  (row/card re-render: pending GWRowBadge)
                    ▼
     Every 10s (piggybacked on ChildWalletsCubit's poll) or "Check again":
     registry.resolve() re-reads GeniusApi.getChild{Registrations,BalanceAll}
       ├─ D-11 signal true      → resolved, ToastType.success once, drop from registry
       └─ now > submittedAt+2m  → "Not confirmed yet", release any lock it held
```
SWT-06 read path is a pure lookup, no FFI call: each `SDKAccountRow` calls
`context.watch<ChildOperationsCubit>().pendingFromAccount(address)`; non-null → row dims, shows a
`Tooltip(reason)`, and `onTap` toasts the reason instead of dispatching `SelectSDKAccount`.

### Recommended Project Structure
```
lib/child_wallets/
├── child_wallets_cubit.dart, child_wallets_screen.dart   # Phase 36, extended (row menu, card actions)
├── child_operations_cubit.dart          # NEW — D-10 registry (state + resolve)
├── child_operation_dialogs.dart         # NEW — Fund/Recover/Revoke/Detach/Move/Register dialogs
├── child_operation_switch_dialog.dart   # NEW — D-06 switch-and-continue / refusal
└── child_main_picker_dialog.dart        # NEW — D-05 picker (list ⇄ manual entry)
lib/account/account_drawer.dart          # extended: SDKAccountRow gains `lockedReason`
lib/components/data/gw_row_badge.dart    # NEW — promoted from account_drawer.dart's `_RowBadge`
lib/dev/dev_mock_child_wallets.dart      # extended: DevChildWalletsWriteMode {confirm, timeout, fail}
lib/main.dart                            # extended: BlocProvider<ChildOperationsCubit> after AppBloc
```

### Pattern 1 — Submit consumes the return value exactly once
`GeniusNodeReturnValue` decides pending-vs-immediate-failure at submission and nothing else ever
renders "done" from it.
```dart
// Source: packages/genius_api/lib/src/genius_api.dart:1749 (fundChildGnus)
final result = api.fundChildGnus(amountGnus, childAddress);
if (result != GeniusNodeReturnValue.GENIUS_NODE_RET_OK) {
  showToast(context, 'The SDK refused to fund this child (${result.name}).', type: ToastType.error);
  return;
}
registry.start(ChildOperation(kind: fund, fromAccount: mainAddress, target: childAddress,
    amountGnus: amountGnus, baselineBalanceMinions: api.getChildBalanceAll(childAddress),
    submittedAt: DateTime.now()));
```
`GeniusNodeReturnValue` (`packages/genius_api/lib/ffi/genius_api_ffi.dart:1230-1254`) has **no
message field** — `result.name` (e.g. `"GENIUS_NODE_INVALID_ARGUMENT"`) is the only string
available. Showing the raw enum name vs. authoring a per-code human map is a copy decision for the
planner (see Open Questions).

### Pattern 2 — Await the real signal, never assume a dispatch landed
```dart
// Source: lib/account/sdk_account_manager.dart:414-418 (shipped precedent, DeleteSDKAccount)
bloc.add(DeleteSDKAccount(address));
final removed = await bloc.stream.map((s) => !s.sdkAccounts.contains(address))
    .firstWhere((gone) => gone, orElse: () => false)
    .timeout(const Duration(seconds: 3), onTimeout: () => false);
```
Adapted for D-06 (target: `AppState.selectedSDKAccount`, `lib/bloc/app_state.dart:81`, set only on
`RET_OK` by `_onSelectSDKAccount`, `lib/bloc/app_bloc.dart:871-887`):
```dart
bloc.add(SelectSDKAccount(requiredAccount));
final landed = await bloc.stream.map((s) => s.selectedSDKAccount == requiredAccount)
    .firstWhere((ok) => ok, orElse: () => false)
    .timeout(const Duration(seconds: 3), onTimeout: () => false);
```
`SelectSDKAccount` event: `lib/bloc/app_event.dart:52`. A refused switch never updates
`selectedSDKAccount`, so the timeout is the correct "didn't land" signal.

### Anti-Patterns to Avoid
- Treating `GENIUS_NODE_RET_OK` as "done" — the header repeats "submitted, not confirmed" three times for exactly this reason (Pitfall 4).
- A second poll timer for the registry — `ChildWalletsCubit` already polls every 10s; wire `resolve()` to that cadence instead of a new `Timer.periodic`.
- A lingering "done" badge — UI-SPEC's resolved decision: remove the badge, fire a one-shot toast, let the row's own updated data be the proof.
- Dispatching `SelectSDKAccount` from a SWT-06-locked context — check the lock before offering "Switch and continue."

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Exact-decimal GNUS amount validation | A new regex+BigInt parser | Port `send_cubit.dart:499-517`'s pattern (`RegExp('\\.\\d{$decimals}\\d*[1-9]')` over-precision check) with `decimals=6`, `symbol='GNUS'` | Already tested; this codebase has twice guarded against float-precision regressions (Send, Swap) |
| SGNUS/EVM address validation | A new "0x + N hex" regex | `isEvmAddress` (`lib/utils/wallet_utils.dart:7-11`) — EIP-55 aware, source of the exact "42 characters starting with 0x" string | One canonical validator; a second implementation could diverge on checksum handling |
| "Did the switch land" polling | A `Future.delayed` retry loop | `bloc.stream` + `firstWhere` + `.timeout()` (Pattern 2) | Same await-the-real-signal discipline as every other write in this app |
| Dialog chrome, fields, buttons | New dialog widgets | `GWDialog`/`GWDialogAction`, `GWTextField`, `GWButton`, `GWSelectRow` — already used 5+ times in `sdk_account_manager.dart` | UI-SPEC: "this phase does not invent a new dialog language" |

## Common Pitfalls

### Pitfall 1: Collapsing `RET_OK` to a success toast
All six writes ack submission, not finality (`GeniusSDK.h` ~648-718, PITFALLS.md Pitfall 4).
**Avoid:** submit handler only registers the op with `ChildOperationsCubit`; `ToastType.success`
fires only from `resolve()` observing D-11's real signal.

### Pitfall 2: Account switch fired while a pending op targets the current account
SuperGenius patched this node-side (`e1b81120`, `5b9254c1`, Pitfall 6); nothing guards the Dart
side. **Avoid:** SWT-06 (D-16) — check `registry.pendingFromAccount(currentAccount)` before ever
dispatching `SelectSDKAccount`, both from the switcher row and from D-06's own flow.

### Pitfall 3: A second poll loop duplicating `ChildWalletsCubit`'s reads
`ChildWalletsCubit` already runs `Timer.periodic(10s)` over the same `getChildRegistrations`/
`getChildBalanceAll` calls Pitfall 9 flags as the likeliest to have real node latency. **Avoid:**
call `registry.resolve()` from `ChildWalletsCubit.refresh()`'s own tick, or read its already-fetched
state — don't add an independent timer.

### Pitfall 4: Resolution compared as an absolute value instead of a delta from baseline
`GetChildBalance(All)` returns 0 for both "empty" and "not yet synced" (Pitfall 5); a naive `==`
check misfires on unrelated balance movement. **Avoid:** `current >= baseline + amount` (Fund) /
`current <= baseline - amount` (Recover) — an inequality tolerates other activity between polls,
answering the "robust to other activity" question directly.

### Pitfall 5: Re-validating metadata that D-09 already makes moot
`writeRegistrationMetadata` (`genius_api.dart:222-239`) already caps each string at 127 UTF-8 bytes.
D-09 sends `const ChildRegistrationMetadata()` (all empty/zero) for Register/Detach/Move, which
always passes trivially — no new validation task needed here.

## Code Examples

```dart
// Source: packages/genius_api/lib/src/genius_api.dart — six write wrappers, all
// "RET_OK means submitted, not confirmed by consensus," all return
// GENIUS_NODE_ERROR_NOT_INITIALIZED (no FFI call) when the SDK isn't up.
GeniusNodeReturnValue registerChild(String mainAddress, ChildRegistrationMetadata metadata)     // :1673
GeniusNodeReturnValue fundChildGnus(String amountGnus, String childAddress)                     // :1749
GeniusNodeReturnValue recoverFromChildGnus(String amountGnus, String childAddress)              // :1802
GeniusNodeReturnValue revokeChild(String childAddress)                                          // :1874
GeniusNodeReturnValue detachChild(ChildRegistrationMetadata metadata)                           // :1828 — self only, no address param
GeniusNodeReturnValue replaceMain(String newMainAddress, ChildRegistrationMetadata metadata)    // :1848 — self only

// GNUS-string marshalling (D-07's "GeniusTokenValue char[22]"), confirmed by reading both sides:
// Source: packages/genius_api/lib/src/genius_api.dart:251-261
bool writeTokenValue(Pointer<GeniusTokenValue> out, String amountGnus) {
  final bytes = utf8.encode(amountGnus);
  if (bytes.length > 21) return false;   // 21 bytes + 1 NUL = the 22-byte char[] field
  // ... writes bytes then a trailing 0
}
// Source: packages/genius_api/lib/ffi/genius_api_ffi.dart:1200-1210 — GeniusTokenValue struct,
// "Represents a Genius token value in fixed-point format as a string," 22-byte char array.
// Confirms: Fund/Recover GNUS variants take a plain decimal STRING, capped at 21 bytes.

// Read-side, address-agnostic — no requirement that the argument match the running account:
ChildRegistrations getChildRegistrations(String mainAddress)   // :1629 — local CRDT read, any address
BigInt getChildBalanceAll(String childAddress)                 // :1646 — "no registration check is performed"
// Answers the "query a main other than the running one" question: same call, different address —
// no side-switch needed to poll Move/Register resolution against the new main.
```

Dev mock extension (D-17) is a **separate, orthogonal** notifier from the existing read preset enum
(`lib/dev/dev_mock_child_wallets.dart:18-24`), not a sixth value on it — write behavior composes
with whichever read preset is armed: `enum DevChildWalletsWriteMode { confirm, timeout, fail }`,
read behind the same `kDebugMode && kShowDevTools` gate `ChildWalletsCubit.refresh` already uses.

Locked-row dimming reuses the exact disabled-menu-item treatment already shipped:
```dart
// Source: lib/account/sdk_account_manager.dart:210-212
final fg = !enabled ? gw.textSecondary.withValues(alpha: 0.5) : (danger ? gw.statusErrorText : gw.textPrimary);
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|---------------|--------|
| Two separate account menus | One unified switcher (`account_drawer.dart`) | Phase 35, this branch | SWT-06's lock extends the already-shipped `SDKAccountRow` list, not a new menu |
| No child-wallet capability | Read-only list + balances | Phase 36, this branch | This phase is purely additive; no Phase 36 shape needs to change |

**Deprecated/outdated:** none — this is the newest code in the repo.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | No established copy exists for `GeniusNodeReturnValue` failure codes; planner must pick `result.name` or author a human map. | Pattern 1 | Low — copy-only, easily changed in review |
| A2 | Switching TO an account with its own pending op (vs. FROM one, which SWT-06 locks) is not addressed by any D-number; assumed allowed. | Common Pitfall 2 | Medium — a second race window SWT-06 doesn't close if wrong; worth a planner/user check |
| A3 | Registry resolve() should piggyback on `ChildWalletsCubit`'s 10s timer rather than run its own — inferred from D-11's wording, not spelled out. | Don't Hand-Roll, Pitfall 3 | Low — either wiring satisfies D-11's letter; risk is only doubled FFI volume if ignored |

## Open Questions (RESOLVED)

1. **Switching TO an account with its own pending op** — PEND-02's per-(kind,target) independence (D-15) likely covers this; confirm during the live/dev-mock walk rather than pre-building a broader gate.
2. **Per-code failure copy** — default to the UI-SPEC's generic "The SDK refused to {verb} this child." (matches `_confirmDeleteSDKAccount`'s existing pattern, which also has no per-code detail) unless the planner wants finer-grained wording.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | `flutter test`/`analyze` | ✓ (not on PATH) | invoke via `C:/Users/User/Documents/Projects/GNUS/flutter/flutter/bin/flutter.bat` | none needed |
| Live SuperGenius testnet | VER-02 live walk | ✗ | — | Dev-mock walk (D-17) substitutes; live walk recorded as blocked, not skipped (testnet stuck `INITIALIZING_BLOCKCHAIN`) |
| Native GeniusSDK library | Any FFI call | Not loaded this session (per task instruction) | — | Fakes/injection, same pattern `child_wallets_screen_test.dart` already uses |

**Missing dependencies with no fallback:** none.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | `flutter_test` (bundled) — no `bloc_test`; `mockito` is present but Phase 36 tests use hand-written fakes, not mocks |
| Config file | none |
| Quick run command | `flutter test test/child_wallets/ test/account/ test/dev/` |
| Full suite command | `flutter test` (re-confirm the current pass count at plan/execution time — Phase 36 Plan 03 recorded 2032 passed/5 skipped, but later review-fix commits may have added more) |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| CHILD-03/06/07/08 | Submit + resolve via list membership | unit (cubit) | `flutter test test/child_wallets/child_operations_cubit_test.dart` | ❌ Wave 0 |
| CHILD-04/05 | Amount validation, balance cap, exact-decimal guard | unit | `flutter test test/child_wallets/` | ❌ Wave 0 |
| CHILD-09 | Switch dialog offers + awaits the real signal | widget | `flutter test test/child_wallets/child_operation_switch_dialog_test.dart` | ❌ Wave 0 |
| PEND-01 | Pending → resolved / timeout, never false-done | unit, using `flutter_test`'s own fake-async clock inside `testWidgets` (no `fake_async`/`clock` package in `pubspec.yaml`) — same mechanism `child_wallets_screen_test.dart:398-427` already uses for its 10s-poll test | `flutter test test/child_wallets/child_operations_cubit_test.dart` | ❌ Wave 0 |
| PEND-02 | Same (kind,target) locked, different targets independent | unit | same file | ❌ Wave 0 |
| SWT-06 | Row dims/tooltips/refuses tap while locked; releases on timeout | widget | extend `test/account/sdk_account_rows_test.dart` | ✅ existing file, new cases |
| VER-02 | Live testnet walk | manual-only | n/a — deferred | n/a |

### Sampling Rate
- **Per task commit:** `flutter test test/child_wallets/ test/account/ test/dev/`
- **Per wave merge / phase gate:** `flutter test` (full suite), green before `/gsd-verify-work`

### Wave 0 Gaps
- [ ] `test/child_wallets/child_operations_cubit_test.dart` — CHILD-03..08, PEND-01, PEND-02
- [ ] `test/child_wallets/child_operation_switch_dialog_test.dart` — CHILD-09
- [ ] Extend `test/account/sdk_account_rows_test.dart` — SWT-06
- [ ] Extend `test/dev/dev_mock_child_wallets_test.dart` — D-17's three write modes
- [ ] No new framework install — `flutter_test` + hand-written fakes matches Phase 36's pattern

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | No new auth surface |
| V3 Session Management | no | Not applicable |
| V4 Access Control | yes | D-01's "never the wrong side" — enforced by which dialogs are reachable from which UI location, not an SDK-side permission check |
| V5 Input Validation | yes | Amount: `send_cubit.dart`'s exact-decimal regex, plus `writeTokenValue`'s 21-byte cap (shipped). Address: `isEvmAddress` (EIP-55). Metadata: D-09 constants only, `writeRegistrationMetadata`'s 127-byte cap already shipped and moot |
| V6 Cryptography | no | No new key material; every op is public-address-only; no secret enters any new Cubit field (AGENTS.md wallet-safety, Pitfall 11) |

### Known Threat Patterns

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Double-submit (impatience / slow feedback) | Repudiation | PEND-02's per-(kind,target) lock, disable for the whole pending window (Pitfall 8) |
| Account-switch mid-submission | Tampering (partially node-mitigated) | SWT-06's lock — never dispatch `SelectSDKAccount` while an op from the current account is unresolved (Pitfall 6) |
| False "done" eroding trust (this repo's own bug class: fake swap success, demo-only Send) | Spoofing of a completion signal | D-11/D-12's honest pending/not-confirmed/toast-on-real-signal model |
| Secret leakage via a new surface | Information Disclosure | No field ever holds a mnemonic/key; only public addresses, amounts, timestamps (Pitfall 11) |

## Sources

### Primary (HIGH confidence — code read this session)
- `packages/genius_api/lib/src/genius_api.dart` — six write wrappers, `writeTokenValue`/`writeRegistrationMetadata`/`uint64Arg`, `getChildRegistrations`/`getChildBalanceAll`
- `packages/genius_api/lib/ffi/genius_api_ffi.dart` — `GeniusAddress`, `GeniusTokenValue`, `GeniusNodeReturnValue`
- `lib/child_wallets/child_wallets_cubit.dart`, `child_wallets_screen.dart`, `lib/dev/dev_mock_child_wallets.dart` — Phase 36 shipped code
- `lib/account/sdk_account_manager.dart` — `SDKAccountRow`, `sdkRowActions`, `_confirmDeleteSDKAccount`'s await-the-real-signal idiom, `_menuItem` dimming
- `lib/account/account_drawer.dart` — `_RowBadge`, "Node running as" `SDKAccountRow` list
- `lib/bloc/app_bloc.dart`, `app_state.dart`, `app_event.dart` — `SelectSDKAccount`, `_onSelectSDKAccount`, `AppState` fields, `sdkAccountName`/`linkedWallet`
- `lib/send/send_cubit.dart`, `send_screen.dart` — exact-decimal amount field/validation
- `lib/utils/wallet_utils.dart` — `isEvmAddress`, `getAddressForDisplay`
- `lib/main.dart` — root `MultiBlocProvider`, `AppBloc` provider position
- `.planning/phases/37-.../37-CONTEXT.md`, `37-UI-SPEC.md`; `.planning/phases/36-.../36-01/02/03-SUMMARY.md`, `36-VERIFICATION.md`
- `.planning/research/FEATURES.md`, `PITFALLS.md` — protocol mechanics, Pitfalls 4/5/6/8/9/11
- `pubspec.yaml` — no `fake_async`/`clock`; `mockito`/`flutter_test` present

### Secondary / Tertiary
None — every claim traces to a file read this session or a locked CONTEXT.md decision.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — zero new dependencies, all patterns already in this repo
- Architecture: HIGH — every wrapper signature, event class and cubit field quoted was read this session
- Pitfalls: HIGH for SDK-return-value and race pitfalls (sourced from PITFALLS.md's own `GeniusSDK.h`/commit citations); MEDIUM for Open Question 1 (no CONTEXT.md decision covers it directly)

**Research date:** 2026-09-29
**Valid until:** Next SDK header regeneration or a Phase 38+ change to `ChildWalletsCubit`/`AppBloc`'s switch flow — no package pins in this phase, so valid for the life of this branch.

> **Correction (orchestrator, before planning):** the main address the user types is an SGNUS address, `0x` + 128 hex (`GeniusSDK.h:57` `GENIUS_SDK_ADDRESS_SIZE`), not an EVM address. Do not reuse `isEvmAddress`; validate `^0x[0-9a-fA-F]{128}$` (case-insensitive compare downstream).

RESOLVED: switching TO an account with its own pending operation is allowed (only switching away from the submitting account locks); failure copy is generic ("The SDK refused to {verb}: {reason}").
