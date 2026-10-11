# Boot and SDK init

## Requirements

From idea `honest-boot`:

- **Single-flight guard on SDK init.** `_initSDK` runs twice at boot: the router redirect
  (`lib/navigation/router.dart:56`) dispatches `InitializeSDK` before `sdkStatus` leaves
  `AppStatus.initial`, and `_isSdkInitialized` is only set at the end of `_initSDK`. Store the
  in-flight `Future` and return it to concurrent callers.
- **Any network leg in the readiness gate needs a timeout with a cached-data fallback.** A full
  run with DNS down (`Failed host lookup: api.coingecko.com`) only booted because market sections
  fail soft onto cache.
- **`GeniusSDKInit*` returning is NOT "SDK ready". It is the 10% mark.** Derive readiness from
  `getInitializationStatus()` reaching completion.
- **No Dart-driven animation can be promised for the first ~8.2 s of boot.** Spinner, blur and
  progress bar all render on the main isolate, which is frozen.

## How to Build It

1. Keep `GeniusSDKInitWithMnemonic` where it is (main isolate). Moving it buys nothing (see
   What to Avoid). Keep `decryptMnemonic` / private-key prep on main too: it costs 209-361 ms.
2. Add the single-flight guard first. It is pure Dart and independent of everything else:
   cache the `Future` of `_initSDK` and hand the same one to the second caller.
3. Treat boot as two windows:
   - **Window 1, inside `GeniusSDKInit*` (~8.2 s):** opaque. Show a static splash that does not
     pretend to animate. No timers fire, no frames pump.
   - **Window 2, after init returns, until ready:** the main isolate is responsive.
     Poll `getInitializationStatus()` (returns instantly) for a 0-1 percentage and a stage string
     such as `"Migrating database (step 1 of 5): v0.2.0 -> v1.0.0"`, which is fit to show
     verbatim. `transactionManagerState` reads `GENIUS_TM_STATE_CREATING` at this point.
4. Open the dashboard only when the status reaches completion, and gate any network-backed
   section with a timeout that falls back to cached data.
5. Instrumentation pattern that worked: a 100 ms `Timer.periodic` heartbeat at the top of
   `main()` logging any gap > 300 ms (`BOOTPROBE stall <ms>`), plus enter/exit timestamps
   around the FFI call. Remove it before merge.

## What to Avoid

- **`Isolate.spawn` for the init does not unfreeze the UI.** The init succeeds from a spawned
  isolate (returns OK, the main isolate then reads a valid 130-char address through its own
  `NativeLibrary` handle), but the main isolate still stalls ~8.2 s. A control timer that made
  no SDK call fired zero times. The block is below Dart, most plausibly native init contending
  for the platform main thread that the Dart main isolate runs on.
- **Do not blame leaf FFI.** All 41 `asFunction` bindings in `genius_api_ffi.dart` are non-leaf
  (0 x `isLeaf: true`).
- **Do not read a single poll sample during window 1 as "the status call blocks".** The one
  sample that arrived was the timer's first chance to run as the freeze lifted.
- **Do not gate the dashboard on init returning.** It would open while the SDK is still
  migrating its database.

## Constraints

- Only synchronous init entry points exist: `GeniusSDKInit`, `GeniusSDKInitWithKey`,
  `GeniusSDKInitWithMnemonic`, all returning `Pointer<Char>`. There is no native async init.
- Native state is process-global and visible across isolates in both directions (init-on-main
  then call-from-spawned, and the reverse).
- `DynamicLibrary`, `NativeLibrary` and `Pointer` are not sendable across isolates; only plain
  Dart values may cross.
- A genuinely animated first 8 s needs a non-blocking init in GeniusSDK/SuperGenius C++.
- All measurements were debug builds on macOS. Later Phase-13 cold-start traces (9.6 s,
  52.5% stall, 141 ms data-ready) are authoritative for those numbers, not these spikes.
- Open: does phase-2 progress reach 1.0, how long does it take, does it stall?

## Origin

Synthesized from spikes: 001, 002
Source files available in: sources/001-sdk-init-off-isolate/, sources/002-init-progress-polling/
