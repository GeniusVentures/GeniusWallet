---
spike: 001
name: sdk-init-off-isolate
type: standard
validates: "Given a wallet with a stored mnemonic, when GeniusSDKInitWithMnemonic runs inside Isolate.spawn, then it returns non-null, the main isolate's event loop shows no stall > 300ms, and the main isolate can afterwards call GeniusSDKGetAddress / getInitializationStatus / getTransactionManagerState"
verdict: INVALIDATED
related: [002]
tags: [ffi, isolate, boot, sgns-sdk, splash]
---

# Spike 001: SDK Init Off the Main Isolate

> NOTE (2026-07-23): the later 9.6 s / 52.5%-stall / 141 ms-data-ready figures cited by sketch 015 and Phase 13 come from a subsequent 40 s / 161-poll cold-start trace, NOT from this spike. This spike measured ~8.2 s freeze; the 52.5% stall curve was UNMEASURED here (see spike 002). Treat the Phase-13 trace as authoritative for those three numbers.

## What This Validates

**Given** a GeniusWallet install holding a wallet with a stored mnemonic,
**when** `GeniusSDKInitWithMnemonic` is called inside an `Isolate.spawn` rather than
on the main isolate,
**then** it returns a non-null pointer, the main isolate's 100 ms heartbeat records
no stall > 300 ms, and afterwards the main isolate can still drive the SDK through
its own `NativeLibrary` handle (`GeniusSDKGetAddress`, `GeniusSDKGetInitializationStatus`,
`GeniusSDKGetTransactionManagerState`).

## Why This Matters

Measured on `redesign/homepage-chrome-260721` before any change:

```
BOOTPROBE ffi-init ENTER (isMnemonic=true)
BOOTPROBE ffi-init EXIT after 8351ms
BOOTPROBE stall 8610ms ending at t=11814ms
```

`GeniusSDKInitWithMnemonic` blocks the Dart main isolate for **8.35 s** at boot. The
100 ms heartbeat timer did not fire for **8.61 s**, so Flutter could not pump a single
frame. That is the whole reason the splash's `LoadingAnimationWidget.flickr` appears
frozen — it is not a static asset, its `AnimationController` simply never gets ticked.

Consequence for design: **no splash treatment can fix this.** A blur overlay, a
progress bar, a different spinner — all of them render on the main isolate and would
be equally frozen. Unblocking the isolate is a precondition for any visual work.

## Research

No async variant exists in the generated bindings. Full set of init-related symbols
in `packages/genius_api/lib/ffi/genius_api_ffi.dart`:

```
GeniusSDKInit, GeniusSDKInitWithKey, GeniusSDKInitWithMnemonic
GeniusSDKGetInitializationStatus, GeniusSDKGetProcessingStatus, GeniusSDKGetTransactionStatus
```

All three init entry points are synchronous, returning `Pointer<Char>`. So there is no
"start init, poll for completion" native API to fall back on — moving the call to
another isolate is the only lever available from Dart.

| Approach | Pros | Cons | Status |
|----------|------|------|--------|
| `Isolate.spawn` re-opening the dylib | In-repo precedent; no native changes; keeps FFI handles isolate-local | Relies on the native SDK tolerating init off the main thread | **Chosen** |
| Native async init entry point | Cleanest; would let the SDK own its own threading | Requires a change in SuperGenius/GeniusSDK C++ and a dep rebuild — out of reach for this milestone | Rejected for now |
| Accept the block, show a static splash | Zero work | 8.6 s of a dead window; fails the stated goal | Rejected |

**Chosen approach and its precedent.** `_selectGeniusAccountIsolate`
(`packages/genius_api/lib/src/genius_api.dart:59-77`) already does exactly this shape
for `GeniusSDKSelectGeniusAccount`, with a comment stating the rationale: *"Opens the
native library independently (the OS shares code pages across isolates) and calls
[GeniusSDKSelectGeniusAccount] off the main isolate so the UI thread stays responsive."*

Note the direction: that precedent proves **init-on-main → call-from-spawned-isolate**
works. This spike needs the **opposite** direction — **init-in-spawned-isolate →
call-from-main**. Both rely on the same underlying fact (one `dlopen` per process,
shared C++ globals), but only the experiment settles whether the SGNS node has thread
affinity that makes the reverse fail.

Encouraging signal: `GeniusSDKGetInitializationStatus()` returning a 0–1 percentage
only makes sense if some thread can observe init progress while another thread drives
it. That implies the native side was written to be polled cross-thread.

## How to Run

The spike is instrumented inside the real app (the mnemonic lives in the macOS
keychain inside the app sandbox, so a standalone `dart run` harness cannot reach it).

```bash
# from the repo root
export CMAKE_ARGUMENTS='-DCMAKE_BUILD_TYPE=Release'
flutter run -d macos --dart-define=GW_DEV_TOOLS=true
```

