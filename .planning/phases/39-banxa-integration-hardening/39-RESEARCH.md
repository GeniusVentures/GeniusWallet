# Phase 39: Banxa integration hardening - Research

**Researched:** 2026-09-30
**Domain:** Banxa v2 REST integration inside a Flutter multi-platform wallet (secrets, sandbox switching, embedded checkout, order tracking, Transactions integration)
**Confidence:** MEDIUM. Code facts and Banxa docs facts are HIGH. Three items cannot be settled from a desk: what Banxa appends to `redirectUrl`, whether Banxa accepts a custom-scheme `redirectUrl`, and whether GNUS exists in the sandbox coin list. Each is a Wave 0 spike (see Open Questions).

## User Constraints

No `39-CONTEXT.md` exists. The locked inputs are the ROADMAP Phase 39 entry and the three picked sketches. Copied from them, not from a discuss session.

### Locked Decisions
- Buying GNUS feels like one step. The Buy page is rebuilt around GNUS only; receiving address prefilled from the Selected wallet; one "you get X GNUS" figure with fees underneath; checkout that brings the user back to a tracked order.
- No Banxa credential ships in the app or reaches a log. KYC runs inside Banxa's checkout. Finished orders read as finished. A sandbox build can complete a whole buy.
- Design picked 2026-09-30: sketch 080 A (compact card), 081 B (full-screen in-app checkout), 082 C (orders in Transactions behind a Buy orders filter).
- Also required: an easy way into Buy GNUS from the main surfaces, and a link from Buy GNUS to Transactions with the Buy orders filter already selected.
- Fiat defaults from locale with a small change link (sketch 080).
- 082 C: promote the existing `Filters.purchase` to the title row. Do not add a new enum value.

### Claude's Discretion
Everything not listed above: proxy shape, sandbox switch mechanism, webview package per platform, poller placement, status enum design, requirement ids, plan/wave breakdown.

### Deferred Ideas (OUT OF SCOPE)
- Multi-provider aggregator (MetaMask-style tags, Phantom price sort). UX research item 8: "No aggregator now."
- Banxa listing GNUS is a Banxa-side action, not app work. The plan must be buildable and testable against a fake API without it.

<phase_requirements>
## Phase Requirements

No ids assigned in ROADMAP (`Requirements: TBD`). Proposed for REQUIREMENTS.md under a new `### Buy GNUS (BUY)` group in the v3.0 section:

| ID | Description | Research Support |
|----|-------------|------------------|
| BUY-01 | Buy page is a compact GNUS-only card: amount, fiat pill defaulting from locale, payment-method row only when the fiat has more than one method, "You get ~X GNUS" with fee rows underneath, quote refreshes on its own (no "Get quote" step) | Standard Stack, Pattern 2, Pitfalls 6, 7 |
| BUY-02 | Receiving address is the Selected wallet's address read at tap time, shown as a "To" row with Change; no free-text address field | Q5, Pattern 5 |
| BUY-03 | No Banxa credential in the binary, source tip, or any log/breadcrumb; existing key rotated | Q1, Security Domain |
| BUY-04 | A build-time switch selects sandbox vs production endpoint, a visible marker shows sandbox, and a sandbox build completes a whole buy | Q2 |
| BUY-05 | Checkout opens full-screen in the app (Android, iOS, macOS, Windows); Linux uses the system browser; KYC happens inside checkout; the separate "Verify with Banxa" button and `/kyc` route are gone | Q3 |
| BUY-06 | The return trip lands on a tracked order: one callback constant, status-driven Done, return-URL interception as an accelerator | Q3, Pitfall 3 |
| BUY-07 | One app-level poller tracks every non-final order of the Selected wallet, stops on the real final set, and follows wallet switches | Q4, Pattern 3 |
| BUY-08 | One status enum covers all 11 Banxa statuses; `complete` reads as finished, `paymentReceived` does not; labels and tones follow the sketch 082 table | Q4, Pattern 4 |
| BUY-09 | Buy orders appear in Transactions with a "Buy orders" filter chip (count of open orders), order id copyable, support link on failed/expired/refunded | Q4, Pattern 6 |
| BUY-10 | A final status raises a result surface (success or cancelled drawer wired to a real order) | Q4 |
| BUY-11 | Buy GNUS is reachable from Home, Assets, the GNUS coin page and the Transactions empty state; Buy page links to `/transactions?filter=purchase` | Q4, Pattern 6 |
| BUY-12 | Dead Banxa code removed (`submitKYC`, `generateHmacSignature`, `banxaKycUrl`, header/body printing, sandbox KYC screen) and the Banxa tests rewritten to match | Q6 |
</phase_requirements>

## Summary

The only option that meets the phase goal and keeps the key out of the app is a small team-hosted proxy in front of Banxa's v2 API. Banxa documents that every v2 endpoint needs `x-api-key`, including quotes, payment methods and currency lists, and the docs mention no read-only or scoped key. The referral-URL flow needs no key but Banxa's own comparison table says it has no in-app quote, no order history lookup and no webhooks, so it cannot deliver the "you get X GNUS" figure or tracked orders. Keeping "read-only" calls in the app therefore still ships the key. This is a one-way, costly decision and needs the user's sign-off before planning.

Everything else in the phase is app work that is testable against a fake `BanxaApiService`, because Dart lets a test class `implements BanxaApiService` without any new abstraction. The two biggest code findings: (1) `webview_flutter` has no Windows or Linux implementation, so `BanxaPaymentWebView` would assert on Windows today (only Linux is guarded); a Windows checkout must use `webview_windows`, the way `lib/web/web_view_screen.dart` already splits; (2) Banxa orders never enter the Transactions list today, they render only in the Buy page's private `_OrdersRail`, so the Buy orders filter needs an orders source wired into `TransactionsSlimView`, plus an app-level poller that follows the Selected wallet.

The Windows and Linux desktop builds have no deep-link path at all (no scheme registration, Windows ships as a zip, Linux uses `G_APPLICATION_NON_UNIQUE`, and a second Windows instance hits the Hive lock and shows `AlreadyRunningApp`). Design the return trip so that polling the order status is the source of truth and URL interception is only an accelerator.

**Primary recommendation:** Build against an injectable `BanxaApiService(baseUrl, ...)` with no key; stand up a stateless allowlist proxy (sandbox and production deployments) as the production path; make order status polling the source of truth for "Done"; treat the WebView return-URL match as a shortcut.

## Project Constraints (from CLAUDE.md / AGENTS.md)

- Brace every `if`, body on its own line (`tool/check_brace_style.sh` enforces; CRLF files break it in CI).
- Widgets, never `_buildFoo()` helper methods returning Widget. Rule of Three for extraction.
- Colours from `Theme.of(context).extension<GWColors>()`; no `Colors.*` or `Color(0x...)` outside `lib/theme/`; correct in both appearance modes and WCAG AA. `test/banxa/banxa_reskin_literals_test.dart` enforces per-file.
- Widgets do not reach past the repository layer: no `http`, `Hive.box`, SDK calls in a widget or its State. Today `OrderDetailsPage` (`order_details_page.dart:36`) and `router.dart:168` build `BanxaApiService()` in the view layer; new code must not.
- No secrets: never log or send to Sentry anything derived from keys. `tool/check_no_new_key_logging.sh --scan-tree` runs in CI (`build.yml:1461`); it flags any print-family call in the files given.
- Comments: WHY only, max 3 lines of doc comment, never cite plan/phase/sketch numbers or test files in source.
- Files under repo-root `banxa/` and `squidrouter/` are generated; do not edit. `lib/banxa/` is hand-written. (Repo-root `banxa/` is not imported anywhere: `grep package:banxa` finds nothing.)
- `dart format`, `flutter analyze` (exits non-zero on infos), `flutter test` before done. Flutter is not on PATH.
- PLAN.md <= 150 lines, SUMMARY.md <= 40.
- Only the executor session commits, runs the full suite, edits `lib/` `test/` `macos/` `packages/`. This research session changed nothing outside `.planning/phases/39-.../`.
- Parallel-agent rule: code-committing executors stay sequential (one git index). Every plan below touches `lib/banxa/`, so waves are sequential.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Banxa credential custody | Team proxy (API/Backend) | - | The only place a key can live without shipping in the binary |
| Quote, create order, order lookup | Team proxy | App `BanxaApiService` (thin client) | Proxy adds the key and pins partner, redirect URL and address validation |
| Sandbox vs production selection | Build (compile-time define) | Proxy deployment | App holds a URL only; each proxy deployment holds its own Banxa key |
| Quote refresh timer, form state | Cubit (`MakeOrderCubit`) | Widget (renders state) | Timer and validation are business logic, not widget code |
| Receiving address | `WalletDetailsCubit.selectedWallet` | Read at submit time in `MakeOrderCubit` | Address must follow the switcher and never be stale text |
| Order polling and wallet scoping | App-level cubit (`OrdersCubit`, provided in `main.dart`) | `BanxaApiService` | Must outlive the Buy page and follow the Selected wallet |
| Order rows in Transactions | `TransactionsStream` (view wiring) | Pure mapping in `lib/banxa/banxa_helpers/order_transaction_mapping.dart` | Mapping is Banxa knowledge; the list stays ignorant of orders |
| Embedded checkout | Client webview host per platform | System browser (Linux, "pay on another device") | Platform capability differs; see Q3 |
| Return detection | Polling (source of truth) | Webview URL match (accelerator) | Desktop has no deep-link path |
| KYC | Banxa hosted checkout | - | Runs inside the checkout webview; the app owns nothing |
| Final-status notification | App-level listener on `OrdersCubit` | Toast + result drawer | Must fire from any page |

