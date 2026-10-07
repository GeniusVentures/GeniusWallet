---
phase: 39-banxa-integration-hardening
reviewed: 2026-09-30T17:35:00Z
depth: standard
files_reviewed: 74
files_reviewed_list:
  - .github/workflows/build.yml
  - android/app/src/main/AndroidManifest.xml
  - ios/Runner/Info.plist
  - lib/banxa/banxa_api_services.dart
  - lib/banxa/banxa_components/buy_order_toasts.dart
  - lib/banxa/banxa_components/order_details_drawer.dart
  - lib/banxa/banxa_components/order_drawer_footer.dart
  - lib/banxa/banxa_components/order_status_style.dart
  - lib/banxa/banxa_env.dart
  - lib/banxa/banxa_helpers/buy_defaults.dart
  - lib/banxa/banxa_helpers/deep_link_service.dart
  - lib/banxa/banxa_helpers/order_transaction_mapping.dart
  - lib/banxa/banxa_model.dart
  - lib/banxa/banxa_order/banxa_order_cubit.dart
  - lib/banxa/banxa_order/banxa_order_state.dart
  - lib/banxa/banxa_order/banxa_order_status.dart
  - lib/banxa/banxa_order/buy_gnus_cubit.dart
  - lib/banxa/banxa_order/buy_gnus_state.dart
  - lib/banxa/checkout/checkout_rules.dart
  - lib/banxa/checkout/checkout_screen.dart
  - lib/banxa/checkout/checkout_webview.dart
  - lib/banxa/checkout/checkout_webview_windows.dart
  - lib/banxa/checkout_qr.dart
  - lib/components/coins/view/coins_screen.dart
  - lib/components/gw_control_track.dart
  - lib/components/overlay/global_swap_fab_host.dart
  - lib/components/overlays/gw_menu_item.dart
  - lib/components/toast/toast_manager.dart
  - lib/components/toast/toast_widget.dart
  - lib/dashboard/assets/assets_screen.dart
  - lib/dashboard/home/widgets/transactions_slim_view.dart
  - lib/dashboard/transactions/sgnus_transactions_screen.dart
  - lib/dashboard/transactions/transactions_screen.dart
  - lib/dashboard/transactions/view/transactions_stream.dart
  - lib/dev/dev_banxa_fixtures.dart
  - lib/main.dart
  - lib/navigation/router.dart
  - lib/screens/banxa_buy_screen.dart
  - lib/tokens/token_info_screen.dart
  - macos/Runner/DebugProfile.entitlements
  - macos/Runner/Info.plist
  - macos/Runner/Release.entitlements
  - pubspec.yaml
  - test/banxa/banxa_api_service_test.dart
  - test/banxa/banxa_order_status_test.dart
  - test/banxa/banxa_reskin_literals_test.dart
  - test/banxa/buy_card_test.dart
  - test/banxa/buy_defaults_test.dart
  - test/banxa/buy_entry_points_test.dart
  - test/banxa/buy_gnus_cubit_test.dart
  - test/banxa/buy_order_toasts_test.dart
  - test/banxa/buy_page_layout_test.dart
  - test/banxa/checkout_platform_config_test.dart
  - test/banxa/checkout_qr_test.dart
  - test/banxa/checkout_rules_test.dart
  - test/banxa/checkout_screen_test.dart
  - test/banxa/fake_banxa_api.dart
  - test/banxa/fixtures.dart
  - test/banxa/no_banxa_secret_test.dart
  - test/banxa/order_drawer_footer_test.dart
  - test/banxa/order_status_style_test.dart
  - test/banxa/order_transaction_mapping_test.dart
  - test/banxa/orders_poller_test.dart
  - test/banxa/orders_wallet_scope_test.dart
  - test/components/drawer_padding_invariant_test.dart
  - test/components/gw_menu_item_test.dart
  - test/components/gw_text_field_prefix_test.dart
  - test/components/toast_test.dart
  - test/dashboard/buy_orders_filter_test.dart
  - test/dashboard/transaction_filter_rail_test.dart
  - test/dashboard/transaction_filters_test.dart
  - test/dashboard/transactions_page_frame_test.dart
  - test/dashboard/transactions_refresh_test.dart
  - tool/verify_additive_boundary.sh
findings:
  critical: 0
  warning: 13
  info: 11
  total: 24
status: issues_found
---

# Phase 39: Code Review Report

**Reviewed:** 2026-09-30
**Depth:** standard
**Files Reviewed:** 74 (24 deleted files out of scope; no remaining references found to them)
**Status:** issues_found

## Summary