Then filter the log for `SPIKE001`, `SPIKE002` and `BOOTPROBE`.

Instrumentation lives in (all TEMPORARY, marked in-source):
- `lib/main.dart` — `BOOTPROBE` 100 ms heartbeat on the main isolate
- `packages/genius_api/lib/src/genius_api.dart` — `_initSdkIsolate` entry point,
  the rewritten `_initSDK` body, and the post-init main-isolate SDK calls

This is a fact/benchmark question (does it work, how long does it block), so log
output is the verification surface rather than a UI — per the spike workflow's
carve-out for binary and benchmark questions.

## What to Expect

Pass looks like:

```
SPIKE001 secret-prep (main isolate) <N>ms (isMnemonic=true)
SPIKE001 isolate spawned in <N>ms
SPIKE002 poll#1 t=200ms pct=... msg="..."
...
SPIKE001 isolate result=OK:<N>  wall=<N>ms  polls=<N>
SPIKE001 main-isolate GeniusSDKGetAddress -> "0x..." (len=42)
SPIKE001 post-init status pct=1.0 msg="..."
SPIKE001 transactionManagerState=...
```

and **no** `BOOTPROBE stall` line anywhere near the init window.

Fail modes to watch for, each of which changes the plan:
- `result=ERR_NULL:<N>` — init refuses to run off the main thread
- `GeniusSDKGetAddress -> "<EMPTY>"` — native state not visible from main isolate
- a crash / SIGSEGV in the log — thread affinity violation in the C++ node
- `BOOTPROBE stall` still present — something else on the main isolate blocks too
  (prime suspect: `secret-prep`, which is TrustWallet FFI and stays on main)

## Investigation Trail

**Iteration 1 — establish the baseline.** Added a 100 ms `Timer.periodic` heartbeat at
the top of `main()` plus enter/exit timestamps around the FFI init. Cold run produced
the numbers quoted above: an 8351 ms init and an 8610 ms event-loop stall spanning it.
Also confirmed `isMnemonic=true`, so the `GeniusSDKInitWithMnemonic` branch is the one
that matters here.

Two incidental findings from the same run, both pre-existing and neither introduced by
this work:
- `_initSDK` runs **twice** at boot (two `Base path directory:` lines), the second
  throwing `LateInitializationError: Field '_basePath' has already been initialized`.
  The router redirect (`lib/navigation/router.dart:56`) dispatches `InitializeSDK`
  before `sdkStatus` leaves `AppStatus.initial`, and `_isSdkInitialized` is only set at
  the *end* of `_initSDK`. Making init non-blocking widens that race window from
  milliseconds to ~8.35 s, so a single-flight guard is now mandatory, not cosmetic.
  Recorded as a requirement in `../MANIFEST.md` rather than spiked — it is preventable
  in Dart, and you do not spike what you can simply not do.
- The whole run happened with **DNS down** (`Failed host lookup: api.coingecko.com`,
  repeatedly). The app still booted because the market sections fail soft onto cached
  data. That is load-bearing for the dashboard-gate design: gating boot on those
  sections without a timeout would have hung the app on this very run.

**Iteration 2 — move the call.** Added `_initSdkIsolate`, mirroring
`_selectGeniusAccountIsolate`: it re-opens the dylib via `loadGeniusSDKLibrary()`,
allocates its own native strings from plain Dart `String`s, and sends back only
`'OK:<ms>'` / `'ERR_*:<ms>'`. Nothing but Dart values crosses the isolate boundary, so
the "DynamicLibrary, NativeLibrary and Pointer are not sendable" constraint noted at
`genius_api.dart:960` is respected.

Deliberately kept `decryptMnemonic` / `privateKey` extraction on the **main** isolate
and timed it separately as `secret-prep`. The original 8351 ms measurement bracketed
both the TrustWallet key work and the SGNS init, so the split is needed to know whether
moving only the SGNS call actually clears the stall.

**Iteration 3 — the move works, the stall does not go away.** First instrumented run:

```
SPIKE001 secret-prep (main isolate) 209ms (isMnemonic=true)
SPIKE001 isolate spawned in 4ms
BOOTPROBE stall 8145ms ending at t=12767ms
SPIKE002 poll#1 t=8151ms pct=0.10 msg="Migrating database (step 1 of 5): v0.2.0 -> v1.0.0"
SPIKE001 isolate result=OK:8141  wall=8154ms  polls=1
SPIKE001 main-isolate GeniusSDKGetAddress -> "0x1d9b...4a87" (len=130)
```

Good news buried in there: the init **succeeded from the spawned isolate** (`OK:8141`),
and the main isolate afterwards read a valid 130-char address through its own
`NativeLibrary` handle. So the native state genuinely is process-global and visible
across isolates — the reverse direction of the `_selectGeniusAccountIsolate` precedent
holds.