## Standard Stack

No new external packages are needed. Everything below is already in `pubspec.yaml` / `pubspec.lock`.

### Core
| Library | Version (lock) | Purpose | Why Standard |
|---------|---------------|---------|--------------|
| http | 1.6.0 | Banxa REST client | Already used; `BanxaApiService` takes an injectable `http.Client` in the refactor |
| flutter_bloc | 9.1.1 | Cubits (`MakeOrderCubit`, `OrdersCubit`) | Project standard |
| go_router | 17.3.0 | `/buy`, `/transactions?filter=`, `/checkout` | Project standard |
| webview_flutter | 4.14.0 (android 4.12.0, wkwebview 3.25.1) | Checkout on Android, iOS, macOS | Pubspec platforms are android, ios, macos only [VERIFIED: webview_flutter-4.14.0/pubspec.yaml, `flutter: plugin: platforms:` lists android, ios, macos] |
| webview_windows | 0.4.0 | Checkout on Windows (WebView2) | Already used by `lib/web/web_view_windows.dart`; registers with `WindowsWebViewShutdown` |
| url_launcher | 6.3.2 | System browser (Linux, pay on another device); Custom Tabs on Android via `LaunchMode.inAppBrowserView` | url_launcher_android maps `inAppBrowserView` to Custom Tabs [VERIFIED: url_launcher_android-6.3.30/lib/url_launcher_android.dart:140-141 `return _hostApi.supportsCustomTabs();`] |
| app_links | 7.0.0 | Existing `DeepLinkService` | Keep; do not extend to desktop (Q3) |
| qr_flutter (existing `checkout_qr.dart`) | existing | "Pay on another device" | Already built |

### Supporting
| Library | Purpose | When to Use |
|---------|---------|-------------|
| sentry_flutter 9.22.0 | Existing crash reporting | Configure `beforeBreadcrumb` scrub if any Banxa URL could be printed (Pitfall 9) |
| mockito ^5 (dev) | Available | Not needed; hand-written `implements` fakes match the existing tests |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Team proxy | Banxa referral URL (no key) | No in-app quote, no order lookup, no webhooks per Banxa's own table. Cannot meet BUY-01/07/09 |
| Team proxy | Key via `--dart-define` | Still extractable from the binary. Acceptable only as a `kDebugMode` sandbox-only dev convenience |
| `LaunchMode.inAppBrowserView` | `flutter_custom_tabs` package | New dependency for what url_launcher already does; slopsquat surface; skip |
| `webview_flutter` on Windows | `desktop_webview_window`, `flutter_inappwebview` | Not in pubspec; `webview_windows` is already the app's Windows answer |

**Installation:** none.

**Version verification:** versions above read from `pubspec.lock` this session (webview_flutter "4.14.0", webview_flutter_android "4.12.0", webview_flutter_wkwebview "3.25.1", webview_windows "0.4.0", app_links "7.0.0", url_launcher "6.3.2", http "1.6.0", go_router "17.3.0", flutter_bloc "9.1.1", sentry_flutter "9.22.0"). Sources present in the local pub cache and read directly.

## Package Legitimacy Audit

No new external packages are recommended, so there is nothing to install and no `slopcheck`/`package-legitimacy` run is required.

| Package | Registry | Age | Downloads | Source Repo | Verdict | Disposition |
|---------|----------|-----|-----------|-------------|---------|-------------|
| (none new) | - | - | - | - | - | - |

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none
Explicitly rejected without evaluation: `flutter_custom_tabs`, `flutter_inappwebview`, `desktop_webview_window`, `win32_registry`. Each would only be considered if a spike proves the existing stack cannot do the job, and then it needs a `checkpoint:human-verify` install task.

## Architecture Patterns

### System Architecture Diagram

```
                         BUILD TIME
   --dart-define=GW_BANXA_ENV=sandbox|production  (const, default production)
                              |
                              v
  +-------------------+   HTTPS, no key    +----------------------------+     x-api-key      +--------------+
  |  Flutter app      | -----------------> |  Team proxy (per env)      | -----------------> |  Banxa v2    |
  |  BanxaApiService  | <----------------- |  allowlist 5 routes,       | <----------------- |  sandbox or  |
  |  (baseUrl only)   |   JSON             |  pins partner + redirect,  |                    |  production  |
  +---------+---------+                    |  validates address,        |                    +--------------+
            ^                              |  caches order GET ~5-10 s  |
            |                              +----------------------------+
   +--------+-----------------------------------------------------------+
   |                                                                    |
   |  MakeOrderCubit (Buy page)             OrdersCubit (app level)     |
   |   - amount, fiat, method                - list for Selected wallet |
   |   - 10 s quote timer (foreground)       - poll open orders only    |
   |   - createOrder(address = selected      - follows WalletDetails    |
   |     wallet read at tap)                   selectedWallet           |
   |            |                            - emits "justFinished"     |
   |            v                                      |                |
   |   checkoutUrl + orderId                           v                |
   |            |                        BlocListener (router builder): |
   |            v                        toast + result drawer          |
   |   Checkout host (per platform)                    ^                |
   |    Android/iOS/macOS: webview_flutter             |                |
   |    Windows: webview_windows                       |                |
   |    Linux: system browser + "I've paid"            |                |
   |    Done = status >= paymentReceived OR return URL |                |
   +--------------------------+-------------------------+---------------+
                              |
                              v
   /transactions?filter=purchase  -->  TransactionsStream
        (TransactionsCubit txs) + (OrdersCubit orders -> orderAsTransaction + orderRowContent)
                              -->  TransactionsSlimView (Filters.purchase promoted to title row)
```

### Recommended Project Structure
```
lib/banxa/
  banxa_api_services.dart          # instance-only client; baseUrl + optional http.Client; no key, no print
  banxa_env.dart                   # const env select (new, ~15 lines)
  banxa_order/
    banxa_order_status.dart        # one enum: wire string <-> label <-> tone <-> isFinal (new)
    create_order_cubit.dart        # quote timer, address read at tap, checkout hand-off
    banxa_order_cubit.dart         # OrdersCubit: fetch + poll + wallet scoping
  banxa_helpers/
    order_transaction_mapping.dart # keep; statuses come from the enum
  checkout/                        # new: host widget + per-platform impl (webview, windows, external)
lib/screens/banxa_buy_screen.dart  # rebuilt compact card (sketch 080 A)
```
Delete: `lib/banxa/user_kyc/`, `lib/banxa/banxa_orders_history.dart` (+ `/buy/orders`), `banxa_helpers/deep_link_service.dart` only if callback route is dropped (recommend keep, see Pitfall 3), `order_service.dart` (`OrderLinker` becomes unnecessary once the order id is known before checkout).

### Pattern 1: One env switch, injected in tests
**What:** A `const` from `String.fromEnvironment`, exactly like `kShowDevTools`, plus constructor injection so tests never depend on a define.
**When to use:** Base URL selection, the sandbox marker, dev-only direct-key mode.
**Example:**
```dart
// Source: existing lib/dev/dev_flags.dart pattern
// [VERIFIED: lib/dev/dev_flags.dart] const bool kShowDevTools = bool.fromEnvironment('GW_DEV_TOOLS');
const String kBanxaEnv = String.fromEnvironment('GW_BANXA_ENV', defaultValue: 'production');
const String kBanxaProxyUrl = String.fromEnvironment('GW_BANXA_PROXY_URL');
bool get isBanxaSandbox => kBanxaEnv == 'sandbox';

class BanxaApiService {
  BanxaApiService({String? baseUrl, http.Client? client})
    : _base = baseUrl ?? kBanxaProxyUrl,
      _client = client ?? http.Client();
}
```
The `child_operations_cubit.dart:127` constructor takes `bool devTools = kShowDevTools` for the same reason (tests cannot pass a define) [VERIFIED: grep hit `lib/child_wallets/child_operations_cubit.dart:127`].

### Pattern 2: Quote timer lives in the cubit, pauses when it should
`MakeOrderCubit` owns a 10 s `Timer`. It runs only while the amount is valid and the app is foreground, restarts on any input change, and each fetch replaces (never caches) the quote, per Banxa: "Always call GET /v2/quotes immediately before presenting a price ... Do not cache quote responses" [CITED: docs.banxa.com/products/hosted-checkout/docs/getting-started/integration-best-practices]. Dim the numbers during refresh instead of blanking (sketch 080).