The Banxa key handling holds up. The key is read in one file through `--dart-define`, sent only as a header to two fixed Banxa hosts, never interpolated into an exception or log, and absent from the working tree (a repo-wide search found no leftover literal; it still lives in git history, so rotation remains open). The CI masks both the plain and the base64 form. `check_brace_style.sh` and `check_raw_colors.sh` exit 0. Checkout URL, order id and address are not in `BuyGnusState`. The checkout host rule, return matcher, and camera/microphone grants are mostly tight, with the gaps listed below.

No blocker was proven. The 13 warnings are mostly correctness gaps in the order poller and order display, plus hardening gaps in the webview trust rules. The most important: WR-01 (every launch sends the wallet address to Banxa before any consent), WR-02 (no HTTP timeouts, so one hung request kills the poller), WR-03 (a stale list fetch can drop the order being checked out), WR-04/WR-05 (screens that tell the user to pay again, or show a declined order as incoming GNUS).

I could not run `flutter analyze` or `flutter test` (SDK not on PATH); findings come from reading the code and from running the repo's shell checks and a small Dart script for URL parsing.

## Warnings

### WR-01: Every launch sends the wallet address to Banxa, before any consent and even with no key

**File:** `lib/banxa/banxa_order/banxa_order_cubit.dart:35-38, 60-69, 119-139`, `lib/main.dart:409-414`, `lib/banxa/banxa_components/buy_order_toasts.dart:51`
**Issue:** `OrdersCubit` used to fetch only when an orders screen asked. It now fetches in its constructor and on every wallet switch. `BuyOrderToasts` sits in the `MaterialApp` builder and reads the cubit, so the lazy `BlocProvider` builds it at first frame. Result: every user with a selected wallet, including users who never open Buy, sends `gw-<address>` and their IP to `api.banxa.com` at each launch. That bypasses the "Before your first buy ... your details go to Banxa" disclaimer the Buy flow shows. `fetchOrders` also never checks `_api.isConfigured`, so a build without a key still makes the call, with an empty `x-api-key`, and ends in an error state.
**Fix:** Skip the network when `!_api.isConfigured`. Start the initial fetch only once the user has a Banxa relationship (for example the same `banxaDisclaimerAccepted` flag, or a locally stored "has created an order" flag). Keep `track()` working without it.
```dart
Future<void> fetchOrders() async {
  if (!_api.isConfigured || !_hasBuyHistory()) { return; }
  ...
}
```

### WR-02: No timeout on any Banxa request; one hang stops polling for good

**File:** `lib/banxa/banxa_api_services.dart:25, 54-240`, `lib/banxa/banxa_order/banxa_order_cubit.dart:204-221`, `lib/banxa/banxa_order/buy_gnus_cubit.dart:209`
**Issue:** `http.Client()` has no request timeout, and there is no `.timeout(` anywhere in `lib/banxa`. `_poll` sets `_polling = true` and awaits `getOrderById` in a loop; a stalled connection (common on a mobile network hand-off) leaves `_polling` true forever, so every later tick returns at the guard and the status never updates. The checkout screen depends on that poller for Done. The same hang leaves `creating` true and the Buy button spinning.
**Fix:** Bound every call once, in the service.
```dart
static const _timeout = Duration(seconds: 20);
final response = await _client.get(uri, headers: _headers).timeout(_timeout);
```
Apply it to `get` and `post` (a small private `_get`/`_post` wrapper keeps it to one place).

### WR-03: A list fetch that started before the order was created can erase the tracked order

**File:** `lib/banxa/banxa_order/banxa_order_cubit.dart:133-143, 223-241`
**Issue:** `fetchOrders` replaces `state.orders` wholesale with its response. `track()` merges a new order into state. If a fetch began before the order existed (startup fetch, pull-to-refresh, wallet switch; `fetchAllOrders` can take up to 20 pages) and finishes after `track()` merged, the new order disappears. `CheckoutScreen` then sees `order == null`, `_openIds()` no longer contains it, and nothing polls it until the next manual refresh, so Done never appears. The reverse also holds: `track()` captures `_fetchGeneration` at its start, so a fetch that starts while `track()` is in flight makes `_readOrder` discard the tracked result.
**Fix:** Keep locally tracked orders across a fetch: after a successful fetch, append any order that `track`/`_merge` added and that the response does not contain. Let `track()` ignore the generation check unless the customer key changed.

### WR-04: "Complete payment" is offered for orders that are already paid or unrecognised

