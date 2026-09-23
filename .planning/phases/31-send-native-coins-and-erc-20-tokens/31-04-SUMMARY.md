---
phase: 31-send-native-coins-and-erc-20-tokens
plan: 04
status: complete
requirements: [SEND-05]
key-files:
  created: [lib/send/recipient_field.dart, test/send/recipient_field_test.dart]
  modified: [lib/send/send_cubit.dart, lib/send/send_screen.dart, packages/genius_api/lib/web3/send_service.dart, packages/genius_api/lib/src/genius_api.dart, test/send/send_screen_test.dart, ios/Runner/Info.plist, macos/Runner/Info.plist, macos/Runner/DebugProfile.entitlements, macos/Runner/Release.entitlements]
actuals: { tokens: 6500, tasks: 3, commits: 4 }
---

# Phase 31 Plan 04: recipient safety -- paste, scan, self-send and contract warnings

`RecipientField` (extracted from `send_screen.dart`) adds paste, a platform-gated QR scan, a
self-send warning and a contract warning, all reading `SendCubit` directly. `SendCubit.setRecipient`
sets `selfSend` on a case-insensitive match and starts a one-shot `eth_getCode` check (new
`GeniusApi.hasCode`) for any other valid recipient, applying the answer only if the text hasn't
changed since. `addressFromScan` pulls the first `0x` address out of a scanned payload, ignoring an EIP-681 link's amount and chain.

## Baseline vs. after (measured)

`flutter test`: 1656 pass/5 skip -> 1672 pass/5 skip, exit 0 (+16, all new). `flutter analyze`
"No issues found!" at root and `packages/genius_api`. `dart format --set-exit-if-changed lib
test` (plus the two touched genius_api files), `check_brace_style.sh`, `check_raw_colors.sh`,
`check_no_new_key_logging.sh --scan-tree`, `check_onboarding_seed_safety.sh` and
`check_agent_rules_sync.sh`: all exit 0. `NSCameraUsageDescription` and
`com.apple.security.device.camera` each appear exactly once. Every touched file's `git ls-files
--eol` shows lf.

## Deviations

- **[Rule 1]** Extracting the recipient field dropped the inline `errorText: state.error` a failed
  `review()` used to show. First pass moved it to a toast; the coordinator caught that a toast isn't
  reliably screen-reader announced, so a follow-up commit added an `errorText` parameter and
  restored the inline display, removing the toast.
- **[Rule 2]** Added a `canScan` constructor parameter (default `defaultCanScanQr`) so tests can
  force the Scan button on/off without a real platform check -- not named in the plan's own task
  text but required by its "canScan false/true" acceptance case.

## Self-Check: PASSED
