# 20261110-glm — FFI bindings for task ids/results + live jobsProcessed

The gnus_dashboard-v1 dependency table (SDK-JOBID/SDK-STATUS/SDK-PAYOUT)
waits on data the node already exposes; GeniusSDK develop implements it
(GeniusSDKGetMyTaskIds newline ids, GeniusSDKGetTaskResult protobuf
GeniusArray, GeniusSDKGetPayoutAddress). This quick task wires the wallet
side so `gnus_getEarnings` carries a real `jobsProcessed` count.

## Changes

- `packages/genius_api/lib/ffi/genius_api_ffi.dart`: bindings for
  `GeniusSDKGetMyTaskIds`, `GeniusSDKGetTaskResult`, `GeniusSDKGetPayoutAddress`
  matching the FFI contract already documented in this file.
- `packages/genius_api/lib/src/genius_api.dart`: `getMyTaskIds` (newline-split),
  `getTaskResultBytes` (GeniusArray → Uint8List, freed with GeniusSDKFree),
  `getPayoutAddress`. All null when the SDK is uninitialized or the bundled
  build predates the symbols — callers keep contract nulls, no fake data.
- `lib/gnus_bridge/gnus_rpc_handler.dart`: `_getEarnings` reports
  `jobsProcessed` from `getMyTaskIds().length` (null on unsupported builds).

## Out of scope

- Earnings `history` rows: need a Dart SGProcessing proto to decode
  `GeniusSDKGetTaskResult` bytes (D2).
- `jobsProcessed` semantics: the ids mix submitted and processed tasks; a
  processed-only count waits on SDK-STATUS.

## Verification

- `flutter analyze` on the touched files: 0 errors.
- `flutter test test/gnus_bridge/ test/submit_job/`: green.
- Live check: with an SDK build exporting the symbols, getEarnings returns a
  real count; on older builds it stays null (contract preserved).