### Pattern 3: One poller in `OrdersCubit`
`OrdersCubit` is already provided at app level after `WalletDetailsCubit` (`main.dart:410-414`) and already derives the customer id from the selected wallet (`banxa_order_cubit.dart:29-30`). Extend it, do not add a second cubit:
- Subscribe to `WalletDetailsCubit` for `selectedWallet` changes; clear and refetch on change. Copy `TransactionsCubit`'s `_loadGeneration` guard (`transactions_cubit.dart`, "Bumped by every load; only the newest load's read may land") so wallet A's late response cannot land under wallet B. Today nothing refetches on a switch.
- After each list fetch, poll `GET /orders/{id}` for non-final orders only. Stop the timer when none remain. Pause on `AppLifecycleState.paused` (an observer already exists at `main.dart:277`, `_AppLifecycleHandlerState`).
- Diff old vs new status; when an order becomes final, put it in a `justFinished` field the listener consumes once.
Layering: the cubit talks to an injected `BanxaApiService`; widgets read only the cubit. That satisfies "widgets do not reach past the repository layer" without inventing a repository class. Fix `banxa_order_cubit.dart:89` (`BanxaApiService()`) to use the injected instance.

### Pattern 4: One status enum
Replace the 10 files that compare raw strings (census: `banxa_api_services.dart:222-227`, `order_card.dart:94,101`, `order_status_style.dart:20-29,124,127`, `banxa_helpers.dart:17-60`, `polling_order_cubit.dart:33-35`, `checkout_qr.dart:41,57-58`, `dev_banxa_fixtures.dart:116,128,138`, `banxa_buy_screen.dart:1419,1448`, `order_details_page.dart:70,83`) with one enum parsed once at the model boundary. Wire strings, verbatim from Banxa [CITED: docs.banxa.com/products/hosted-checkout/docs/transaction-lifecycle/order-statuses]:
`pendingPayment`, `waitingPayment`, `paymentReceived`, `inProgress`, `cryptoTransferred`, `complete`, `cancelled`, `declined`, `expired`, `refunded`, `extraVerification`. The task brief also names `coinTransferred`; the docs page does not list it. Accept both and map to the same value; an unknown string parses to `unknown` (neutral tone, non-final, still polled) rather than throwing. Final set: `complete`, `declined`, `expired`, `cancelled`, `refunded`. Banxa notes an expired order can reactivate if payment lands late, so keep polling `expired` orders for a bounded window (planner decision, Open Decision 6).

### Pattern 5: Address read at tap time
`MakeOrderState` currently stores `walletText` (`create_order_state.dart:24`) and `canCreateOrder` requires it (`:155-158`). Remove `walletText` and the "Wallet address" field. `createOrder` receives the address from the caller, which reads `context.read<WalletDetailsCubit>().state.selectedWallet` (a `Wallet`: `required WalletType walletType`, `required String address`) at the moment of the tap. The "To" row watches the cubit for display only. `router.dart:351-360` already snapshots `selectedWallet?.address` into the route builder; that snapshot goes stale when the user switches wallets without leaving the page.

### Pattern 6: Orders in Transactions, filter by query parameter
- `TransactionsSlimView` takes `List<Transaction>` and `Filters.matches(Transaction)`. `orderAsTransaction(order)` already returns a `Transaction` with `type: TransactionType.purchase` (`order_transaction_mapping.dart:185-199`), so the existing filter works if the order-derived transactions are in the list.
- The row and drawer need the order too (`TransactionRow(tx:, contentOverride:)`, `showTransactionDetails(..., extraTransactionRows:, extraNetworkRows:, footer:)`, as `_OrderRows` uses at `banxa_buy_screen.dart:1390-1400`). `Transaction` has no `operator ==` (plain class, `packages/genius_api/lib/models/transaction.dart:99`), so an identity-keyed `Map<Transaction, Order>` built once per orders emission works. Build it in `TransactionsStream` (wrap in a second `BlocBuilder<OrdersCubit>`); do not rebuild `Transaction` instances per frame.
- `SgnusTransactionsScreen` (used when `selectedWallet.walletType == WalletType.sgnus`, `transactions_screen.dart:30-31`) scopes with `isShowOnlySGNUSTransactions` which filters `tx.isSGNUS ?? false`, so order-derived transactions (isSGNUS null) would vanish for an SGNUS Selected wallet. Decide explicitly.
- Filter preselect: `TransactionsSlimView._TransactionsSlimViewState` holds `Filters selectedFilter = Filters.all;` (`transactions_slim_view.dart:207`). Add `initialFilter`, thread it `TransactionsScreen -> TransactionsStream/SgnusTransactionsScreen -> TransactionsSlimView`, and set it from the route: `GoRoute(path: '/transactions', builder: (_, _) => const TransactionsScreen())` (`router.dart:250-253`) becomes `(_, state) => TransactionsScreen(initialFilter: Filters.values.asNameMap()[state.uri.queryParameters['filter']])`. Use a query parameter, not `extra`: it survives deep links and rebuilds. `currentIndex` uses `GoRouterState.of(context).uri.path`, so the nav highlight ignores the query [VERIFIED: nav_destinations.dart:108-109]. Handle `didUpdateWidget` so `context.go('/transactions?filter=purchase')` while already on Transactions still switches the chip (same route, different query; State is reused).
- Promote the chip: `Filters.primary = [sent, received, mint, jobs]` (`:118`) gains `purchase`; `overflowTypes = [escrow, swap, purchase]` (`:121`) loses it. Relabel `purchase('Purchased', ...)` (`:59`) to `Buy orders`. The label feeds `filteredEmptyTitle` ("No ${f.label.toLowerCase()} transactions", `:165-166`), which reads badly for "buy orders"; adjust the copy. `transaction_filters_test.dart` pins the bar width (183) and the rail's 7 type rows and the `_listCardFloor` literal 496 (`:267`); a fifth primary chip moves all three.

### Pattern 7: Checkout host per platform
One `CheckoutHost` widget with a small interface (`open(checkoutUrl)`, `onReturn`, `onClosed`) and three implementations chosen once:

| Platform | Host | Return detection | Notes |
|----------|------|------------------|-------|
| Android | `webview_flutter` (Android WebView) full-screen | `NavigationDelegate.onNavigationRequest` on the return URL, plus polling | Google Pay needs Custom Tabs (see Q3); camera/mic permission wiring required |
| iOS | `webview_flutter` (WKWebView) | same | Needs NSMicrophoneUsageDescription; iOS 15+ per Banxa |
| macOS | `webview_flutter` (WKWebView) | same | Needs microphone usage string and audio-input entitlement if liveness uses mic |
| Windows | `webview_windows` inside the shell, registered with `WindowsWebViewShutdown` | `controller.url` stream, plus polling | No request interception API; a custom scheme may trigger an OS protocol prompt |
| Linux | `url_launcher` external browser, waiting card | polling + "I've paid, check status" | Same as today's `_isLinux` branch (`banxa_payment.dart:39-44,130-188`) |

### Anti-Patterns to Avoid
- **`request.url.contains(redirectUrl)`** (`banxa_payment.dart:57`): substring match; compare scheme, host and path, and check `request.isMainFrame` (field exists on `NavigationRequest`).
- **Storing the wallet address as editable text in Cubit state** (`walletText`): stale after a switch; also one more place an address is echoed to state.
- **A second constant for the callback:** `create_order_cubit.dart:225` invents `yourapp://banxa-callback` while `banxa_api_services.dart:17` and `:146-151` send `geniuswallet://banxa/callback`. One constant, used everywhere.
- **`print` of headers/bodies** (`banxa_api_services.dart:337-349` prints `_headers`, which includes `x-api-key`, and the response body). Remove all prints in `lib/banxa/`.
- **Building `BanxaApiService()` in a view or route builder** (`router.dart:168`, `order_details_page.dart:36`).

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Custom Tabs on Android | A method channel or new package | `launchUrl(uri, mode: LaunchMode.inAppBrowserView)` | url_launcher_android already routes this to Custom Tabs |
| Windows deep link | Registry writing at runtime, IPC to first instance | Status polling + in-webview URL stream | Windows ships as a zip (`build.yml:1289-1291`), `windows/runner/main.cpp` has no single-instance forward, and a second instance dies on the Hive lock |
| Order-row rendering | A new order row widget | `TransactionRow(contentOverride:)` + `orderRowContent` + `showTransactionDetails` | Already built and tested (`order_transaction_mapping_test.dart`) |
| Toast with action | A parallel toast system | Extend `ToastManager` with one optional action (sketch 079: zero callers pass one today) | One toast language |
| Status colour ladder | New colours | `orderStatusPaint` / `txStatusColors` | Already AA-tested in both modes |
| HMAC / identity signing | Any client-side signing | Delete `generateHmacSignature` and `submitKYC` | They are dead code, use the API key as the HMAC secret (wrong per docs: identity HMAC uses a separate secret), and target a non-documented path |
| Quote caching | An in-app quote cache | Fetch fresh every 10 s | Banxa: do not cache quotes |
| Address validation | New regex | `isEvmAddress` (already used in `send_cubit.dart`, `recipient_field.dart`, `sdk_account_manager.dart`) | Existing, deliberately not a checksum test |

