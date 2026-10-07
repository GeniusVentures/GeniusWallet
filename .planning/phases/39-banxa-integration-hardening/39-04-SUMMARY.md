---
phase: 39-banxa-integration-hardening
plan: 04
subsystem: banxa-orders
tags: [banxa, orders, polling, toasts]
provides:
  - "BanxaOrderStatus (parse, isFinal, isPaid, tone, label, shortLabel, description) and Order.banxaStatus"
  - "OrdersCubit poller: pollInterval, now, setForeground, track, refreshOrder; OrdersState.justFinished"
  - "showToast(actionLabel:, onAction:); BuyOrderToasts; open-order count on the Buy orders chip"
key-files:
  created: [lib/banxa/banxa_order/banxa_order_status.dart, lib/banxa/banxa_components/buy_order_toasts.dart, test/banxa/banxa_order_status_test.dart, test/banxa/orders_poller_test.dart, test/banxa/buy_order_toasts_test.dart]
  modified: [lib/banxa/banxa_order/banxa_order_cubit.dart, lib/banxa/banxa_order/banxa_order_state.dart, lib/components/toast/toast_manager.dart, lib/components/toast/toast_widget.dart, lib/dashboard/home/widgets/transactions_slim_view.dart, lib/main.dart, test/banxa/fake_banxa_api.dart, test/components/toast_test.dart, test/dashboard/buy_orders_filter_test.dart, pubspec.yaml, pubspec.lock]
status: complete
actuals: {tokens: 15300, tasks: 3, commits: 3}
---
# Phase 39 Plan 04: Status model, poller, completion toast Summary

Banxa order statuses are parsed once, open orders of the Selected wallet re-read themselves every 15 s from any page, and each order that finishes is announced by one toast with View order.

## Result
- Full `flutter test`: 2274 passed, 6 skipped, 0 failed (plan 03 ended at 2245). `flutter analyze lib test` exit 0; `dart format --set-exit-if-changed`, `tool/check_brace_style.sh`, `tool/check_raw_colors.sh` exit 0. ID gate printed 0 on all three commits.
- Commits: eb490823 (status model), 39ee3a9b (poller), d6b2659f (toasts, chip).
- No checkpoints, no tracer tasks. STATE.md and ROADMAP.md untouched.

## Decisions
- `justFinished` fires whenever the parsed status changes to a final one, so an expired order revived and completed between two ticks is still announced.
- A failed read is swallowed: the old row stays and the next tick retries. No logging, per the lib/banxa print rule.
- A toast skipped because checkout is showing is not replayed later.
- The action link is card-only; a compact toast ignores it. Action cards reserve a 140px stack stride instead of 96.
- The chip count pill sits on an opaque `surfaceElevated` backing so the warning wash reads the same over the active gradient.

## Deviations from Plan
- [Rule 3] `fake_async` added to `dev_dependencies` (`^1.3.3`); it was already locked at 1.3.3 as a transitive package, so `pubspec.lock` only flips it to "direct dev". The poller tests need `fakeAsync`, which `flutter_test` does not export.
- `FakeBanxaApi` already had the per-id status script from plan 01, so it only gained `readIds` and `holdOrderById`.
- The dashboard filter test's orders now use `complete`: the shared fixture default `completed` is not a Banxa wire status, parses to unknown and counts as open. The fixture default was left alone because older tests read it as the legacy tone ladder.
- Widget tests cannot `await cubit.close()` on the fake clock (it hangs); they `unawaited(...)` it and pump.

## Self-Check: PASSED
Created files exist, three commits are in `git log`, no trailer in any message. Known stubs: none.
