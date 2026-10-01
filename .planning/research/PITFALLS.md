# Pitfalls Research

**Domain:** FFI-bound self-custody wallet — child-wallet/account-linking milestone (v3.0)
**Researched:** 2026-09-28
**Confidence:** HIGH (codebase/header cited directly), MEDIUM (SuperGenius fix commits — titles read, diffs not pulled), LOW (live testnet behavior — currently blocked by INITIALIZING_BLOCKCHAIN loop)

## Critical Pitfalls

### Pitfall 1: Stale ffigen bindings — child structs/functions don't exist yet

**What goes wrong:** `packages/genius_api/lib/ffi/genius_api_ffi.dart` has no `GeniusRegistrationDiscoveryEntry`, `GeniusRegistrationMetadata`, or any of the 11 child functions + `GeniusSDKGetPubSub` (confirmed: zero matches for `RegisterChild|FundChild|RecoverFromChild|DetachChild|ReplaceMain|RevokeChild|GetPubSub|GetChildBalance` under `packages/genius_api`). Regeneration must be driven from the actual shipped `GeniusSDK.h` (v2.2-2.4 section), not hand-typed structs — hand-typing risks silent field/offset drift from the real DLL.

**Why it happens:** The header evolved (`/* v2.2 */`...`/* v2.4 */` comments show three separate additions) faster than `genius_api_ffi.dart` was regenerated.

**How to avoid:** Regenerate FFI bindings via the project's existing ffigen config against the shipped header before writing any Dart wrapper method. Diff the generated struct sizes against `sizeof()` printed from a tiny C probe if ffigen and the prebuilt DLL ever disagree (they're built from different header copies across machines per `GeniusSDK/build/Windows/Release/...`).

**Warning signs:** Any hand-written `ffi.Struct` class for `GeniusRegistrationMetadata`/`GeniusRegistrationDiscoveryEntry` instead of a ffigen-generated one; a build that links but returns garbage `sequence`/`peers_cut` values.

**Phase to address:** The binding phase, before any UI consumes child calls.

---

### Pitfall 2: `out_entries` from `GetRegistrationsForMain` freed wrong, or not at all

**What goes wrong:** `GeniusSDKGetRegistrationsForMain(main_address, GeniusRegistrationDiscoveryEntry** out_entries, uint64_t* out_count)` heap-allocates the array on success and requires the caller to call `GeniusSDKFree` on it (header lines ~564-576); on failure **or on the valid zero-registrations case** it sets `out_entries = null` and `out_count = 0` — that zero case is success, not an error, and must not be treated as "call failed, nothing to free" vs "call succeeded with empty list, still nothing to free" — both look identical in Dart but only one is a genuine error (`GENIUS_NODE_ERROR_REGISTRATION`). The existing codebase already frees analogous heap buffers with `GeniusSDKFree(result.cast<ffi.Void>())` (`genius_api.dart:965`, `:1366`) and `GeniusSDKFreeTransactions` for matrices (`:890`) — the child-list wrapper must follow the same "free exactly once, only on a non-null pointer" discipline, not skip freeing because the count is 0 (a 0-count non-null pointer is still a call site that allocated).

**Why it happens:** Out-param double-indirection (`Pointer<Pointer<Struct>>`) is easy to get wrong in Dart FFI — forgetting `.cast<ffi.Void>()` before `GeniusSDKFree`, or freeing `out_entries` itself instead of `*out_entries`.

**How to avoid:** Write the child-list read as a single wrapper method mirroring `getAvailableAccounts()`'s free-then-return shape (`genius_api.dart:956-971`): allocate `out_entries`/`out_count` with `calloc`, call, copy every entry into Dart objects immediately (chars via the existing `_CharArrayToDartString` extension, `genius_api.dart:43-55`), free the native array, free the two out-param pointers, then return the Dart list. Never hold the native pointer past that method.

**Warning signs:** A leak visible in long dev sessions (repeated child-list refresh) or a use-after-free crash if the raw pointer escapes into a Bloc state.