**Key insight:** the expensive mistakes here are platform ones (WebView availability, deep links, Google Pay) and custody ones (the key). Rendering and status-tone work is mostly reuse.

## Common Pitfalls

### Pitfall 1: Windows checkout crashes
**What goes wrong:** `BanxaPaymentWebView.initState` builds `WebViewController()` on every non-Linux platform (`banxa_payment.dart:46`). On Windows there is no `WebViewPlatform.instance`; the constructor asserts `WebViewPlatform.instance != null` [VERIFIED: webview_flutter_platform_interface-2.15.1/lib/src/platform_webview_controller.dart:27]. Nothing navigates to `/checkout` today, so it has never surfaced.
**How to avoid:** platform switch like `lib/web/web_view_screen.dart` (`Platform.isWindows ? WebViewWindows : WebViewMobile`). Register the Windows controller with `WindowsWebViewShutdown` (main.dart:245-254 disposes them before exit) or the window will hang on close.
**Warning signs:** an assertion on first "Buy" tap on Windows in debug.

### Pitfall 2: Google Pay in a plain Android WebView
**What goes wrong:** Banxa: "Standard WebView does not support GPAY or ACH" [CITED: docs.banxa.com/products/hosted-checkout/docs/checkout-experience/iframe/webview-mobile]. **Mitigating fact:** the verified `/v2/fiats/buy` list (29 fiats: card everywhere, extras only for EUR, AUD, CAD, CLP, ZAR, MXN) contains no Google Pay method. **Rule:** at runtime, if the selected fiat's `supportedPaymentMethods` contains a method whose name or id matches `google`/`apple` (case-insensitive), open Android in Custom Tabs (`inAppBrowserView`) and skip the "Leave checkout?" prompt. Apple/Google Pay are not testable in Banxa sandbox [CITED: docs.banxa.com/products/hosted-checkout/docs/testing/overview], so this branch needs a production walk.

### Pitfall 3: Callback handling mismatch and no desktop deep link
**What goes wrong:** two different constants (see Anti-Patterns). Custom scheme `geniuswallet` is registered on Android (`AndroidManifest.xml:25-33`, host `banxa`, path `/callback`) and macOS (`Info.plist` `CFBundleURLTypes`) only. iOS `Info.plist` has no `CFBundleURLTypes` [VERIFIED: grep "geniuswallet" finds only macos/Runner/Info.plist and android/app/src/main/AndroidManifest.xml]. Windows and Linux have none. app_links on Windows requires manual registry registration (its docs use `win32_registry`) and `SendAppLinkToInstance()` in `wWinMain`; on Linux it requires `G_APPLICATION_HANDLES_COMMAND_LINE | G_APPLICATION_HANDLES_OPEN` while `my_application.cc:115` sets `G_APPLICATION_NON_UNIQUE` [CITED: app_links README_windows / README_linux via Context7].
**How to avoid:** Done is status-driven (poll `paymentReceived` or later while the checkout is open). The in-webview return match is an accelerator. Keep the existing scheme registrations (harmless); do not add desktop registration in this phase.
**Unknown:** Banxa does not document what it appends to `redirectUrl`; the existing route reads `status`, `extOrderId`, `orderId` (`router.dart:128-131`) which is the original author's assumption. Never depend on those params.

### Pitfall 4: Proxy concentrates Banxa's per-IP rate limit
**What goes wrong:** Banxa production allows "500 requests per minute across all endpoints combined, per IP address"; sandbox "120 requests per minute per merchant account" [CITED: docs.banxa.com/products/hosted-checkout/docs/getting-started/authentication-and-environments]. Direct-from-app calls have one IP per user. Behind a proxy every user shares one egress IP. Arithmetic: at the current 5 s poll, one open order costs 12 req/min, so about 41 concurrent open orders exhaust the quota; each Buy page with a 10 s quote timer costs 6 req/min.
**How to avoid:** proxy-side response cache of 5-10 s for `GET /orders/{id}` (never for quotes), app poll 15 s with backoff to 60 s, quote timer paused when the app is backgrounded or the amount invalid. Webhooks (Banxa retries up to 18 times over 2 hours, HMAC-signed [CITED: docs.banxa.com/docs/webhooks]) are the scalable follow-up; out of this phase.

### Pitfall 5: Orders of wallet A shown under wallet B
`OrdersCubit` keys on `banxaCustomerId(selectedWallet.address)` (`gw-` + lower-cased address) but only refetches when a caller asks (`buy screen initState`, `OrdersPage`, dev bubble). After the v3 switcher work the Selected wallet changes at any time from the header. Wire the wallet subscription plus a generation guard (Pattern 3). Note SDK-account wallets that share a local wallet's address share the same customer id because the id is lower-cased address only, which is the desired behaviour.

### Pitfall 6: GNUS may be absent from Banxa's coin list
`/v2/crypto/buy` for partner `gnus` returns 120 coins and not GNUS (owned by Banxa). `loadCurrencies` currently selects the crypto by code and leaves `selectedCrypto` null when absent (`create_order_cubit.dart:44-46`), which silently disables the CTA. The GNUS-only page needs an explicit "not available yet" state (not in the sketches) so the failure is visible, and the fake API must be able to return a list with and without GNUS.

### Pitfall 7: Delivery chain differs from the wallet's viewed network
GNUS token exists in `assets/json/tokens` for Base (`0x614577036F0a024DBC1C88BA616b394DD65d105a`), Ethereum (same address, lower-cased), BNB (same address) and Polygon (`0x127E47abA094a9a87D084a3a93732909Ff031419`) [VERIFIED: assets/json/tokens/base.json:3-4, eth.json:3-4, bnb.json:3-4, poly.json:3-4]. Banxa decides which chain it lists; the app takes `CryptoCurrency.defaultBlockchain.id` (`banxa_model.dart:58-66`). If Banxa delivers on a chain other than the wallet's selected network, the balance appears to be 0. Show the delivery chain name in the order drawer (`orderNetworkRows` already renders `Chain` when non-blank) and consider a "switch network" affordance on completion. The sketch shows no network label on purpose.

### Pitfall 8: `externalCustomerId` is the order-list key
Banxa advises a stable internal id and not a wallet address [CITED: docs.banxa.com/products/hosted-checkout/docs/getting-started/integration-best-practices]. The app derives `gw-<lowercased address>` (`banxa_customer_id.dart:8-14`), it is the only key the order list can query by, and all existing orders are stored under it. Changing it orphans them. Recommendation: keep. It is a one-way choice, listed in Open Decisions.

### Pitfall 9: Secrets reach Sentry through print breadcrumbs
`SentryFlutter.init` in `main.dart:82-87` sets `sendDefaultPii = true` and `tracesSampleRate = 1.0`. `enablePrintBreadcrumbs` defaults to true [VERIFIED: sentry-9.22.0/lib/src/sentry_options.dart:332 `bool enablePrintBreadcrumbs = true;`; `run_zoned_guarded_integration` turns `print()` into breadcrumbs, and `DebugPrintIntegration` does the same for `debugPrint` outside debug mode]. So `banxa_api_services.dart:339` (`print('Headers: $_headers')`) puts `x-api-key` into any later error event's breadcrumbs on a release build. Also treat `checkoutUrl` as sensitive (it identifies a live order): do not print it either.

### Pitfall 10: Camera/microphone for the ID liveness step
Banxa requires local storage, camera and inline media in mobile WebViews [CITED: integration-best-practices]. Current state: `AndroidManifest.xml` declares no CAMERA or RECORD_AUDIO (it has INTERNET, network/wifi state, location, storage, foreground service); `ios/Runner/Info.plist` has `NSCameraUsageDescription` ("GeniusWallet uses the camera to scan a recipient's QR code." on macOS; iOS text differs) and no `NSMicrophoneUsageDescription`; macOS entitlements have `device.camera`, no `device.audio-input`. Android WebView DOM storage is already enabled by the plugin (`android_webview_controller.dart:156 _webView.settings.setDomStorageEnabled(true);`). Permission grant goes through the controller constructor `WebViewController(onPermissionRequest: (request) => request.grant())` [VERIFIED: webview_flutter-4.14.0/lib/src/webview_controller.dart:108-115; `grant()`/`deny()` at :462-468]. Grant only camera/microphone types, and only for the checkout host. `webview_windows` exposes `Webview(controller, permissionRequested: ...)` [CITED: Context7 /jnschulze/flutter-webview-windows]. Whether the `gnus` partner's KYC needs liveness at all is unknown; sandbox KYC uses a fixed PIN.