Bad news: the 8145 ms main-isolate stall is still there. And `polls=1` — a 200 ms timer
fired **once**, at t=8151 ms. First hypothesis: the timer did fire on schedule at
~200 ms, called `getInitializationStatus()`, and *that* call blocked on the native
init lock until 8151 ms, printing only on return. In other words: my own progress
polling was re-blocking the UI.

**Iteration 4 — control run, timer touches nothing.** Replaced the poll body with a
bare tick counter that makes no SDK call at all. If the main isolate were free, ticks
would accumulate every 200 ms.

```
SPIKE001 secret-prep (main isolate) 361ms (isMnemonic=true)
SPIKE001 isolate spawned in 8142ms
BOOTPROBE stall 8211ms ending at t=13320ms
SPIKE001 isolate result=OK:8139  wall=8214ms  polls=0
```

`polls=0`. The timer **never fired at all**, and `await Isolate.spawn(...)` itself
appeared to take 8142 ms (versus 4 ms in the previous run — the same statement, so the
difference is only *where* the block got attributed, not whether it happened).

This kills the iteration-3 hypothesis. No Dart code on the main isolate touched the SDK
during the window, and the main isolate was still frozen for 8.2 s.

**Iteration 5 — ruling out the leaf-FFI explanation.** The standard reason a long
synchronous FFI call freezes an entire isolate group is `isLeaf: true` bindings: leaf
calls skip the native thread-state transition, so the calling thread never reaches a
GC safepoint and a stop-the-world collection hangs every isolate in the group.

Checked the generated bindings:

```
$ grep -c "isLeaf: true" packages/genius_api/lib/ffi/genius_api_ffi.dart
0
$ grep -c "asFunction"  packages/genius_api/lib/ffi/genius_api_ffi.dart
41
```

All 41 bindings are non-leaf. That explanation is out.

## Results

**Verdict: INVALIDATED ✗** — for the stated approach. Moving `GeniusSDKInitWithMnemonic`
into `Isolate.spawn` does **not** free the main isolate.

Evidence, consistent across three cold runs:

| Run | Init location | Main-isolate stall | Native init | Timer ticks during init |
|-----|---------------|--------------------|-------------|--------------------------|
| baseline | main isolate | 8610 ms | 8351 ms | — |
| iter 3 | spawned isolate, polling status | 8145 ms | 8141 ms | 1 (and it blocked) |
| iter 4 | spawned isolate, no SDK calls | 8211 ms | 8139 ms | **0** |

The stall tracks the native call almost exactly regardless of which isolate issues it.

**What IS proven (and is reusable):**
- The init runs correctly from a spawned isolate — returns non-null, and the main
  isolate then reads a valid address, a status, and a transaction-manager state through
  its own handle. Cross-isolate visibility of the native state is not the problem.
- `secret-prep` (TrustWallet `decryptMnemonic` on the main isolate) is only
  **209–361 ms**. It is not a meaningful share of the 8.35 s and does not need moving.
- Dart-level bindings are non-leaf, so this is not the textbook leaf-FFI safepoint bug.

**Therefore the block is below Dart.** The remaining explanation consistent with all
three runs is that `GeniusSDKInit*` blocks the process's main thread from inside native
code — most plausibly by dispatching work to (or otherwise contending for) the platform
main thread that the Dart main isolate runs on for desktop Flutter. No arrangement of
Dart isolates can route around that; the fix would have to be native-side, in
GeniusSDK/SuperGenius.

**Unplanned finding that changes the design regardless — init returning ≠ SDK ready.**
Immediately after `GeniusSDKInit*` returned OK, the main isolate read:

```
post-init status pct=0.10 msg="Migrating database (step 1 of 5): v0.2.0 -> v1.0.0"
transactionManagerState=GENIUS_TM_STATE_CREATING
```

So the 8.2 s blocking call only gets the SDK to **10%**. There is a further,
**non-blocking** initialization phase afterwards that reports real staged progress and
is pollable from the main isolate without hanging (that post-init call returned
instantly). This splits the boot into two qualitatively different windows:

1. **0 → 8.2 s: opaque and frozen.** Nothing can animate, nothing can be reported.
2. **8.2 s → ready: observable and responsive.** `getInitializationStatus()` yields a
   percentage plus a human-readable stage ("Migrating database (step 1 of 5)"),
   exactly what a determinate progress bar needs.

**Consequence for the splash design.** The determinate progress bar chosen during
intake is feasible **only for window 2**. Window 1 admits no Dart-driven animation of
any kind — spinner, blur, or progress bar alike. Any design that claims to show live
progress from second zero cannot be built on this SDK as it stands.

