---
phase: 39-banxa-integration-hardening
fixed_at: 2026-09-30T20:00:00Z
review_path: .planning/phases/39-banxa-integration-hardening/39-REVIEW.md
iteration: 1
findings_in_scope: 13
fixed: 13
skipped: 0
status: all_fixed
---

# Phase 39: Code Review Fix Report

**Fixed at:** 2026-09-30
**Source review:** .planning/phases/39-banxa-integration-hardening/39-REVIEW.md
**Iteration:** 1

**Summary:**
- Findings in scope: 13 (WR-01 to WR-13; Info items left alone)
- Fixed: 13
- Skipped: 0

Every finding was checked against the code first and held. Each fix has one regression test. The tests were run against the old code and failed there, except WR-09 and WR-12 (and the WR-06 re-run after the clock parameter was added; its first run against the old code failed both tests), where the test needs the new parameter or function and cannot compile without the fix.

## Fixed Issues

### WR-01: Wallet address sent to Banxa at launch
**Files:** `lib/banxa/banxa_order/banxa_order_cubit.dart`, `lib/banxa/banxa_order/buy_gnus_cubit.dart`, `lib/main.dart`, `test/banxa/orders_wallet_scope_test.dart`
**Commit:** 7ca1b89a
**Applied fix:** `fetchOrders` now does no network call unless the API has a key and the user has accepted the first-buy disclaimer (`hasBuyHistory`, wired in `main.dart` to the same stored flag the Buy flow uses, now exposed as `readBanxaDisclaimerAccepted`). It settles on an empty success state instead. `track()` still works without it, and the dev fixture seam runs before the gate. Choice made: the disclaimer flag stands in for "has a Banxa relationship"; no separate order-history flag was added. Consequence: someone who bought with an older build and has not accepted the disclaimer sees no Buy orders until they open Buy and accept it.

### WR-02: No timeout on Banxa requests
**Files:** `lib/banxa/banxa_api_services.dart`, `test/banxa/banxa_api_service_test.dart`
**Commit:** f6707814
**Applied fix:** A private `_get` wrapper and the `POST /buy` call both apply a 20 second timeout (constructor parameter so the test can shorten it). The test hangs the client and expects `TimeoutException`; with the timeout removed it hangs.

### WR-03: A list fetch erases a tracked order
**Files:** `lib/banxa/banxa_order/banxa_order_cubit.dart`, `test/banxa/orders_poller_test.dart`
**Commit:** f4978341
**Applied fix:** Orders added through `track()` are remembered by id (cleared on wallet switch) and re-added after a list fetch that does not contain them. A single read (`track`, `refreshOrder`) is now dropped only when the customer key changed, not whenever any fetch started; poll ticks still yield to a newer fetch. Two tests cover both directions; both fail on the old code.

### WR-04: Complete payment offered for paid or unrecognised orders
**Files:** `lib/banxa/checkout/checkout_screen.dart`, `test/banxa/checkout_screen_test.dart`
**Commit:** 6afc6a82
**Applied fix:** The button shows only for `pendingPayment` and `extraVerification`. Other statuses fall through to the existing no-action result (status text, Back to Buy, View order).

### WR-05: Declined, expired, cancelled and refunded orders read as incoming GNUS
**Files:** `lib/banxa/banxa_order/banxa_order_status.dart`, `lib/banxa/banxa_helpers/order_transaction_mapping.dart`, `lib/banxa/checkout/checkout_screen.dart`, two test files
**Commit:** 197da2aa
**Applied fix:** New `BanxaOrderStatus.deliversNothing`. Row amounts for those four statuses carry no sign; `CheckoutResult` hides the GNUS headline for them. `unknown` keeps its current treatment (not changed, since nothing is known about it).

### WR-06: A stale quote can create an order
**Files:** `lib/banxa/banxa_order/buy_gnus_cubit.dart`, `test/banxa/buy_gnus_cubit_test.dart`
**Commit:** 2b48e5f1
**Applied fix:** `pause()` marks a held quote stale. `createOrder` refuses, marks stale and starts a re-quote when the quote is stale, has no fetch time, or is older than two refresh intervals. The cubit takes an injectable clock (`now`) so the age rule can be tested under fake time.
**Status note:** logic change; please confirm the behaviour in a live walk.

### WR-07: Disabled Buy with no reason for a non-EVM address
**Files:** `lib/banxa/banxa_order/buy_gnus_state.dart`, `lib/screens/banxa_buy_screen.dart`, `test/banxa/buy_card_test.dart`
**Commit:** d2c777cf
**Applied fix:** `BuyGnusState.blockedReason(wallet)` returns the watch-only or the new unsupported-address line; `ctaFor` and the To row both use it, so they cannot disagree.