**Phase to address:** The child-list binding plan (`GetRegistrationsForMain`), verified with one runnable check that calls it twice and confirms no crash/leak growth.

---

### Pitfall 3: `char[128]` metadata fields overflow silently — no bounds check at the Dart/FFI boundary

**What goes wrong:** `GeniusRegistrationMetadata.game_id/publisher_id/dev_wallet` are each `char[GENIUS_SDK_MAX_METADATA_STRING_SIZE]` = 128 bytes fixed (header line ~90-96). A UI text field with no max-length constraint can produce a string whose UTF-8 encoding exceeds 128 bytes (non-ASCII devs/publishers make this worse — 1 char can be 3-4 UTF-8 bytes), truncating or overrunning the array when copied in.

**Why it happens:** Dart strings are UTF-16; the byte length of the UTF-8 encoding is not obvious from `.length`, and nothing enforces the 128-byte cap client-side.

**How to avoid:** Validate UTF-8 byte length ≤ 127 (leave room for the null terminator) before the call, same spirit as `isValidPrivateKey`'s length pre-check (`genius_api.dart:1014-1036`) that refuses "a huge paste... without being copied." Reject/truncate in the UI layer with a visible error, not silently.

**Warning signs:** Metadata that round-trips through `RegisterChild` → `GetRegistrationsForMain` and comes back truncated or corrupted for any name with emoji/accents.

**Phase to address:** Register-child UI/validation plan.

---

### Pitfall 4: Fire-and-forget submitted != confirmed shown as done

**What goes wrong:** `FundChild`, `RecoverFromChild`, `RevokeChild` (and the fire-and-forget `RegisterChild`/`DetachChild`/`ReplaceMain` lifecycle calls) return `GENIUS_NODE_RET_OK` on **submission**, before consensus finalizes. The header is explicit and repeats this three times almost verbatim (lines ~648-654, ~707-718): `RecoverFromChild`'s destination-mismatch rejection and `RevokeChild`'s unauthorized-revoke rejection (`CheckParentChildAuthority`) are "only evaluated at consensus finalization and cannot be observed by this synchronous wrapper." A UI that shows "Recovered!" / "Revoked!" on `GENIUS_NODE_RET_OK` is lying — the op can still fail at finality with zero further signal back to this call site.

**Why it happens:** `GENIUS_NODE_RET_OK` reads like "it worked" to anyone who hasn't read the doc comment.

**How to avoid:** Model every fund/recover/revoke/detach/replace-main/register result as a `pending` state distinct from `confirmed`/`failed` in whatever state type the phase introduces — never collapse `GENIUS_NODE_RET_OK` straight to a success toast. Since there's no dedicated confirmation callback, the only honest signal available is polling `GetChildBalance`/`GetRegistrationsForMain` afterward and reconciling — and even that is ambiguous (Pitfall 5). Where no reconciliation is feasible this milestone, the UI copy must say "submitted" not "done," matching the PROJECT.md constraint already written for this milestone.
**Watch also:** the milestone's own known list (RegisterChild + FundChild/RecoverFromChild + RevokeChild) — this is the single most-repeated caveat in the header and the constraint PROJECT.md already names.

**Warning signs:** Any success toast/checkmark bound directly to the function's return value with no follow-up state.

**Phase to address:** Every child-transfer/lifecycle phase (fund, recover, revoke, detach, replace-main) — the state-modeling pattern should be decided once and reused, not re-invented per screen.

---

### Pitfall 5: `GetChildBalance`/`GetChildBalanceAll` return 0 for both "empty" and "not yet synced"

**What goes wrong:** The header states this outright for both functions (lines ~583-600): "0 is inherently ambiguous (no balance vs. not-yet-synced)," same caveat as the existing `GeniusSDKGetBalance`. A freshly funded child showing "0 GNUS" right after `FundChild` returns OK could be genuinely empty, or could be a CRDT view that hasn't caught up yet — indistinguishable from this call alone.

**Why it happens:** The balance read is local CRDT UTXO state, not a live consensus query — there's no separate "am I synced" signal exposed alongside it.

