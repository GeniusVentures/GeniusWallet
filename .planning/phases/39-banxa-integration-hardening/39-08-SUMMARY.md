---
phase: 39-banxa-integration-hardening
plan: 08
subsystem: banxa-buy
tags: [banxa, buy, ui, checkout]
requires: [39-07]
provides:
  - "BanxaBuyScreen: the compact Buy card on BuyGnusCubit, handing off to /checkout"
key-files:
  created: [test/banxa/buy_card_test.dart]
  modified: [lib/screens/banxa_buy_screen.dart, lib/navigation/router.dart, lib/components/gw_control_track.dart, test/banxa/fixtures.dart, test/banxa/buy_page_layout_test.dart, test/banxa/banxa_reskin_literals_test.dart, test/components/drawer_padding_invariant_test.dart]
  deleted: [lib/banxa/banxa_order/create_order_cubit.dart, lib/banxa/banxa_order/create_order_state.dart, test/banxa/banxa_buy_screen_test.dart, test/banxa/buy_form_layout_test.dart, test/banxa/orders_header_track_test.dart, test/banxa/orders_rail_bounds_test.dart, test/banxa/order_rail_row_test.dart]
status: complete
actuals: {tokens: 14300, tasks: 3, commits: 3}
---
# Phase 39 Plan 08: Compact Buy card Summary

`/buy` is now one centred card that quotes GNUS live and hands the order to the in-app checkout; the old form, orders rail and MakeOrderCubit are gone.

## Result
- Full `flutter test`: 2322 passed, 6 skipped, 0 failed (plan 07 ended at 2347; the drop is the five deleted test files). `flutter analyze lib test` exit 0. Format, brace, raw-colour and lib/banxa key-logging scripts exit 0. ID gate printed 0 on all three commits. No trailers, email braianwegmann@hotmail.com.
- Commits: 07ea50b8 (pay and get parts, router, deletions), 016980a5 (To row, not-available states, sandbox pill, Buy orders link), fc24c2a3 (disclaimer, order hand-off, cubit deletion). No checkpoints or tracer tasks. STATE.md and ROADMAP.md untouched; no flutter_tester left running.
- Mutation check: removing the quote pause before the checkout push fails the pause test.
- Not run: a live walk of the card against a real Banxa sandbox key (none in this shell) and the switcher on a nested shell navigator.

## Decisions
- The screen builds its cubit in `initState` and takes an optional `createCubit`, so tests inject a cubit with no Hive and a known clock. The shared client comes from `context.read<BanxaApiService>()`, so the second `BanxaApiService()` construction plan 03 left is gone.
- The wallet is read right before `createOrder`, after the disclaimer, so the address sent is the one the To row shows.
- The currency drawer pops from its own context: it sits on the root navigator, not the shell's.
- The amount field only accepts digits and a dot, so a pasted "1,000" cannot silently disable the button.

## Deviations from Plan
- [Rule 1] The To row first used one line for name, address and Change and overflowed at 360px; the fit test caught it, so the name and address now stack.
- [Rule 1] Quote-grid labels are ellipsised like the values; "Banxa processing fee" overflowed at 360px.
- Stale mentions in `gw_control_track.dart` and a test comment about the removed rail and form were updated.
- The "Change opens the switcher" test seeds a real AppBloc with an unused GeniusApi, the same harness the account tests use.

## Known Stubs
None.

## Self-Check: PASSED
buy_card_test.dart exists, the two cubit files and five old tests are gone, all three commits are in `git log`.