### Pitfall 11: Source-scanning tests break on file moves
`test/banxa/banxa_reskin_literals_test.dart` asserts a hard-coded list of 9 files exists on disk and greps their source for raw colours; `test/banxa/buy_page_layout_test.dart:174-225` greps `router.dart` for the literal `path: '/buy'` inside the ShellRoute. Deleting `user_kyc/`, `banxa_orders_history.dart` or `order_details_page.dart` fails the first; keep the `path: '/buy'` text and its position in the shell.

## Code Examples

### Statuses (proposed; strings from Banxa docs)
```dart
// Source: docs.banxa.com/products/hosted-checkout/docs/transaction-lifecycle/order-statuses
enum BanxaOrderStatus {
  pendingPayment, waitingPayment, paymentReceived, inProgress,
  cryptoTransferred, complete, cancelled, declined, expired, refunded,
  extraVerification, unknown;

  static BanxaOrderStatus parse(String wire) => switch (wire) {
    'coinTransferred' => cryptoTransferred, // seen in the brief, absent from the docs page
    _ => values.asNameMap()[wire] ?? unknown,
  };

  bool get isFinal => const {complete, declined, expired, cancelled, refunded}.contains(this);
}
```

### Filter from the route
```dart
// Source: lib/dashboard/home/widgets/transactions_slim_view.dart:51-61 (enum Filters values)
// `purchase` is an existing value; no enum change.
GoRoute(
  path: '/transactions',
  builder: (_, state) => TransactionsScreen(
    initialFilter: Filters.values.asNameMap()[state.uri.queryParameters['filter']],
  ),
),
// Buy page link: context.go('/transactions?filter=purchase');
```

### Embedded checkout on webview_flutter platforms
```dart
// Source: webview_flutter-4.14.0 (controller ctor onPermissionRequest; NavigationRequest.isMainFrame)
final controller = WebViewController(
  onPermissionRequest: (request) {
    final ok = request.types.every(
      (t) => t == WebViewPermissionResourceType.camera ||
             t == WebViewPermissionResourceType.microphone);
    ok ? request.grant() : request.deny();
  },
)
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..setNavigationDelegate(NavigationDelegate(
    onNavigationRequest: (r) {
      final u = Uri.tryParse(r.url);
      if (r.isMainFrame && u != null && u.scheme == returnUri.scheme &&
          u.host == returnUri.host && u.path == returnUri.path) {
        onReturn();
        return NavigationDecision.prevent;
      }
      return u != null && (u.scheme == 'https' || u.scheme == 'http')
          ? NavigationDecision.navigate
          : NavigationDecision.prevent;
    },
  ));
```
`WebViewPermissionResourceType.camera`/`.microphone` names must be confirmed against `webview_flutter_platform_interface-2.15.1` when implementing (constants seen in the Android impl are `videoCapture`/audio capture at `android_webview_controller.dart:334`); treat the snippet's enum member names as [ASSUMED].

### Sandbox marker and URLs
Banxa environments [CITED: docs.banxa.com/products/hosted-checkout/docs/getting-started/authentication-and-environments]:
- Sandbox API: `https://api.banxa-sandbox.com/{partnerRef}` (v2 paths under `/v2`, so `https://api.banxa-sandbox.com/gnus/v2`)
- Production API: `https://api.banxa.com/{partnerRef}`
- Checkout host: use the `checkoutUrl` the create-order response returns; do not build it. The existing KYC constant `https://gnus.banxa-sandbox.com` (`banxa_api_services.dart:18`) shows the sandbox checkout host pattern but no docs page states it, so do not hardcode.

## Q1: "No key in the app" - options and consequences (one-way decision)

| Option | Key in binary? | Meets BUY-01/07/09? | What changes in `lib/banxa` | Cost |
|--------|----------------|---------------------|-----------------------------|------|
| A. Team proxy (recommended) | No | Yes | `BanxaApiService`: drop `_apiKey`, `_headers` key, `generateHmacSignature`, `submitKYC`; `baseUrl` injected; all 6 call sites use the injected instance | New infra: hosting, deploy, monitoring, two environments, rate limit/abuse controls, ops owner |
| B. Referral / hosted-checkout URL | No | No | Would replace quote, create-order, order lookup with a URL builder (`coinType`, `fiatType`, `fiatAmount`, `blockchain`, `walletAddress`, `returnUrl`) | Banxa's own table: no in-app quote, no order history lookup, no webhooks, no KYC sharing; no `orderId` back, so nothing to track. Contradicts the sketches |
| C. Keep "read-only" calls in app | Yes | Yes | None | Docs list quote, payment methods and currency lists as key-protected; no read-only key is documented. The key still ships. Ask Banxa whether a restricted key exists (Open Question) |
| D. Key via dart-define | Yes (extractable) | Yes | Header read from a define | Only defensible for a `kDebugMode` sandbox build; never profile/release |

**Which v2 endpoints need the key:** all of them. "All v2 API endpoints require the API key header, including: Order API, Quote API, Payment Methods API, Countries & Currencies API"; the identity token share endpoint uses HMAC (`Bearer API_KEY:SIGNATURE:NONCE`) instead [CITED: docs.banxa.com/products/hosted-checkout/docs/api-integration/api-integration-overview and authentication-and-environments]. The app uses `GET /fiats/buy`, `GET /crypto/buy`, `GET /quotes/buy`, `POST /buy`, `GET /orders/{id}`, `GET /orders` (verified in `banxa_api_services.dart`); none can be called without the key.

**Proposed proxy contract (minimum):** `GET /fiats/buy`, `GET /quotes/buy`, `POST /buy`, `GET /orders/{id}`, `GET /orders` (by `externalCustomerId`). Server-enforced: fixed partner `gnus`; fixed `redirectUrl`; `crypto=GNUS`; `walletAddress` must match an EVM address; strip any client-supplied `x-api-key`; cap `fiatAmount`; per-IP rate limit; no quote caching, 5-10 s cache on order GET. `GET /orders` by customer id is enumerable by anyone who knows a public address (also true today); accept at ASVS L1 and note it.

**Key rotation:** the current key is in git since `274da454` (ROADMAP) and in every shipped binary. Removing it from the tip does not un-leak it. Rotation in the Banxa dashboard is the only remedy and must happen after the proxy is live (or before, accepting downtime). Do not rewrite history.

**Sequencing consequence:** production Buy cannot ship until (1) a proxy exists, (2) Banxa lists GNUS, (3) the key is rotated. Everything else, including a full sandbox walk against a sandbox proxy or a `kDebugMode` direct-key build, can proceed.

## Q2: Sandbox mode

- Switch: compile-time `--dart-define=GW_BANXA_ENV=sandbox` (default production) and `--dart-define=GW_BANXA_PROXY_URL=...`, both `const`, read once in `banxa_env.dart` (Pattern 1). This mirrors `GW_DEV_TOOLS` (`dev_flags.dart`). A const cannot change without a rebuild, same as the dev bubble note in memory. Show a persistent "Sandbox - no real money" marker on the Buy page and order drawer whenever `isBanxaSandbox`, so a tester build can never be mistaken for real.
- Not gated on `kDebugMode`: the phase says a sandbox build can complete a buy, and Android emulator builds come from CI release artifacts. Gate only the direct-key convenience on `kDebugMode`.
- Sandbox facts [CITED: docs.banxa.com testing/overview and sandbox-test-data]: separate sandbox key; test card `4111 1111 1111 1111`, any future expiry, any 3-digit CVV; the card name is not free text and must equal the name entered at billing details; email OTP `7203`; wallet addresses must be valid mainnet format (testnet rejected) and no crypto moves; `transactionHash` is never populated with a real hash; no failure simulation (declined/failed cannot be self-triggered); Apple Pay and Google Pay not testable; no customer emails; sandbox rate limit 120/min per merchant. Completing the full flow yields status `complete`.
- Consequence for tests: the failure-path UI (declined, expired, refunded) can only be walked with the dev fixtures (`DevBanxaFixtures`, `dev_banxa_fixtures.dart`), whose statuses must be updated to the real wire strings.
- Unknown: whether GNUS exists in the sandbox coin list for partner `gnus`. Needs the sandbox key (Environment Availability).

## Q3: In-app full-screen checkout per platform

Findings in code (all read this session):
- Pubspec has `webview_flutter` and `webview_windows`; no `desktop_webview_window`, `flutter_inappwebview` or custom-tabs package (`pubspec.yaml:39-40`).
- `/checkout` route exists (`router.dart:186-198`) and is hidden from the swap FAB (`global_swap_fab_host.dart:60`). No code navigates to it.
- `BanxaPaymentWebView`: `NavigationDelegate.onNavigationRequest` pops on substring match (`banxa_payment.dart:56-61`); Linux branch opens the system browser and shows "Payment opened in your browser" with "Re-open in Browser" and "Done" (`:130-188`).
- The app already has the split pattern: `lib/web/web_view_screen.dart` (`Platform.isWindows ? WebViewWindows : WebViewMobile`) and `router.dart:308` hides `/web` on Linux (`if (!Platform.isLinux)`).