**File:** `lib/banxa/checkout/checkout_screen.dart:216-218, 695, 712-720`
**Issue:** After the return link, `_returned && _readDone` shows `CheckoutResult` whatever the status. `unpaid = !isPaid && !isFinal` is then true for `waitingPayment` ("Confirming payment: your bank or card is confirming"), `unknown`, and `pendingPayment`. A user who has just paid and is waiting for the bank is shown "Complete payment", which reloads the checkout. Banxa often reports `waitingPayment` right after the redirect. The test only covers a plain unpaid order.
**Fix:** Offer the button only for the two statuses that need user action, and show a no-action confirming state for the rest.
```dart
final needsAction = status == BanxaOrderStatus.pendingPayment ||
    status == BanxaOrderStatus.extraVerification;
```

### WR-05: Declined, expired, cancelled and refunded orders are shown as incoming GNUS

**File:** `lib/banxa/banxa_helpers/order_transaction_mapping.dart:91, 115`, `lib/banxa/checkout/checkout_screen.dart:700, 747`
**Issue:** `sign = banxa.isFinal ? '+ ' : '+ ≈'`. `isFinal` includes declined, expired, cancelled and refunded, so those rows read `+ 0.0025 BTC` with no approximation mark, exactly like a delivered order. The value line says "Not charged", but the headline figure in a transaction list reads as a credit. `CheckoutResult` does the same: a declined order shows `+ ≈100 GNUS` above "Not charged". No test asserts the amount for these statuses.
**Fix:** Only `complete` gets `'+ '`; in-flight gets `'+ ≈'`; statuses that delivered nothing show the amount without a sign (or struck through) and in the neutral tone. In `CheckoutResult` hide the GNUS headline when `notCharged`.

### WR-06: A stale quote can be used to create an order

**File:** `lib/banxa/banxa_order/buy_gnus_cubit.dart:161-176, 187-228`, `lib/banxa/banxa_order/buy_gnus_state.dart:128-156`
**Issue:** `pause()` (app hidden, or checkout opened) cancels timers and bumps the generation but leaves `quote` set and `quoteStale` false. On `resume()` the old quote stays on screen, with an enabled "Buy GNUS", until the new response lands. The same holds while a refresh is in flight. `createOrder` ignores `quoting`, `quoteStale` and `quoteFetchedAt`, and posts `quote.cryptoAmount` from a quote that can be minutes or hours old. After returning from checkout this is the normal path.
**Fix:** Mark the quote stale on `pause()` (`emit(state.copyWith(quoteStale: true))`) and have `createOrder`/`ctaFor` refuse when `quoting || quoteStale`, or when `quoteFetchedAt` is older than `quoteInterval * 2`.

### WR-07: Some wallets get a disabled Buy button with no reason

**File:** `lib/banxa/banxa_order/buy_gnus_state.dart:132-135`, `lib/screens/banxa_buy_screen.dart:1016-1024`
**Issue:** `ctaFor` disables Buy for tracking wallets and for any address failing `isEvmAddress`. `_ToRow` explains only the tracking case. `WalletType` also has `sgnus`; if such a wallet's address is not a valid EVM address (or fails the EIP-55 check) the user sees a dead "Buy GNUS" and no text. D-04 asks for a one-line reason.
**Fix:** Show a reason for the invalid-address case too (for example "GNUS can only be delivered to an Ethereum-style address. Switch wallet.") and keep the copy in `BuyGnusState` next to `watchOnlyReason`.

### WR-08: The payment row always says "Paid by card"

**File:** `lib/screens/banxa_buy_screen.dart:1041-1053`, `lib/banxa/banxa_helpers/order_transaction_mapping.dart:103`
**Issue:** When a currency has one payment method the row prints the literal "Paid by card" with a card icon, whatever `state.method` is (it could be a bank transfer, PIX, and so on). The order row subtitle also hard-codes "Card purchase". Wrong payment information in a purchase flow.
**Fix:** Print `state.method?.name` (and pick the icon from it), and use `order.paymentMethodName` in the row subtitle with "Card purchase" only as the fallback.

### WR-09: A failed orders fetch reads as "No buy orders yet"

**File:** `lib/dashboard/home/widgets/transactions_slim_view.dart:636-643`, `lib/dashboard/transactions/view/transactions_stream.dart:28-33`
**Issue:** The Buy orders empty state is chosen from `txs.isEmpty` alone. The orders state (loading, error, unconfigured key) is not passed to the view, so a user who has bought GNUS but whose fetch failed sees "No buy orders yet ... Buy GNUS" and may buy again.
**Fix:** Pass `OrdersState.status` into `TransactionsSlimView`; while `loading`/`initial` show a loading row, on `error` show "Couldn't load your buy orders" with a retry that calls `fetchOrders()`.