**How to avoid:** Never render a bare "0" immediately after a fund/recover action as if it were authoritative. Pair the balance read with the node's sync/processing status (`getProcessingStatus()`, `getNodeState()` already exist, `genius_api.dart:1356,1376`) and show a "still syncing" affordance rather than a confident zero. Poll rather than one-shot.

**Warning signs:** A UAT walk where funding a child and immediately checking its balance shows 0 and testers can't tell if the fund failed or just hasn't synced.

**Phase to address:** Child balance display plan; also flag for phase-specific research once live testnet access is restored (currently blocked by INITIALIZING_BLOCKCHAIN, see Pitfall 10).

---

### Pitfall 6: Account-switch race — `selectGeniusAccount(Async)` fired while a transfer/fund/recover/register is in flight

**What goes wrong:** SuperGenius's own fix history for the account subsystem (commits between the pinned SHAs) includes `e1b81120 fix(13-08): drain in-flight submission leases before switching accounts` and `5b9254c1 fix(13-08): hold account switch in flight until manager publication` — i.e. the node itself had to be hardened against switching accounts mid-submission. The wallet's synchronous `selectGeniusAccount` (`genius_api.dart:977-987`) and isolate-based `selectGeniusAccountAsync` (`:993-1007`, `:62-80`) give no indication either checks or waits for an in-flight submission on this side; nothing in `AppBloc._onSelectSDKAccount` (`app_bloc.dart:747-760`) guards against a fund/recover/register call started just before the switch completes. Two independent switcher selections in this milestone (SDK wallet vs. active wallet) double the surface for this: switching the SDK wallet while a child op targets the *previous* SDK wallet's account context is exactly the scenario the SuperGenius fixes target from the node side, but nothing stops the wallet from doing it.
**Watch also:** these are node-side mitigations for a node-side hazard; they don't imply the Dart layer is race-free — the isolate for `selectGeniusAccountAsync` returns as soon as the native call returns, which per the fire-and-forget pattern (Pitfall 4) may be before the switch is durable.

**Why it happens:** `GeniusNodeReturnValue_t` return values are synchronous acks, not completion signals, and the UI has no queue/lock serializing "switch account" against "submit an op."