| Platform | Available | Return URL | Deep-link registration | Caveat |
|----------|-----------|------------|------------------------|--------|
| Android | `webview_flutter_android` 4.12.0 | `onNavigationRequest` | Present: intent-filter `geniuswallet` / `banxa` / `/callback`, `launchMode="singleTop"` | No Google Pay in plain WebView; add CAMERA/RECORD_AUDIO manifest permissions; DOM storage already on |
| iOS | `webview_flutter_wkwebview` 3.25.1 (WKWebView) | `onNavigationRequest` | Absent (no `CFBundleURLTypes`) | Needs `NSMicrophoneUsageDescription`; Banxa wants iOS 15+ |
| macOS | same wkwebview plugin | same | Present in `Info.plist` | Add audio-input entitlement and usage string if liveness needs mic |
| Windows | `webview_windows` 0.4.0 (WebView2); `webview_flutter` has none | `controller.url` stream; no request-prevent API | Absent; zip distribution; `main.cpp` has no single-instance forward; second instance shows `AlreadyRunningApp` | Use polling as truth. A `geniuswallet://` navigation may hit the OS protocol handler; prefer an https return URL if Banxa accepts it |
| Linux | none | polling only | Absent; `G_APPLICATION_NON_UNIQUE` | System browser + "I've paid, check status" (today's behaviour) |

Android detail: "pay on another device" (QR/copy) stays as a menu item per sketch 081 B; it reuses `CheckoutQrPage`. The "Leave checkout?" prompt is a `PopScope` on the host; it does not exist in the Custom Tabs path.

`kyc_registration.dart` (`BanxaKycScreen`) and its `/kyc` route are deleted with the "Verify with Banxa" button (`banxa_buy_screen.dart:243-256`); KYC is inside checkout.

## Q4: Order tracking and Transactions

See Patterns 3, 4, 6. Extra facts:
- Banxa orders merge nowhere today. `orderRowContent`, `orderAsTransaction`, `orderTransactionRows`, `orderNetworkRows` are called only from `_OrderRows` on the Buy page (`banxa_buy_screen.dart:1388-1398`).
- `orderStatusTone` (`order_status_style.dart:18-34`) maps `complete` to `neutral` (only `completed` is success) and maps `cancelled`/`expired` to `error`, which contradicts sketch 082 (cancelled/expired slate). `orderTransactionStatus` routes through it and documents `cancelled`/`expired` -> `failed` (`order_transaction_mapping.dart:43-46`). Both, plus `order_status_style_test.dart` and `order_transaction_mapping_test.dart`, change together. Also `_orderStatusLabel` -> `BanxaHelpers.getOrderStatusLabel` only knows 5 statuses (`banxa_helpers.dart:45-60`).
- Sketch 082 notes `paymentReceived` must stay amber and non-final; `≈` on in-flight amounts is new (the shipped row prints `+ 1,235.62 GNUS` unconditionally at `order_transaction_mapping.dart:162`).
- Toasts have no tap action today (sketch 079). "View order" needs an optional action added to `ToastManager`.
- `BuySuccessDrawer.show(context, {onClose})` and `BuyCancelledDrawer.show(context)` take no order (`buy_success_drawer.dart`); only `dev_tools_bubble.dart:1056,1061` calls them. Give them an `Order` argument or route the final status to the shared transaction drawer instead (planner decision).
- Entry points that push `/buy` today: `wallet_information.dart:198` (origin HOME), `coins_screen.dart:509` and `assets_screen.dart:574` (origin MARKETS). Buy GNUS left the top bar on 2026-07-26 (`responsive_overlay.dart:619`). The GNUS coin page `token_info_screen.dart` has Swap and Receive and no Buy. Recommended additions: a Buy action on the GNUS token page, and on the Transactions empty state (`emptyTransactionsTitle` branch). `mobile_nav_destinations_test.dart:206` expects `'/buy': -1` (no tab lit); keep `/buy` out of the nav lists.
- Dev bubble section for Banxa (`dev_tools_bubble.dart:1056-1157`) calls `OrdersCubit.fetchOrders()` and arms `DevBanxaFixtures`; keep it working with the new statuses; fixtures are gated `kDebugMode && kShowDevTools` (`banxa_order_cubit.dart:46`).

## Q5: Prefilling the Selected wallet address

- "Selected" lives in `WalletDetailsCubit.state.selectedWallet` (`wallet_details_state.dart:8`), persisted with its type by `selectWallet` (`wallet_details_cubit.dart:250-257`) and changed from the header switcher (`account_drawer.dart:103`). `AppBloc.state.selectedSDKAccount` is the SDK node account, a different concept; do not use it for the address.
- `Wallet` has `coinType`, `walletName`, `currencySymbol`, `walletType`, `balance`, `address` [VERIFIED: packages/genius_api/lib/models/wallet.dart:9-18]. `enum WalletType { tracking, privateKey, mnemonic, keystore, sgnus }` [VERIFIED: packages/genius_api/lib/types/wallet_type.dart:6].
- Every wallet-creation path in the app uses `TWCoinType.TWCoinTypeEthereum` (`wallet_routes.dart:57`, `select_wallet_type_screen.dart:25`, `app_bloc.dart:850`), so every wallet has an EVM `address`, and `isEvmAddress` validates it.
- Which types "can receive": technically all five. `tracking` is watch-only (no keys), so GNUS bought to it cannot be spent from this app: warn or block (Open Decision). `sgnus` rows are SDK accounts; the address is still EVM and shares a customer id with the local wallet of the same address.
- Chain/network string: `blockchain` is `Blockchain.id` from `/v2/crypto/buy` (`banxa_model.dart:219-247`, `json['id']`), taken via `selectedCrypto.defaultBlockchain.id` (`create_order_cubit.dart:176,230`). The app cannot choose it; Banxa's listing decides (Pitfall 7). Docs: `blockchain` is "Required for multi-chain assets".

## Validation Architecture (existing tests, Q6)

### Existing `test/banxa` files that break or need updating

| File (lines) | Pins | Action |
|--------------|------|--------|
| `banxa_buy_screen_test.dart` (101) | "Get quote" CTA disabled, currency Retry tooltip, offline pump of `BanxaBuyScreen()` with `OrdersCubit()` | Rewrite: CTA label changes, screen takes an injected fake API |
| `buy_form_layout_test.dart` (522) | `BanxaBuyForm(state:, cardInnerWidth:, onGetQuote:, onBuy:)`, side-by-side threshold 480, `MakeOrderCubit(BanxaApiService())` (`:48`) | Delete or rewrite for the compact card |
| `buy_page_layout_test.dart` (245) | Two-column form + rail, and source-scan of `router.dart` for `path: '/buy'` inside the ShellRoute (`:174-225`) | Drop layout parts; keep the router-scan intent |
| `orders_header_track_test.dart` (385), `orders_rail_bounds_test.dart` (347), `order_rail_row_test.dart` (233) | The private `_OrdersRail` / `_OrderRows` on the Buy page | Delete; port the row/drawer assertions to a Transactions test |
| `order_status_counts_test.dart` (100), `order_status_style_test.dart` (144) | Tone ladder including `complete` as neutral; `OrdersState.statusCounts` | Rewrite for the enum |
| `order_transaction_mapping_test.dart` (305) | `cancelled`/`expired` -> failed; `completed` strings | Update for 082 tones and wire strings |
| `order_card_test.dart`, `order_details_card_test.dart`, `orders_history_states_test.dart` | `OrderCard`, `OrderDetailsCard`, orders-history states | Delete with the history page (`/buy/orders`) or keep if those widgets survive |
| `checkout_options_sheet_test.dart` (164) | Three-button sheet (browser, QR, copy) | Repurpose to the "Pay on another device" menu or delete |
| `checkout_qr_test.dart` (134) | `PollingCubit` with `BanxaApiService()` at `:19`; success/fail transitions on `completed`/`failed` | Update terminal statuses; use fake API |
| `webview_fallback_test.dart` (291) | Inline reproduction of the Linux fallback subtree, "cannot prove the fallback fires on Linux" | Replace with tests for the new external-browser host |
| `banxa_reskin_literals_test.dart` (204) | Hard-coded list of 9 files must exist on disk | Update the list |
| `banxa_customer_id_test.dart`, `banxa_test_harness_test.dart`, `fixtures.dart`, `gw_pump.dart` | Customer id, `testOrder(status: 'completed')` default | Keep; change the default status to `complete` |

Other suites that mention Banxa: `test/dashboard/transaction_utils_test.dart`, `test/dashboard/transaction_filters_test.dart` (filter bar width/rail rows), `test/components/mobile_nav_destinations_test.dart` (`'/buy': -1`), `test/theme/*` contrast tests.

### Test Framework
| Property | Value |
|----------|-------|
| Framework | flutter_test (Flutter 3.41.9 at `C:/Users/User/Documents/Projects/GNUS/flutter/flutter/bin`), hand-written fakes; `mockito ^5` available but unused by Banxa tests |
| Config file | none; `analysis_options.yaml` at repo root |
| Quick run command | `flutter test test/banxa` (run from the repo root with the SDK bin on PATH) |
| Full suite command | `flutter test` |
| Static checks | `flutter analyze` (exit code, not `tail`), `dart format --set-exit-if-changed lib test`, `bash tool/check_brace_style.sh`, `bash tool/check_raw_colors.sh`, `bash tool/check_no_new_key_logging.sh --scan-tree lib/banxa/*.dart` |

No baseline was run in this session: the worktree has no `.dart_tool` and the `banxa`, `squidrouter` and `tokeninfo` submodules are uninitialised (`git submodule status` shows `-` prefixes; `pubspec.yaml:57` depends on `path: squidrouter`), so `flutter pub get` cannot resolve until `git submodule update --init` runs. The executor records the baseline in Wave 0.

### Phase Requirements to Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| BUY-01 | Compact card renders: amount, fiat pill, method row only when >1 method, "You get" + fee rows, no "Get quote"; quote refreshes on timer (fake clock) | widget + cubit (`fakeAsync`) | `flutter test test/banxa/buy_card_test.dart` | Wave 0 |
| BUY-02 | Address = selected wallet at tap; a switch between quote and tap changes the submitted address | cubit | `flutter test test/banxa/create_order_address_test.dart` | Wave 0 |
| BUY-03 | No key literal in `lib/`, no header/body printing in `lib/banxa/`, no `x-api-key` in client requests | source-scan test + shell check | `flutter test test/banxa/no_banxa_secret_test.dart` and `bash tool/check_no_new_key_logging.sh --scan-tree lib/banxa/banxa_api_services.dart` | Wave 0 |
| BUY-04 | Env const selects base URL; sandbox marker shown when sandbox | widget (inject env) | `flutter test test/banxa/banxa_env_test.dart` | Wave 0 |
| BUY-05 | Platform chooser returns the right host; Linux external host shows waiting card; `/kyc` and "Verify with Banxa" absent | widget + source-scan | `flutter test test/banxa/checkout_host_test.dart` | Wave 0 |
| BUY-06 | Return URL match uses scheme+host+path and main-frame only; status >= `paymentReceived` marks Done without a URL | unit + cubit | `flutter test test/banxa/checkout_return_test.dart` | Wave 0 |
| BUY-07 | Poller polls only non-final orders, stops on the final set, refetches on wallet switch, drops a stale wallet-A response | cubit (`fakeAsync`, fake API) | `flutter test test/banxa/orders_poller_test.dart` | Wave 0 |
| BUY-08 | Enum parses all 11 wire strings + `coinTransferred` + unknown; tone/label/final table | unit | `flutter test test/banxa/banxa_order_status_test.dart` | Wave 0 |
| BUY-09 | Orders appear under `Filters.purchase`; count of open orders; row and drawer use `orderRowContent`; `/transactions?filter=purchase` preselects | widget with `GoRouter` | `flutter test test/dashboard/buy_orders_filter_test.dart` | Wave 0 |
| BUY-10 | Final status emits once and raises the result surface; happy path silent per sketch | cubit + widget | `flutter test test/banxa/order_result_test.dart` | Wave 0 |
| BUY-11 | Entry points push `/buy`; token page and empty-state buttons exist; Buy page link goes to the filtered route | widget | `flutter test test/banxa/buy_entry_points_test.dart` | Wave 0 |
| BUY-12 | Deleted files gone; `banxa_reskin_literals_test` list matches disk | existing scan | `flutter test test/banxa/banxa_reskin_literals_test.dart` | update |

Design for testability (the reason the existing tests could only pump the offline error step): inject `BanxaApiService` into `MakeOrderCubit`, `OrdersCubit`, `PollingCubit` and the checkout host, and write `class FakeBanxaApi implements BanxaApiService` with canned `fiats`, `cryptos` (with and without GNUS), quotes and a scripted status sequence. No new abstraction class is needed.

### Sampling Rate
- **Per task commit:** the touched test file plus `flutter test test/banxa`
- **Per wave merge:** `flutter test` plus `flutter analyze` (check `$?`), `dart format`, the three `tool/` scripts
- **Phase gate:** full suite green and analyze clean before `/gsd-verify-work`

### Wave 0 Gaps
- [ ] `git submodule update --init` and `flutter pub get` in `C:/Users/User/Documents/Projects/GNUS/GW-v3`, then record the baseline (test count, analyze exit code)
- [ ] `test/banxa/fake_banxa_api.dart` and fixtures updated to real wire statuses (`fixtures.dart:testOrder` default `'completed'` becomes `'complete'`)
- [ ] The new test files in the table above
- [ ] CI: extend `build.yml:1461` `--scan-tree` to `lib/banxa/*.dart`; add a repo-wide 40-hex `x-api-key`-style secret scan

### Needs a live sandbox walk (cannot be automated)
1. Sandbox buy end to end on Windows, macOS, Android emulator (GW_Test AVD), and one iOS device or simulator: fill, quote, Buy, KYC in checkout, card `4111...`, return, order reaches `complete`.
2. Camera/microphone liveness prompt inside the WebView on each platform (sandbox KYC uses a fixed PIN, so liveness may not appear there; production-only).
3. Google Pay / Apple Pay behaviour (not testable in sandbox).
4. What Banxa really appends to `redirectUrl` and whether a custom-scheme `redirectUrl` is accepted.
5. Linux external-browser flow.
6. Failure statuses (declined, expired, refunded) only via dev fixtures or Banxa support; the sandbox cannot self-trigger them.

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Wallet holds Banxa key, calls REST from the client | Server-side calls; Banxa: "server-to-server REST API calls" | Banxa docs today | Forces a proxy for this app |
| Get quote then Buy | Auto-refreshing quote, single CTA (MetaMask, Ledger) | UX research 2026-09-30 | BUY-01 |
| Browser tab + hope for callback | In-app WebView (mobile), browser + status poll (desktop) | MetaMask PR 31534 / 46394 per UX research | BUY-05/06 |
| Match `completed` | `complete` is the only final success; `paymentReceived` is not final | Banxa order-statuses page | BUY-08 |

**Deprecated/outdated in this repo:** `PollingCubit` terminal set (`completed`/`failed`/`cancelled`), `pollOrderStatus` (`banxa_api_services.dart:206-245`, unreferenced except its own definition; also compares `status.toLowerCase() == 'inProgress'`, which can never be true), `OrderLinker`, `submitKYC`, `generateHmacSignature`, `banxaKycUrl`.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Banxa accepts a custom-scheme `redirectUrl` (`geniuswallet://...`) at create-order | Pitfall 3, Q3 | Orders fail to create or return breaks; fallback is an https return URL hosted on gnus.ai |
| A2 | On a return, Banxa appends no reliable params (or `orderId`/`status`) | Pitfall 3 | Design does not depend on it; only affects the accelerator |
| A3 | WebView2 handles an unregistered custom scheme without a blocking OS dialog | Q3 table (Windows) | If it prompts, prefer an https return URL on Windows |
| A4 | Enum member names `WebViewPermissionResourceType.camera`/`.microphone` | Code Examples | Compile error at implementation; check the platform-interface source |
| A5 | 10 s quote interval is acceptable to Banxa's rate limit via a proxy | Pitfall 4 | Raise the interval or share quotes; numbers are arithmetic from the documented 500/min per IP |
| A6 | The sandbox checkout host is `gnus.banxa-sandbox.com` | Q2 | None if `checkoutUrl` from the API is used as recommended |
| A7 | GNUS exists in the sandbox coin list | Q2 | Sandbox walk blocked until Banxa adds it |
| A8 | `GoRouter` keeps the same `State` when only the query of the same route changes | Pattern 6 | `initialFilter` would not update without `didUpdateWidget`; verify in the widget test |
| A9 | A Banxa sandbox key is low-risk enough for a `kDebugMode`-only dev build | Q1 option D | If not, sandbox also needs the proxy |
| A10 | Google Pay is not offered for partner `gnus` (inferred from the verified fiat method list) | Pitfall 2 | Android would need Custom Tabs as the default path |

## Open Questions

1. **Does Banxa issue a restricted or read-only API key?** Docs are silent. A yes changes Option C from "ships the key" to "ships a weak key". Ask Banxa; do not plan around it.
2. **Who hosts the proxy?** Nothing in the repo is team-hosted (the only third-party hosts in `lib/` are CoinGecko, explorers and Sentry). Needs an owner, a domain and a deploy path before BUY-03 can go live.
3. **Does the `gnus` partner's KYC require camera liveness?** Determines whether Android/iOS/macOS permission work is in scope for the first release.
4. **Is GNUS listed in sandbox?** Needs the sandbox key and one `GET /gnus/v2/crypto/buy` call.
5. **What does Banxa append to `redirectUrl`, and is https required?** One sandbox order answers both.

## Open decisions for the planner

1. **Approve the proxy (Option A).** One-way and costly. Alternative is to ship only the sandbox/dev work in this phase and defer production Buy. Recommend A, with production go-live gated on proxy + Banxa listing + key rotation.
2. **Rotate the leaked key.** Dashboard action, owner Braian/Banxa contact; sequence relative to proxy go-live.
3. **Return URL:** keep `geniuswallet://banxa/callback` with one shared constant (smaller diff, works Android/macOS), or move to an https return URL hosted on gnus.ai (works in every in-app webview incl. Windows). Recommend the smaller diff plus status-driven Done; revisit after spike Q5.
4. **Google Pay rule:** adopt the runtime rule in Pitfall 2 (Custom Tabs when a Google/Apple Pay method appears) or ship the WebView only.
5. **Tracking wallets:** warn, block, or allow buying into a watch-only wallet.
6. **Expired orders:** stop polling at `expired`, or keep a bounded window (Banxa: an expired order can reactivate if payment arrives late).
7. **Orders for an SGNUS Selected wallet:** show them in `SgnusTransactionsScreen` (needs plumbing) or accept they only show under a non-SGNUS wallet.
8. **`externalCustomerId`:** keep `gw-<address>` (recommended; changing orphans existing orders) despite Banxa's advice.
9. **Result surface for final status:** adapt `BuySuccessDrawer`/`BuyCancelledDrawer` to take an `Order`, or open the shared transaction drawer. Happy path is silent per sketch 082.
10. **"Not listed yet" state** for a missing GNUS coin (not in the sketches; needs a design call).
11. **Filter label:** rename `Filters.purchase` label to "Buy orders" (also changes empty-state copy and pinned test numbers).
12. **Suggested wave order (all sequential, all touch `lib/banxa/`):** W0 bootstrap + fake API + status enum; W1 client refactor (no key, env, no prints, delete dead code); W2 OrdersCubit poller + wallet scoping; W3 Buy card + quote timer + address; W4 checkout hosts + return; W5 Transactions integration + filter param + entry points + result surface; W6 test rewrite, CI scans, live sandbox walk.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | build, tests | yes (not on PATH) | 3.41.9, engine 42d3d75a56 (`flutter --version`) | none |
| `.dart_tool` / pub packages in worktree | tests | no | - | `flutter pub get` after submodules |
| Git submodules `banxa`, `squidrouter`, `tokeninfo` | pub get (`squidrouter` path dep) | no (uninitialised) | - | `git submodule update --init` (URLs are relative `../squidrouter` etc.) |
| Banxa sandbox API key + partner `gnus` sandbox access | live walk | not available to this session | - | Fake API for automated tests; live walk blocked |
| Team proxy (sandbox + production) | BUY-03/04 | no, does not exist | - | `kDebugMode` direct-key sandbox build for dev only |
| Android emulator (GW_Test AVD), iOS device, macOS host | live walks | not probed | - | Per-platform walk list in Validation Architecture |
| WebView2 runtime | Windows checkout | not probed (already required by `/web`) | - | none |

**Missing dependencies with no fallback:** Banxa sandbox key (live walk), a proxy owner and host (production).
**Missing dependencies with fallback:** submodules and pub cache (initialise in Wave 0), proxy (debug direct-key mode).

## Security Domain

`security_enforcement` is enabled (absent/true) at ASVS level 1 in `.planning/config.json`.

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no (no user accounts) | - |
| V3 Session Management | no | - |
| V4 Access Control | yes (proxy) | Proxy allowlist of routes; server-pinned partner/redirect; note that `GET /orders` by customer id is enumerable by public address |
| V5 Input Validation | yes | `isEvmAddress` on the address, numeric bounds on amount, WebView scheme allowlist (http/https/return only), proxy re-validates every field |
| V6 Cryptography | no client crypto | Delete the client-side HMAC helper; do not hand-roll signing |
| V7 Error Handling / Logging | yes | No prints in `lib/banxa/`; scrub Sentry breadcrumbs; do not log `checkoutUrl` |
| V8 Data Protection | yes | Wallet address is sent to Banxa by design (documented in the disclaimer once); no key material in Cubit state |
| V9 Communications | yes | https only. `ios/Runner/Info.plist` sets `NSAppTransportSecurity` / `NSAllowsArbitraryLoads` true, so ATS gives no protection here; enforce https in code |
| V10 Malicious Code / V14 Configuration | yes | Key removed from source; rotate; add a secret scan to CI |

### Known Threat Patterns for this stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Hardcoded API key extracted from binary or git | Information Disclosure | Proxy custody; rotate; CI secret scan |
| Key or checkout URL in Sentry breadcrumbs (`print` breadcrumbs default on, `sendDefaultPii = true`) | Information Disclosure | Delete prints; `beforeBreadcrumb` scrub for `banxa` URLs |
| Malicious/compromised API response supplying a `checkoutUrl` to a phishing host | Spoofing | Only open `checkoutUrl` if scheme is https and host ends with `banxa.com` or `banxa-sandbox.com`; the in-checkout redirects to bank 3DS pages must still be allowed |
| Address swapped between quote and order | Tampering | Read the Selected wallet at tap and show the same short address on the confirm row; proxy validates format |
| Open redirect / arbitrary scheme in the WebView | Tampering | `NavigationDelegate` blocks non-http(s) except the return URL; check `isMainFrame` |
| Camera/microphone over-grant | Elevation of Privilege | Grant only camera/microphone types while the checkout host is loaded |
| Proxy abuse (order spam, quote scraping, DoS on shared IP quota) | Denial of Service | Per-IP rate limit, amount caps, order GET cache |
| Watch-only wallet as destination | Tampering / user error | Warn or block (Open Decision 5) |

## Sources

### Primary (HIGH confidence)
- Repo files read this session: `lib/banxa/banxa_api_services.dart`, `banxa_payment.dart`, `banxa_model.dart`, `banxa_order/*`, `banxa_helpers/*`, `banxa_components/order_status_style.dart`, `handle_banxa_drawer.dart`, `user_kyc/kyc_registration.dart`, `lib/screens/banxa_buy_screen.dart`, `lib/screens/order_details_page.dart`, `lib/navigation/router.dart`, `lib/main.dart`, `lib/dev/dev_flags.dart`, `lib/dashboard/home/widgets/transactions_slim_view.dart`, `lib/dashboard/transactions/*`, `lib/wallets/cubit/wallet_details_cubit.dart`, `lib/web/*`, `android/.../AndroidManifest.xml`, `ios/Runner/Info.plist`, `macos/Runner/Info.plist`, `windows/runner/main.cpp`, `linux/my_application.cc`, `.github/workflows/build.yml`, `tool/check_no_new_key_logging.sh`, `test/banxa/*`, `packages/genius_api/lib/models/wallet.dart`, `types/wallet_type.dart`, `assets/json/tokens/*.json`.
- Plugin sources in the local pub cache: webview_flutter-4.14.0, webview_flutter_android-4.12.0, webview_flutter_wkwebview-3.25.1, webview_flutter_platform_interface-2.15.1, url_launcher_android-6.3.30, sentry-9.22.0, sentry_flutter-9.22.0.
- Banxa docs (fetched): https://docs.banxa.com/products/hosted-checkout/docs/api-integration/api-integration-overview ; .../getting-started/authentication-and-environments ; .../testing/overview ; .../testing/sandbox-test-data ; .../transaction-lifecycle/order-statuses ; .../transaction-lifecycle/order-lookup ; .../api-integration/create-buy-order ; .../getting-started/integration-best-practices ; .../checkout-experience/iframe/webview-mobile ; https://docs.banxa.com/docs/referral-link ; https://docs.banxa.com/docs/webhooks ; https://docs.banxa.com/docs/checkout-approaches

### Secondary (MEDIUM confidence)
- Context7 `/llfbandit/app_links` (Windows registry registration, `SendAppLinkToInstance`, Linux flags); Context7 `/jnschulze/flutter-webview-windows` (`url` stream, `permissionRequested`, popup policy).
- `39-UX-RESEARCH.md` (other wallets' patterns; its vendor claims were not re-verified).

### Tertiary (LOW confidence)
- Nothing relied on from web search alone. The referral parameter list came from a search snippet and was cross-checked against the fetched supported-parameters page.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH. All packages already locked and sources read; nothing new to install.
- Architecture: MEDIUM. Layering and Transactions integration follow existing code; the proxy and return-URL behaviour depend on the open questions.
- Pitfalls: HIGH for code-derived items (Windows crash, callback mismatch, print breadcrumbs, source-scanning tests); MEDIUM for Banxa behaviours (rate limit under a proxy, Google Pay).

**Research date:** 2026-09-30
**Valid until:** 2026-10-30 for code facts (branch `gsd/v3.0-banxa-hardening` at `c551a694`); 2026-10-14 for Banxa docs claims (vendor pages change).