### WR-10: `isTrustedCheckoutUrl` accepts a percent-escaped host

**File:** `lib/banxa/checkout/checkout_rules.dart:11-17`
**Issue:** Dart's `Uri` keeps escapes in the host. Verified by running it: `https://evil.io%2F.banxa.com/` parses to host `evil.io%2f.banxa.com` and passes the `.banxa.com` suffix test. WebViews (WHATWG host parsing) reject it today because `/` is a forbidden host character, so this is not exploitable now, but the gate that decides what loads and who gets the camera should not depend on two parsers disagreeing. `checkout_rules_test.dart` has no case for it.
**Fix:**
```dart
final host = uri.host;
if (host.contains('%') || host.isEmpty) { return false; }
```
Add `https://evil.io%2F.banxa.com` and a tab-embedded host to the rejected list in the test.

### WR-11: Plain `http` is allowed for main-frame navigation inside the payment and ID webview

**File:** `lib/banxa/checkout/checkout_rules.dart:33-38`, `lib/banxa/checkout/checkout_webview.dart:65-71`, `ios/Runner/Info.plist:58-59`
**Issue:** `allowsCheckoutNavigation` accepts `http`. iOS ships with `NSAllowsArbitraryLoads` true, so a redirect off a Banxa page to an `http` URL loads in the same JavaScript-enabled view that hosts card entry and ID capture, and is open to injection on a hostile network. No 3-D Secure or ID vendor needs cleartext. The test suite asserts `http://example.com` is allowed.
**Fix:** Allow `https` and `about` only (`const {'https', 'about'}`); update `checkout_rules_test.dart`.

### WR-12: Uploaded ID documents stay in the app cache

**File:** `lib/banxa/checkout/checkout_webview.dart:116-132`
**Issue:** `FilePicker.pickFiles` copies the chosen file into the app cache on Android/iOS and returns that path. Passport or licence photos therefore remain on disk until the OS clears the cache. Nothing calls `FilePicker.clearTemporaryFiles()`.
**Fix:** Clear after the webview is done with the files (on `dispose` and on return/final status): `unawaited(FilePicker.clearTemporaryFiles())`. Consider a short delay or calling it on dispose only, since the page reads the file after the picker returns.

### WR-13: One malformed order breaks the whole list, and `metadata` has a type mismatch

**File:** `lib/banxa/banxa_model.dart:279-302`, `lib/banxa/banxa_order/buy_gnus_cubit.dart:218`
**Issue:** `Order.fromJson` assigns straight from `dynamic` to non-nullable `String` fields and to `Map<String, dynamic>? metadata`. Any null or unexpected type throws a `TypeError` inside `fetchAllOrders`, so one bad order sinks the entire list and puts the store in the error state; in `_readOrder` the same throw is swallowed and retried every 15 s forever. The app sends `metadata: 'real'` (a String, `buy_gnus_cubit.dart:218`) while the model expects a Map; if Banxa echoes it back as sent, every order this app creates fails to parse. No sandbox key exists yet (D-09), so this path has never met a real response.
**Fix:** Parse defensively: `metadata: json['metadata'] is Map<String, dynamic> ? json['metadata'] : null`, default missing strings to `''`, and in `OrdersResponse.fromJson` skip (and count) orders that fail to parse instead of throwing. Confirm the `metadata` shape against a sandbox response before shipping.

## Info

### IN-01: Comments break the project comment rules

**File:** `lib/banxa/banxa_api_services.dart:153-170`, `lib/banxa/banxa_order/banxa_order_cubit.dart:15-24, 82-91`, `lib/banxa/banxa_helpers/order_transaction_mapping.dart:9-22, 127-169`
**Issue:** AGENTS.md caps doc comments at 3 lines and forbids history and planning ids. The `fetchAllOrders` doc (added this phase) is 17 lines and narrates that the id "used to default to 'your-cust-id'". The older blocks cite "Phase 9", "D-01", "D-03" and "quick task 260731-ope".
**Fix:** Cut each to the constraint only, for example: `/// Reads every page of orders; stops at [maxPages] or when Banxa repeats a page.`

### IN-02: `verify_additive_boundary.sh` edit is partial

**File:** `tool/verify_additive_boundary.sh:143-150`
**Issue:** The edit removes the four deleted importers but does not add the three new `components/loading.dart` importers (`checkout_screen.dart`, `checkout_webview.dart`, `checkout_webview_windows.dart`). Check 1 [Loading] fails both before and after this phase (the step is `continue-on-error`), so nothing new goes red, but the edit leaves the list wrong and the step's "2 false positives" label now understates the failures.
**Fix:** Either regenerate the list from the script's "actual" output or leave the file alone.

