---
phase: 39-banxa-integration-hardening
plan: 03
subsystem: banxa-client
tags: [banxa, secrets, sandbox]
provides:
  - "lib/banxa/banxa_env.dart: kBanxaApiKey, kBanxaSandbox, banxaApiBase, kBanxaPartnerCode"
  - "BanxaApiService({apiKey, sandbox, client}), isConfigured, isSandbox, returnUri, BanxaRequestException(statusCode)"
  - "OrdersCubit requires api; main.dart provides one BanxaApiService"
key-files:
  created: [lib/banxa/banxa_env.dart, test/banxa/banxa_api_service_test.dart, test/banxa/no_banxa_secret_test.dart]
  modified: [lib/banxa/banxa_api_services.dart, lib/main.dart, lib/banxa/banxa_order/banxa_order_cubit.dart, lib/banxa/banxa_order/create_order_cubit.dart, lib/banxa/banxa_helpers/deep_link_service.dart, lib/banxa/user_kyc/kyc_registration.dart, test/banxa/fixtures.dart]
  deleted: [lib/banxa/banxa_helpers/order_service.dart]
status: complete
actuals: {tokens: 30000, tasks: 2, commits: 2}
---
# Phase 39 Plan 03: Key out of source, sandbox switch, one client Summary

The Banxa key now comes only from `--dart-define=GW_BANXA_API_KEY`, `GW_BANXA_SANDBOX=true` moves every call (order listing included) to the sandbox, and the app shares one required client.

## Result
- Full `flutter test`: 2245 passed, 6 skipped, 0 failed (plan 02 ended at 2232). `flutter analyze lib test` exit 0, `dart format --set-exit-if-changed`, `tool/check_brace_style.sh` and the key-logging scan over every `lib/banxa` file exit 0. ID gate printed 0 on both commits.
- Commits: f0f3c797 (client, env, tests), 9a33d905 (shared client, print removal, order_service deletion).
- The old key literal is gone from the tree and appears in no added line of either commit. It is still in git history and shipped binaries; rotation is the dashboard task in user_setup and is not done.
- No checkpoints or tracer gates in this plan.

## Decisions
- Non-2xx is any status outside 200-299 on every call; the old 404 special case on `getOrderById` now reads as `BanxaRequestException(404)`.
- The partner code lives in `banxa_env.dart` as `kBanxaPartnerCode` so the base URL and the KYC host share it.
- The print-family scan test was added in Task 2, not Task 1, so Task 1 stayed green.

## Deviations from Plan
- Two `BanxaApiService()` constructions remain outside this plan's file list: `lib/navigation/router.dart:127` (the QR route's PollingCubit) and `lib/screens/banxa_buy_screen.dart:101` (the Buy screen's own MakeOrderCubit). Both still build a client from the same defines, so behaviour is correct, but the final "no stray second client" grep will find them. Plan 09 (polling) and the Buy screen work should take them from `context.read`.
- `create_order_cubit.dart` lost its unused `flutter/foundation.dart` import after the debug print went (analyzer warning otherwise).

## Known Stubs
None. `create_order_cubit.dart` still passes its own `yourapp://banxa-callback` string into state; the return-URL plan owns it.

## Self-Check: PASSED
Both commits exist in `git log`, `banxa_env.dart` and both new tests exist, `order_service.dart` is absent, `.planning/STATE.md` and `ROADMAP.md` untouched.
