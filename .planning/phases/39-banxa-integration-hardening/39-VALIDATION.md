---
phase: 39
slug: banxa-integration-hardening
status: draft
nyquist_compliant: true
wave_0_complete: false
created: 2026-09-30
---

# Phase 39 — Validation Strategy

> Per-phase validation contract. Source: `39-RESEARCH.md` "Validation Architecture".

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | flutter_test (widget + unit), bloc_test where cubits change |
| **Config file** | none; `analysis_options.yaml` for analyze |
| **Quick run command** | `flutter test test/banxa test/transactions` |
| **Full suite command** | `flutter analyze && flutter test` (Flutter SDK at `C:/Users/User/Documents/Projects/GNUS/flutter/flutter/bin`, not on PATH) |
| **Estimated runtime** | ~60 seconds full suite |

## Sampling Rate

- **After every task commit:** quick run command
- **After every plan wave:** full suite command plus `bash tool/check_brace_style.sh` and `bash tool/check_no_new_key_logging.sh --scan-tree`
- **Before `/gsd-verify-work`:** full suite green
- **Max feedback latency:** 60 seconds

## Per-Task Verification Map

Automated tests run against `FakeBanxaApi` (test/banxa/fake_banxa_api.dart) or http's `MockClient`; no test depends on a `--dart-define`. `flutter` below is `C:/Users/User/Documents/Projects/GNUS/flutter/flutter/bin/flutter`.

| Task | Requirement | Automated verify |
|------|-------------|------------------|
| 39-01 T1 (tracer) | BUY-10, BUY-11 | `flutter test test/dashboard/ test/banxa/ test/dev/` (new `buy_orders_filter_test.dart`, incl. order-id copy) |
| 39-01 T2 | BUY-10 | `flutter test test/banxa/` (`orders_wallet_scope_test.dart`) |
| 39-01 T3 | BUY-11 | `flutter test` |
| 39-02 T1 | BUY-08 | `flutter test test/dashboard/buy_orders_filter_test.dart test/banxa/` (return-link redirect; router scan in `buy_page_layout_test.dart` no longer pins the removed route) |
| 39-02 T2 | BUY-14 | `flutter test` |
| 39-03 T1 | BUY-05, BUY-06 | `flutter test test/banxa/banxa_api_service_test.dart test/banxa/no_banxa_secret_test.dart` (incl. typed create-order failure) |
| 39-03 T2 | BUY-05, BUY-14 | `flutter test` + key-logging scan over every `lib/banxa` file (OrdersCubit client now required) |
| 39-04 T1 | BUY-09 | `flutter test test/banxa/banxa_order_status_test.dart` |
| 39-04 T2 | BUY-10 | `flutter test test/banxa/` (`orders_poller_test.dart`) |
| 39-04 T3 | BUY-11, BUY-12 | `flutter test` (`buy_order_toasts_test.dart`, `toast_test.dart`, chip count) |
| 39-05 T1 | BUY-09 | `flutter test test/banxa/order_status_style_test.dart test/banxa/order_transaction_mapping_test.dart test/dashboard/buy_orders_filter_test.dart` |
| 39-05 T2 | BUY-09, BUY-11 | `flutter test` + `'completed'` grep limited to intentional legacy cases + filtered-list grep empty |
| 39-06 T1 | BUY-01 | `flutter test test/banxa/buy_defaults_test.dart` |
| 39-06 T2 | BUY-01..BUY-04 | `flutter test test/banxa/` (`buy_gnus_cubit_test.dart`, incl. create-order failure and no URL in state) |
| 39-06 T3 | BUY-06 | `grep` for the recorded "Sandbox coin list" line |
| 39-07 T1 | BUY-08 | `flutter test test/banxa/checkout_rules_test.dart` (dot-boundary host cases) |
| 39-07 T2 | BUY-06, BUY-07, BUY-08 | `flutter test` (`checkout_screen_test.dart`) |
| 39-08 T1 | BUY-01, BUY-04 | `flutter test test/banxa/ test/components/drawer_padding_invariant_test.dart` (`buy_card_test.dart`) |
| 39-08 T2 | BUY-02, BUY-03, BUY-04, BUY-06, BUY-13 | `flutter test test/banxa/buy_card_test.dart` |
| 39-08 T3 | BUY-02 | `flutter test` |
| 39-09 T1 | BUY-07 | `flutter test test/banxa/checkout_rules_test.dart` |
| 39-09 T2 | BUY-07 | `flutter test` |
| 39-10 T1 | BUY-07 | `flutter test test/banxa/checkout_platform_config_test.dart` + lockfile unchanged |
| 39-10 T2 | BUY-07 | `flutter test test/banxa/checkout_rules_test.dart` |
| 39-11 T1 | BUY-11 | `flutter test test/banxa/order_drawer_footer_test.dart` |
| 39-11 T2 | BUY-11 | `flutter test` |
| 39-12 T1 | BUY-14 | `flutter test test/banxa/ test/components/` + deleted paths absent |
| 39-12 T2 | BUY-14 | `flutter test` + removed-symbol grep empty |
| 39-13 T1 | BUY-13 | `flutter test test/banxa/buy_entry_points_test.dart test/tokens/ test/dashboard/ test/components/` (Home, Assets, GNUS page, Transactions) |
| 39-13 T2 | BUY-05 | YAML parse of build.yml + define/secret/mask greps |
| 39-13 T3 | all | `flutter test && flutter analyze lib test` + every tool/ script + only main.dart constructs the client + Windows sandbox debug build; GATE A and GATE B in the live walk |

## Wave 0 Requirements

- [ ] `git submodule update --init` and `flutter pub get` in the worktree, baseline recorded (39-01 T1)
- [ ] Fake Banxa API used by all Banxa tests, constructor-injected (39-01 T1)
- [ ] Banxa order status enum with a table test covering all eleven wire statuses (39-04 T1)
- [ ] Sandbox coin list checked before the Buy card is built (39-06 T3)

## Manual-Only Verifications

| Behavior | Why Manual | Test Instructions |
|----------|------------|-------------------|
| A full sandbox buy completes and lands as `complete` in Transactions | Needs the Banxa sandbox key and hosted checkout | Sandbox build, test card 4111 1111 1111 1111, OTP 7203; watch the order reach Done under Buy orders |
| Full-screen checkout per platform (Android, iOS, macOS, Windows) | Platform webviews and camera prompts | Open checkout, complete ID step, close early, confirm return and status |
| GNUS listed on Banxa | Banxa-side action | Re-query `/v2/crypto/buy` for partner `gnus` |

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] No 3 consecutive tasks without automated verify
- [x] Wave 0 covers all missing references
- [x] No watch-mode flags
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