### IN-03: Manifest feature flags and stale dependency floor

**File:** `android/app/src/main/AndroidManifest.xml:51-53`, `pubspec.yaml:39`
**Issue:** `CAMERA` and `RECORD_AUDIO` imply required camera autofocus and microphone features for Play Store filtering; only `android.hardware.camera` is marked optional. `webview_flutter: ^4.1.0` is below the release that has `onPermissionRequest`; the lock file resolves 4.14.0 but a constraint-minimum resolve would break.
**Fix:** Add `uses-feature` entries for `android.hardware.camera.autofocus` and `android.hardware.microphone` with `required="false"`; raise the constraint to `^4.14.0`.

### IN-04: `subPartnerId` says macOS on every platform

**File:** `lib/banxa/banxa_order/buy_gnus_cubit.dart:218-219`
**Issue:** Hard-coded `'macOS-app'` (and `metadata: 'real'`) carried over from the old cubit; Windows, Android and iOS orders are all attributed to macOS in Banxa's dashboard.
**Fix:** Derive from `Platform.operatingSystem`, or drop the field.

### IN-05: `fetchOrders` ignores the injected clock and misnames its window

**File:** `lib/banxa/banxa_order/banxa_order_cubit.dart:129-130`
**Issue:** `DateTime.now().toUtc()` is used although `_now` was added for testability, and the variable `oneMonthAgo` is 120 days.
**Fix:** Use `_now().toUtc()` and rename to `windowStart` with a named constant.

### IN-06: Small robustness gaps around `launchUrl` and the order id path

**File:** `lib/banxa/banxa_components/order_drawer_footer.dart:93-94`, `lib/banxa/banxa_api_services.dart:235`
**Issue:** The support button returns the un-awaited `launchUrl` future, so a missing browser throws an uncaught async error (the checkout screen wraps the same call in `_openInBrowser`). `getOrderById` interpolates `orderId` into the path without encoding.
**Fix:** Reuse a shared guarded opener; use `Uri.encodeComponent(orderId)`.

### IN-07: "Secured by Banxa" and the lock icon are static

**File:** `lib/banxa/checkout/checkout_screen.dart:386-397`
**Issue:** The header claims the page is secured by Banxa for the whole session, but 3-D Secure and ID steps legitimately navigate to other https hosts, and an open redirect would keep the same header over a look-alike page. There is no URL bar.
**Fix:** Show the current host (from `onPageStarted`/`url`) next to the lock and drop the claim when it is not a Banxa host.

### IN-08: Finish toasts for other orders are dropped while checkout is open

**File:** `lib/banxa/banxa_components/buy_order_toasts.dart:69-71`
**Issue:** `_onCheckout` drops the toast for every order, but `justFinished` is one-shot. An older order that finishes while the user is in a new checkout is never announced.
**Fix:** Only skip orders whose id matches the open checkout.

### IN-09: The `geniuswallet://` return scheme is registered on Android and macOS only

**File:** `ios/Runner/Info.plist`, `lib/banxa/checkout/checkout_webview_windows.dart:53-68`
**Issue:** iOS, Windows and Linux register no handler. iOS and Android work because the webview intercepts the link; on Windows WebView2 cannot veto it, and a load error can arrive before the `url` event, which would show "Checkout didn't load" after a successful payment. The poller recovers the status, so this is cosmetic, but it was not exercised (no sandbox key).
**Fix:** Check `_returned` before honouring `onLoadError` on Windows, or ignore load errors whose URL is the return URI.

### IN-10: Layering and lifecycle loose ends

**File:** `lib/banxa/banxa_order/buy_gnus_cubit.dart:35-40`, `lib/main.dart:392-394`
**Issue:** `BuyGnusCubit` defaults reach into `Hive.box(...)` directly instead of a repository (AGENTS.md layering). `BanxaApiService`'s `http.Client` is never closed by the `RepositoryProvider`.
**Fix:** Move the disclaimer flag behind the preferences repository; pass `dispose: (s) => s.close()` and add a `close()` that closes the client.

### IN-11: Open orders with an unrecognised status poll for ever

**File:** `lib/banxa/banxa_order/banxa_order_cubit.dart:161-183`
**Issue:** `unknown` is non-final by design, so an order whose wire status the app does not know is read every 15 s for as long as it is inside the 120-day list window, with no back-off. Many stuck orders mean many sequential requests per tick.
**Fix:** Stop polling an order after a cap (for example 24 h since `updatedAt`) or back off per order.

---

_Reviewed: 2026-09-30T17:35:00Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