### WR-08: "Paid by card" hard-coded
**Files:** `lib/screens/banxa_buy_screen.dart`, `lib/banxa/banxa_helpers/order_transaction_mapping.dart`, two test files
**Commit:** f3163507
**Applied fix:** The single-method row prints `Paid by <method name from Banxa>` with a card icon only when the name contains "card", a bank icon otherwise. The order row subtitle uses `paymentMethodName`, with "Card purchase" only when it is blank. A USD card now reads "Paid by Card" (Banxa's name), not "Paid by card".

### WR-09: Failed orders fetch reads as "No buy orders yet"
**Files:** `lib/dashboard/home/widgets/transactions_slim_view.dart`, `lib/dashboard/transactions/view/transactions_stream.dart`, `lib/dashboard/transactions/sgnus_transactions_screen.dart`, `test/dashboard/buy_orders_filter_test.dart`
**Commit:** 910e9051
**Applied fix:** `TransactionsSlimView` takes the orders status and a retry callback (passed from the two call sites; the widget does not read the cubit). Empty Buy orders shows a loading state or "Couldn't load your buy orders" with Try again. `initial` is treated as empty, not loading, because a cubit with no wallet never leaves `initial`.

### WR-10: Percent-escaped host accepted
**Files:** `lib/banxa/checkout/checkout_rules.dart`, `test/banxa/checkout_rules_test.dart`
**Commit:** cdefe637
**Applied fix:** The host must match `^[a-z0-9.-]+$` before the Banxa suffix test. This covers `%2F`, an encoded tab and other control characters, not only `%`. New rejected cases added.

### WR-11: Cleartext http in the payment and ID webview
**Files:** `lib/banxa/checkout/checkout_rules.dart`, `test/banxa/checkout_rules_test.dart`
**Commit:** 1f482855
**Applied fix:** `allowsCheckoutNavigation` accepts `https` and `about` only; http cases moved to the blocked list.

### WR-12: ID photos stay in the app cache
**Files:** `lib/banxa/checkout/checkout_rules.dart`, `lib/banxa/checkout/checkout_webview.dart`, `test/banxa/checkout_rules_test.dart`
**Commit:** 0483771b
**Applied fix:** `clearPickedIdFiles` calls `FilePicker.clearTemporaryFiles()` on Android and iOS only (the call is unimplemented on desktop), swallows errors, and runs on dispose only if a file was picked in that session. It clears the plugin's whole cache, so a file picked by another screen at the same moment would also go.

### WR-13: One malformed order breaks the list; metadata type mismatch
**Files:** `lib/banxa/banxa_model.dart`, `test/banxa/banxa_api_service_test.dart`
**Commit:** a33788cb
**Applied fix:** `Order.fromJson` defaults missing strings to empty, converts numbers to text, ignores a non-map `metadata`, and rejects an order with no id. `OrdersResponse.fromJson` skips orders that fail to parse. Skips are not counted. The `metadata: 'real'` the app sends is unchanged; its shape still needs confirming against a sandbox response.

## Skipped Issues

None.

## Verification

Run in the isolated checkout `C:/Users/User/Documents/Projects/GNUS/GW-v3` (git worktree on `gsd/v3.0-banxa-hardening`), not a second fixer worktree, because it already has the dependencies the gates need. Results are reproducible from that tree at HEAD `a33788cb`.

| Gate | Result |
|------|--------|
| `dart format --set-exit-if-changed` on the 24 changed Dart files | exit 0, 0 changed |
| `flutter analyze` (whole project) | exit 0, "No issues found" |
| `bash tool/check_brace_style.sh` | exit 0 |
| `bash tool/check_raw_colors.sh` | exit 0 |
| `bash tool/check_no_new_key_logging.sh --scan-tree` (default file) | exit 0 |
| same with `lib/account/sdk_account_manager.dart` plus all `lib/banxa/*.dart` (the CI form) | exit 0 |
| `flutter test` (full) | exit 0, 2360 passed, 6 skipped (baseline 2341 passed, 6 skipped; 19 new tests) |

No `flutter_tester` processes remain. No Banxa key value was written anywhere and no Banxa API or workflow was called. Commit messages carry no attribution; author email is `braianwegmann@hotmail.com`.

---

_Fixed: 2026-09-30_
_Fixer: gsd-code-fixer_
_Iteration: 1_