**How to avoid:** Serialize account-switch and any child-transfer/lifecycle call through a single in-flight guard in the bloc/cubit layer (a simple "operation in progress" flag disabling both the switcher and action buttons is enough — no new dependency needed per AGENTS.md's YAGNI rule). Disable the switcher while any child op's pending state (Pitfall 4) is unresolved, and vice versa.

**Warning signs:** A UAT walk that fund-child's then immediately flips the header switcher and sees the fund silently apply to the wrong account, or a `GENIUS_NODE_ERROR_TRANSFER` that only reproduces when switching fast.

**Phase to address:** The header-switcher phase (guard added where both selections live) plus the child-transfer phases (guard consumed).

---

### Pitfall 7: "SDK wallet" vs "active wallet" — sending from the wrong account

**What goes wrong:** This milestone explicitly introduces two independent selections in one header switcher: which wallet the SDK **node runs as** (`getStartAccountAddress()`/`selectGeniusAccount`) vs. which wallet is **active for send/swap** (the existing `Wallet` selection in `lib/wallets`, unrelated to the SDK account). `getStartAccountAddress()`'s own doc comment (`genius_api.dart:1102-1104`) already warns: "The SDK account the node was started with... a delete of this account would not survive a restart" — i.e. these two concepts already diverge subtly today even before the new UI. A user who reads one switcher control but two independent states are changing (as the compute-panel matching logic in `lib/dashboard/compute/compute_state.dart` already relies on: "requires the connected node's wallet address to match the selected wallet's" — `dev_mock_sgnus.dart:46-49`) can send GNUS from an account they think is merely "connected," not "chosen to spend from."

**Why it happens:** Two selections rendered as one control is inherently confusable; the SDK account and the send-from wallet were previously two separate, rarely-both-visible UI surfaces (`account_dropdown_selector.dart`, wallet picker) that are now merged.

**How to avoid:** Make the two selections visually and textually distinct in the single switcher (label each row, e.g. "Node running as" vs. "Sending from") rather than one ambiguous name; require the send/swap confirmation drawer to always name the active wallet address explicitly (mirroring how the Reown approval drawer already names what it signs, per PROJECT.md's Squid milestone). Never let "switch SDK wallet" implicitly also switch the active/send wallet or vice versa — keep the two state slots orthogonal in whatever bloc/state class backs the switcher.

**Warning signs:** A UAT walk where switching one dropdown visibly changes balances/labels that the user associated with the *other* selection.

**Phase to address:** The header-switcher UI-SPEC phase — this is the milestone's core design risk per PROJECT.md's Goal statement, so it deserves its own UAT criterion, not an incidental check.

---

### Pitfall 8: Double-submit on fund/recover/revoke (no idempotency, no submit-button lock)

**What goes wrong:** Because these calls are fire-and-forget (Pitfall 4) with a delayed, unobservable finality, a user who taps "Fund Child" twice (slow UI, double-tap, or a retry after "it looked like nothing happened") can submit two transfers. There is no dedup key argument on `GeniusSDKFundChild`/`RecoverFromChild`/`RevokeChild` visible in the header — each call is a fresh submission.

**Why it happens:** The "submitted, not confirmed" ack (Pitfall 4) with no immediate balance change (Pitfall 5) makes the UI feel unresponsive, inviting a second tap.

**How to avoid:** Disable the action button for the whole pending window (tie to the same in-flight guard from Pitfall 6), and show an immediate optimistic "pending" row so the tap visibly registered before the button re-enables.

**Warning signs:** Two fund transactions of the same amount to the same child from one user action during a UAT walk.

**Phase to address:** Same child-transfer phases as Pitfall 4 — one shared guard, not per-screen state.

---

### Pitfall 9: Blocking the UI isolate with a synchronous FFI call

**What goes wrong:** The codebase already distinguishes sync vs. async FFI calls on purpose: `selectGeniusAccount` is a plain synchronous call with a comment explaining *why* no isolate is used ("FFI objects... are not sendable across isolate boundaries," `genius_api.dart:973-976`), while `selectGeniusAccountAsync` spins up a dedicated isolate (`:62-80`, `:989-1007`) specifically "so the UI thread stays responsive during account switching." The 11 new child functions are plain synchronous FFI calls with no async variant yet. `GetRegistrationsForMain` (a discovery query) and `GetChildBalance(All)` (a CRDT scan) are the likeliest to have non-trivial native-side latency — if bound synchronously and called from `build()`/an event handler without the isolate pattern, they will jank the UI exactly like `selectGeniusAccount` used to before its async twin existed.

**Why it happens:** Copy-pasting the simpler synchronous wrapper pattern (most of `genius_api.dart`'s existing calls, e.g. `transferTokens`, `mintTokens`) is less work than replicating the isolate dance, and the isolate pattern here is non-trivial (re-opening the dylib per isolate, since `DynamicLibrary`/`Pointer` aren't `Sendable`).

**How to avoid:** For any child call expected to block on I/O or a lock inside the node (registration discovery, balance scans, submission calls that wait on `manager publication` per the SuperGenius fix titles above), follow the `_selectGeniusAccountIsolate` pattern (`genius_api.dart:62-80`): reopen the library in the isolate, marshal only primitives (Strings, ints) across the `SendPort`, never a `Pointer`. Reserve synchronous calls for genuinely cheap reads.

**Warning signs:** Visible frame drops/jank during a UAT walk when opening the child-list screen or tapping fund/recover, especially once tested against a real (slow) testnet node rather than dev mocks.

**Phase to address:** Each binding phase should decide sync-vs-isolate per call up front, not retrofit after a jank report.

---

### Pitfall 10: No live network to verify child calls against — testnet loops in INITIALIZING_BLOCKCHAIN

**What goes wrong:** Per the milestone context, the node currently loops in `GENIUS_NODE_INITIALIZING_BLOCKCHAIN` on testnet on both old and new SDK builds — so `RegisterChild`, `GetRegistrationsForMain`, `FundChild`, etc. cannot be walked end-to-end against a real network today. A plan that defers all verification to "walk it on testnet" will stall indefinitely on an unrelated infra blocker (this is a control-case check per existing project practice — "Don't manufacture diagnoses" — verify the *same* fullnode-drop symptom appears on an unrelated existing SDK call before treating any child-call failure as a child-wallet bug).

**Why it happens:** SuperGenius `c575a16`'s fullnode keeps dropping the client node before `GENIUS_NODE_READY`; `upnp_enabled:false` is a known required workaround for a `bad_weak_ptr` crash, but does not fix the blockchain-init loop.

**How to avoid:** Build every child-wallet plan's verification around `lib/dev/` mocks first (there is already a `dev_mock_sgnus.dart`/`dev_flags.dart` pattern gated behind `kShowDevTools` + `GW_DEV_TOOLS`, used to reach otherwise-unreachable SGNUS-connected UI states without a live node — see `dev_mock_sgnus.dart:6-13`). Add equivalent dev fixtures for: a fake `GetRegistrationsForMain` result list, a fake pending/confirmed child balance, and fake OK/error returns for fund/recover/revoke — so UI and state-machine logic can be verified without the network. Treat any live-testnet UAT step as a separately-flagged, possibly-deferred criterion, not a blocking gate for the phase.

**Warning signs:** A plan whose only verification step is "walk it on testnet" with no dev-mock fallback listed.

**Phase to address:** Flag explicitly in ROADMAP for every phase touching a live child call — this needs its own dev-mock plan item, likely bundled with the binding phase.

---

### Pitfall 11: Key/mnemonic leaking into Bloc state or logs via the new account-linking surface

**What goes wrong:** Account linking ("each SDK account shows its source ETH wallet") pulls the mapping between an SDK address and the `StoredKey`/mnemonic that produced it (`_registerWallet`, `genius_api.dart:302-332`) closer to UI-facing state than before. AGENTS.md is explicit: a private key or mnemonic must never become a field on a Cubit/Bloc state class (states are equatable/printable and land in `BlocObserver` logs by default), and nothing derived from a seed/key may be logged or `toString()`'d. `getSelectedAccountMnemonic()` already exists (`genius_api.dart:1106-1118`) and returns a raw mnemonic string — any new "show linked wallet" or "recover mnemonic for this SDK account" UI must route this through a value that never touches Bloc state, not just avoid an obvious `debugPrint`.

**Why it happens:** Linking UI naturally wants to display "this SDK account came from wallet X" — a short hop from there to "let me show/copy the mnemonic," which is exactly the surface AGENTS.md flags.

**How to avoid:** Only ever hold and display the derived **address** (already a public value) in state; if a mnemonic-reveal flow is genuinely needed, fetch it on demand into a local widget variable, never a Bloc/Cubit field, and never pass it through `emit()`. Prefer `Uint8List` over `String` for any secret that is handled (per AGENTS.md), even though `getSelectedAccountMnemonic` currently returns `String?` — that's an existing API constraint to route around at the call site, not into new state.

**Warning signs:** A grep for `mnemonic`/`privateKey` hitting a `*State`/`*Cubit` class file, or any of those values appearing in a widget that also logs its state via `BlocObserver`.

**Phase to address:** Account-linking UI phase — add a code-review checklist item (grep) rather than relying on review attention alone.

---

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|-----------------|------------------|
| Treat `GENIUS_NODE_RET_OK` from fund/recover/revoke as final success in UI copy | Faster to ship, simpler state machine | Users see false confirmations; support burden when a "confirmed" transfer silently fails at consensus | Never — PROJECT.md already commits to a pending-state UI |
| Hand-type the child FFI structs instead of regenerating bindings | Skips learning the ffigen pipeline | Silent struct-layout drift vs. the real DLL, crashes only on some builds | Never |
| Poll `GetChildBalance` on a tight timer to paper over the not-synced ambiguity | Looks responsive | Battery/CPU cost, still doesn't disambiguate 0-vs-unsynced without a sync-status pairing | Short-lived, only immediately after a fund/recover action, paired with node-state check |

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|-----------------|-------------------|
| GeniusSDK child FFI | Binding functions by hand against a memorized signature | Regenerate from the actual shipped `GeniusSDK.h`; diff before/after struct sizes |
| GeniusSDK child FFI | Freeing `out_entries` pointer itself instead of `*out_entries`, or skipping `.cast<ffi.Void>()` | Mirror `getAvailableAccounts()`'s existing free pattern exactly |
| SuperGenius node account switching | Assuming the Dart-side `selectGeniusAccount(Async)` call is safe to fire mid-transfer because the node "handles races internally" | The node-side fixes (drain leases, hold switch in flight) reduce node-side corruption; they don't make the Dart call synchronous-safe from the UI's perspective — still serialize client-side |
| Testnet (SuperGenius `c575a16`) | Blocking a phase's verification entirely on a live testnet walk | Build dev-mock fixtures in `lib/dev/` first; testnet walk is a bonus/flagged criterion while INITIALIZING_BLOCKCHAIN persists |

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|-----------------|
| Synchronous `GetRegistrationsForMain`/`GetChildBalanceAll` calls on the UI isolate | Frame jank opening the child-list screen, worse on a real (slow) node than dev mocks | Use the isolate pattern from `_selectGeniusAccountIsolate` for any call expected to touch node-internal locks/CRDT scans | Noticeable once tested against real network latency, may be invisible against instant dev mocks |
| Naive balance-poll loop after every fund/recover | Battery/CPU drain, redundant FFI calls | Bound poll count/duration, stop once node state moves past `not-synced` or on explicit user dismiss | Multiple concurrent child rows each polling independently |

## Security Mistakes

| Mistake | Risk | Prevention |
|---------|------|------------|
| Mnemonic/private key surfaced through account-linking display logic | Key exposure via Bloc logs, Sentry, or a printed widget state | Address-only in state; mnemonic reveal (if any) stays local to a widget, never `emit()`'d |
| Treating "submitted" as authorization-checked | User believes a revoke/recover succeeded when `CheckParentChildAuthority` later rejects it at consensus | Never let the UI's "done" state be reachable from the synchronous return value alone |
| No cap check on `GeniusRegistrationMetadata` string fields before crossing FFI | Buffer overrun/truncation on `char[128]` arrays | Byte-length validation client-side before the call (see Pitfall 3) |

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-------------------|
| One switcher, two silent selections | User sends from an account they didn't mean to (Pitfall 7) | Label each selection explicitly; confirmation drawer always names the active wallet |
| "0" balance shown right after funding a child | User assumes the fund failed and retries (→ Pitfall 8 double-submit) | Pair balance display with node sync state; show "pending sync" not a bare 0 |
| Confirmation toast on fire-and-forget ops | False confidence, later confusion when the op silently fails at finality | "Submitted" language + a distinct pending/confirmed/failed visual state |

## "Looks Done But Isn't" Checklist

- [ ] **Child-list screen:** Often missing the zero-registrations-is-success distinction — verify a real empty list renders "no children yet," not an error state.
- [ ] **Fund/Recover/Revoke buttons:** Often missing a disabled/pending state — verify the button is unclickable for the full pending window, not just until the FFI call returns.
- [ ] **Header switcher:** Often missing explicit labeling of which selection is which — verify a first-time user can tell "node account" from "active wallet" without reading code.
- [ ] **FFI bindings:** Often "done" once it compiles — verify against the live `GeniusSDK.h` used to build the current prebuilt DLL, not an assumed/cached header.
- [ ] **Account-linking display:** Often done by reusing `getSelectedAccountMnemonic()`'s return value somewhere convenient — verify no mnemonic/private-key value reaches a Bloc/Cubit state class.

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|----------------|-----------------|
| Double-submitted fund/recover (Pitfall 8) | MEDIUM | No client-side undo exists (fire-and-forget, on-chain); requires a matching reverse transfer once confirmed, communicated to the user as a manual correction |
| Wrong-account send from switcher confusion (Pitfall 7) | HIGH | Same as any wrong-recipient/wrong-account send — no protocol-level reversal; only mitigation is confirmation-drawer prevention, not recovery |
| Leaked mnemonic in logs (Pitfall 11) | HIGH | Treat as key compromise: prompt wallet migration to a new key, audit log retention/Sentry scrub |
| Stale FFI binding crash (Pitfall 1) | LOW | Regenerate bindings, rebuild; caught at build/smoke-test time, not user-facing if verification runs first |

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|-------------------|----------------|
| Stale ffigen bindings (1) | Child-wallet FFI binding phase | Bindings regenerated from current header; one runnable check calls each new function against a dev-mock dylib stub or a real DLL smoke test |
| `out_entries` ownership (2) | Same binding phase (`GetRegistrationsForMain`) | Call twice in a loop with no crash/leak growth (Instruments/valgrind-equivalent or a repeated-call smoke test) |
| Metadata char[128] overflow (3) | Register-child UI phase | Unit test with a UTF-8-heavy string rejected before reaching FFI |
| Submitted-vs-confirmed (4) | Every child-transfer/lifecycle phase | UAT checks the UI never shows unqualified "done" on a fire-and-forget return |
| Balance-zero ambiguity (5) | Child balance display phase | UAT: fund then immediately view balance shows "pending," not silent 0 |
| Account-switch race (6) | Header-switcher phase + child-transfer phases | UAT: rapid switch-then-submit sequence doesn't apply to wrong account |
| SDK vs active wallet confusion (7) | Header-switcher UI-SPEC phase | UAT: user can name which control does what without reading code |
| Double-submit (8) | Child-transfer phases | UAT: double-tap fund/recover produces exactly one submission |
| UI isolate blocking (9) | Each binding phase | Frame-timing check or manual jank observation on the child-list/balance screens |
| No live network (10) | Roadmap-wide flag | Every child-call phase ships a dev-mock fixture alongside the real binding |
| Key/mnemonic leak (11) | Account-linking UI phase | Code-review grep for `mnemonic`/`privateKey` in new `*State`/`*Cubit` files |

## Sources

- `packages/genius_api/lib/src/genius_api.dart` (HIGH — direct code read: FFI call patterns, isolate usage, key-handling, `getStartAccountAddress`/`getSelectedAccountMnemonic`)
- `packages/genius_api/lib/ffi/genius_api_ffi.dart` (HIGH — confirms child functions/structs are unbound; `GENIUS_SDK_ADDRESS_SIZE` constant)
- `GeniusSDK/build/Windows/Release/GeniusSDK/include/GeniusSDK.h` (HIGH — authoritative struct layouts, ownership/free contracts, fire-and-forget notes, all v2.2-2.4 child function docs)
- SuperGenius blobless clone, `git log --oneline da035a7..c575a16 -- src/account` (MEDIUM — commit titles read directly; diffs not pulled, so exact mechanism is inferred from title + header cross-reference)
- `lib/dev/dev_mock_sgnus.dart`, `lib/dev/dev_flags.dart` (HIGH — existing dev-mock pattern for otherwise-unreachable SGNUS states)
- `lib/bloc/app_bloc.dart:743-760` (HIGH — current `_onSelectSDKAccount` handler, no in-flight guard present)
- `AGENTS.md` (HIGH — wallet-safety rules: no key/mnemonic in Bloc state, no logging, `Uint8List` preference)
- `.planning/PROJECT.md` (HIGH — milestone scope, known fire-and-forget/balance-ambiguity constraints, testnet blocker)

---
*Pitfalls research for: GeniusWallet v3.0 Child wallets & account linking*
*Researched: 2026-09-28*
