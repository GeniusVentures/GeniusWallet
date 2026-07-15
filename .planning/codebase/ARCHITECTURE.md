<!-- refreshed: 2026-07-15 -->
# Architecture

**Analysis Date:** 2026-07-15

## System Overview

```text
┌──────────────────────────────────────────────────────────────────────────┐
│                        Flutter/Material UI Layer                         │
│   Views & Widgets (lib/*/view, lib/screens)                              │
│   • Dashboard, Transactions, Swap, Markets, News, Settings, Onboarding   │
└────────────────┬─────────────────────────────────┬──────────────────────┘
                 │                                 │
                 ▼                                 ▼
┌──────────────────────────────┐    ┌──────────────────────────────┐
│  Navigation & Shell Layout   │    │  Theme & Design System       │
│  lib/navigation/router.dart  │    │  lib/theme/                  │
│  GoRouter + ShellRoute       │    │  (colors, gradients, consts) │
│  lib/components/overlay/     │    │                              │
│  responsive_overlay.dart     │    │  Responsive Breakpoints      │
└─────────────┬────────────────┘    │  lib/utils/breakpoints.dart  │
              │                      └──────────────────────────────┘
              │
              ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                    State Management Layer (BLoC/Cubit)                   │
│                                                                          │
│  Main: AppBloc (lib/bloc/app_bloc.dart)                                  │
│    • SDK initialization, wallet loading, account management              │
│    • SGNUS connection streaming, transaction streaming                   │
│    • Events: InitializeSDK, LoadWallets, FetchAccount,                  │
│      StartSGNUSTransactionsStream, SelectSDKAccount, etc.               │
│                                                                          │
│  Feature Cubits:                                                        │
│    • WalletDetailsCubit (lib/wallets/cubit/) - wallet & coin selection  │
│    • TransactionsCubit (lib/dashboard/transactions/cubit/)              │
│    • OrdersCubit (lib/banxa/banxa_order/) - Banxa orders                │
│    • SubmitJobCubit (lib/submit_job/cubit/) - job submissions           │
│    • PollingCubit (lib/banxa/banxa_order/) - order polling              │
│    • GnusCubit (lib/dashboard/gnus/cubit/) - GNUS token data            │
│                                                                          │
│  Providers (ChangeNotifier + Provider):                                 │
│    • NetworkProvider (lib/providers/network_provider.dart)              │
│    • NetworkTokensProvider (lib/providers/network_tokens_provider.dart) │
└────────────┬──────────────────────────────────────────────────────────┘
             │
             ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                      Data & Services Layer                               │
│                                                                          │
│  Core API Facade:                                                        │
│    • GeniusApi (packages/genius_api/lib/src/genius_api.dart)            │
│      - Wraps native GeniusSDK via FFI bindings                          │
│      - Manages wallet streams, SGNUS transactions, account operations   │
│      - Web3 transaction broadcasting via web3dart                       │
│                                                                          │
│  External Services:                                                     │
│    • BanxaApiService (lib/banxa/banxa_api_services.dart)               │
│    • CoinGeckoApi (lib/services/coin_gecko/coin_gecko_api.dart)        │
│    • CoinTelegraphApi (lib/services/coin_telegraph/)                   │
│    • Web3 (packages/genius_api/lib/web3/web3.dart)                     │
│    • SecureStorage (packages/local_secure_storage/)                    │
│                                                                          │
│  Data Controllers (RxDart BehaviorSubject streams):                     │
│    • SGNUSConnectionController                                          │
│    • SGNUSTransactionsController                                        │
│    • _walletsController (in GeniusApi)                                  │
└────────────┬──────────────────────────────────────────────────────────┘
             │
             ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                  Local Persistence & Platform Layer                      │
│                                                                          │
│  Hive NoSQL Database (lib/hive/):                                       │
│    • HiveModels: CoinGeckoMarketData, CoinGeckoCoin,                   │
│      HistoricalPriceEntry, NewsArticle                                  │
│    • Boxes: marketDataBox, coinsBox, priceHistoryBox, newsBox          │
│    • TransactionStorageService for persistent transaction caching       │
│                                                                          │
│  SecureStorage (packages/local_secure_storage/):                        │
│    • Wallet mnemonic/private key encryption (platform-specific)        │
│    • iOS: Keychain; Android: KeyStore; Windows: DPAPI                  │
│                                                                          │
│  FFI Bindings (packages/genius_api/lib/ffi/):                           │
│    • GeniusApiFFI - native GeniusSDK C interface                        │
│    • TrustWalletApiFFI - Trust Wallet core (HD wallets, signing)       │
│    • FFIBridgePrebuilt - prebuilt binary coordination                   │
│                                                                          │
│  Platform-Specific:                                                     │
│    • WindowManager (desktop navigation/lifecycle)                       │
│    • WebViewFlutter/WebViewWindows (in-app web browsing)               │
│    • PathProvider (app documents directory)                             │
│    • AppLinks (deep linking)                                            │
└──────────────────────────────────────────────────────────────────────────┘
```

## Component Responsibilities

| Component | Responsibility | File |
|-----------|----------------|------|
| **AppBloc** | App-wide state (SDK init, wallets, accounts, SGNUS stream) | `lib/bloc/app_bloc.dart` |
| **Router** | Navigation with GoRouter, redirect guards, route matching | `lib/navigation/router.dart` |
| **Overlay** | Responsive shell (mobile/desktop), bottom nav, app bar | `lib/components/overlay/responsive_overlay.dart` |
| **GeniusApi** | Wallet creation, signing, FFI bridge, secure storage | `packages/genius_api/lib/src/genius_api.dart` |
| **WalletDetailsCubit** | Wallet/network/coin selection, balance updates | `lib/wallets/cubit/wallet_details_cubit.dart` |
| **TransactionsCubit** | Transaction history loading & caching | `lib/dashboard/transactions/cubit/transactions_cubit.dart` |
| **OrdersCubit** | Banxa order history & filtering | `lib/banxa/banxa_order/banxa_order_cubit.dart` |
| **Theme** | Design tokens, colors, gradients, responsive breakpoints | `lib/theme/` |
| **Components** | Shared widgets (buttons, QR, toast, overlay, coins list) | `lib/components/` |
| **Hive** | Local DB schemas, boxes, migration logic | `lib/hive/` |
| **Providers** | Network and token metadata loaders | `lib/providers/` |
| **Services** | External API integrations (CoinGecko, Banxa, Web3) | `lib/services/` |

## Pattern Overview

**Overall:** Domain-driven, feature-based architecture with explicit layering.

**Key Characteristics:**
- **Separation of Concerns:** UI layer (views/widgets) → State (BLoC/Cubit) → Data (services/API)
- **Reactive Streams:** RxDart BehaviorSubjects for wallet/transaction state; stream subscriptions in AppBloc
- **Provider Pattern:** ChangeNotifier for app-wide providers (network, tokens); RepositoryProvider for GeniusApi
- **Feature Isolation:** Each domain (onboarding, dashboard, banxa, squid_router, etc.) has its own cubit/bloc and view directory
- **Responsive Design:** LayoutBuilder + MediaQuery for mobile/tablet/desktop adaptation
- **Platform Abstraction:** FFI for native SDK, platform-specific secure storage, conditional web view imports

## Layers

**UI Layer:**
- Purpose: Render user-facing screens and interactive components
- Location: `lib/*/view/`, `lib/screens/`, `lib/components/`
- Contains: Widgets, screens, reusable components (buttons, cards, dialogs)
- Depends on: BLoC/Cubit (state), GeniusApi (injected via context)
- Used by: Go Router navigation, Shell layout

**Navigation Layer:**
- Purpose: Route management, deep linking, guard logic
- Location: `lib/navigation/router.dart`, `lib/onboarding/routes/`, `lib/components/overlay/`
- Contains: GoRouter definition, redirect logic, route guards, responsive shell
- Depends on: AppBloc (redirect checks), BLoC/Cubit (route builders)
- Used by: MyApp MaterialApp.router

**State Management Layer:**
- Purpose: Encapsulate business logic, emit new states, manage side effects
- Location: `lib/bloc/`, `lib/**/cubit/`, `lib/providers/`
- Contains: BLoC (multi-event, state) and Cubit (single method, state) classes
- Depends on: GeniusApi, services, secure storage
- Used by: UI (BlocBuilder/BlocListener), router redirects

**Data Layer:**
- Purpose: Abstract external APIs, provide unified data interface
- Location: `packages/genius_api/`, `lib/services/`
- Contains: GeniusApi facade, Banxa/CoinGecko clients, Web3 broadcaster, transaction cache
- Depends on: FFI bindings, SecureStorage, HTTP clients (http, web3dart)
- Used by: BLoC/Cubit (for data fetching)

**Persistence Layer:**
- Purpose: Local caching and sensitive data encryption
- Location: `lib/hive/`, `packages/local_secure_storage/`
- Contains: Hive boxes (marketData, coins, news, price history), secure storage (wallets, keys)
- Depends on: Hive plugin, platform-specific keychain/keystore APIs
- Used by: Services (cache), GeniusApi (load/save wallets)

## Data Flow

### Primary Request Path: User Views Dashboard

1. **Router Redirect** (`lib/navigation/router.dart:49-69`)
   - GoRouter.redirect checks AppBloc state (sdkStatus, subscribeToWalletStatus, accountStatus)
   - If initial, emits InitializeSDK → LoadWallets → FetchAccount → StartSGNUSTransactionsStream

2. **AppBloc Initialization** (`lib/bloc/app_bloc.dart:57-125`)
   - InitializeSDK calls GeniusApi.initSDK() (FFI)
   - LoadWallets loads wallets from secure storage via GeniusApi.getWallets()
   - Starts SGNUS connection listener
   - Emits AppState with wallets, selectedSDKAccount, sdkAccounts
   - Calls WalletDetailsCubit.loadInitial() and TransactionsCubit.loadInitial()

3. **Dashboard View Render** (`lib/dashboard/home/view/dashboard_screen.dart:47-75`)
   - BlocBuilder<AppBloc> checks subscribeToWalletStatus == loaded
   - Calls WalletDetailsCubit.getCoins() in initState
   - Renders ResponsiveDashboardView (desktop) or OneColumnDashBoardView (mobile)

4. **Coin & Balance Update** (`lib/wallets/cubit/wallet_details_cubit.dart:79-95`)
   - getCoins() fetches coin balances for selected wallet+network via GeniusApi
   - CoinGeckoApi (if enabled) enriches with market prices
   - WalletDetailsCubit emits new state with coins list
   - UI re-renders coin cards with live prices

### Secondary Flow: Transaction Processing & SGNUS Connection

1. **SGNUS Listener** (`lib/bloc/app_bloc.dart:165+`)
   - AppBloc starts StreamSubscription to _sgnusConnectionSubscription
   - GeniusApi broadcasts SGNUSConnection (connected, processing, disconnected)
   - On connection, AppBloc polls processing status every 1s (ProcessingStatusTicked)

2. **Transaction Stream** (`lib/bloc/app_bloc.dart:43-58`)
   - AppBloc.StartSGNUSTransactionsStream subscribes to GeniusApi.getSGNUSTransactionsController()
   - New transactions flow to TransactionsCubit
   - TransactionsCubit stores in Hive cache (TransactionStorageService)
   - UI (TransactionsScreen) displays via StreamBuilder

3. **Order Flow (Banxa)** (`lib/navigation/router.dart:84-95`, `lib/banxa/banxa_order/create_order_cubit.dart`)
   - User navigates to /createOrder
   - MakeOrderCubit calls BanxaApiService.createOrder()
   - Order ID returned, user navigated to /checkout (WebView)
   - PollingCubit polls order status until complete
   - OrderDetailsPage displays final status

**State Management:**
- **AppBloc** holds wallet list, accounts, processing status (updated every 1s)
- **WalletDetailsCubit** holds selected wallet/network/coin, balance, token list
- **Providers** (NetworkProvider, NetworkTokensProvider) load once at startup, notifyListeners on changes
- **Hive** caches market data, coins, news articles, price history (survives app restart)
- **Streams** (BehaviorSubject) for wallets, SGNUS transactions (emit latest value to new subscribers)

## Key Abstractions

**Wallet Abstraction:**
- Purpose: Unified interface over multi-chain wallets (EVM, Bitcoin, etc.)
- Examples: `lib/wallets/cubit/wallet_details_cubit.dart`, `packages/genius_api/models/wallet.dart`
- Pattern: Wallet model holds address, balance, type (external/import), associated network

**Transaction Abstraction:**
- Purpose: Cache and stream transactions from SGNUS and chain RPC
- Examples: `lib/dashboard/transactions/cubit/transactions_cubit.dart`, `SGNUSTransactionsController`
- Pattern: TransactionsCubit loads paginated history, Hive caches, streams new via controller

**Coin/Token Abstraction:**
- Purpose: Represent blockchain assets with metadata and market prices
- Examples: `packages/genius_api/models/coin.dart`, `lib/hive/models/coin_gecko_coin.dart`
- Pattern: Coin model from GeniusApi, enriched with CoinGecko market data in Hive

**Order Abstraction (Banxa):**
- Purpose: Unified order lifecycle (create, poll, complete, callback)
- Examples: `lib/banxa/banxa_model.dart`, `lib/banxa/banxa_order/banxa_order_cubit.dart`
- Pattern: OrdersCubit holds cached orders, PollingCubit handles status polling

## Entry Points

**App Entry:**
- Location: `lib/main.dart:66`
- Triggers: App launch (platform: Android/iOS/Windows/macOS/Web)
- Responsibilities: 
  - Initialize Sentry error tracking
  - Initialize Hive local DB
  - Load SecureStorage (wallets)
  - Create GeniusApi instance
  - Load NetworkProvider and NetworkTokensProvider
  - Fetch all CoinGecko coins
  - Load stored wallets
  - Initialize WindowManager (desktop)
  - Set up MultiProvider and MultiBlocProvider
  - Run MyApp with MaterialApp.router(geniusWalletRouter)

**Navigation Entry:**
- Location: `lib/navigation/router.dart:46`
- Triggers: Routing on app startup and user navigation
- Responsibilities: 
  - Redirect guards (check AppBloc state before allowing route access)
  - Route matching (/dashboard, /swap, /buy, /onboarding, etc.)
  - ShellRoute layout (ResponsiveOverlay for mobile/desktop)
  - Deep link handling (Banxa callback, wallet connect, etc.)

**Onboarding Entry:**
- Location: `lib/onboarding/routes/wallet_routes.dart:22+`
- Triggers: First app launch (no wallets detected) or user creates new wallet
- Responsibilities: 
  - Route user through wallet creation or import flow
  - Collect mnemonic/private key via NewWalletBloc or ExistingWalletBloc
  - Create wallet via GeniusApi.createWallet() or importWallet()
  - Persist in SecureStorage

**Feature Entries (via ShellRoute):**
- Dashboard (`/dashboard`) → DashboardScreen → coins, balance, transactions
- Transactions (`/transactions`) → TransactionsScreen → tx history with filters
- Swap (`/swap`) → SwapScreen → Squid Router integration
- Markets (`/markets`) → MarketsScreen → CoinGecko prices
- Buy (`/buy` or `/createOrder`) → Banxa integration screens

## Architectural Constraints

- **Threading:** Single-threaded event loop (Flutter); FFI calls (GeniusSDK, TrustWallet) may block briefly
- **Global state:** GeniusApi (singleton via RepositoryProvider), AppBloc (single instance), Hive boxes (singletons)
- **Circular imports:** Minimal (separate part files in bloc for events/state); packages/genius_api is acyclic
- **Platform differences:** 
  - Windows/macOS desktop: WindowManager for lifecycle, WebViewWindows for browsing
  - Linux: No web view support (conditional route in router)
  - iOS: Uses native Keychain for secure storage
  - Android: Uses native KeyStore for secure storage
  - Web: device_preview for testing; conditional logic disables desktop-only features

## Anti-Patterns

### Mutable Widget State Without Rebuild Trigger

**What happens:** Some cubits/providers emit but listeners don't rebuild (e.g., manually modifying list without emit).

**Why it's wrong:** UI becomes stale; user sees outdated data; difficult to debug.

**Do this instead:** Always emit a new state after data mutations in cubits. Use copyWith() to create new instances. Example: `emit(state.copyWith(coins: [...state.coins, newCoin]))` in `WalletDetailsCubit`.

### Direct FFI Calls on Main Thread

**What happens:** Long-running FFI operations (wallet creation, signing) block UI if called directly from BLoC.

**Why it's wrong:** UI jank, frozen app, poor UX.

**Do this instead:** Wrap FFI calls in async/await; use Isolate.spawn() for heavy operations if needed. GeniusApi already handles this via GeniusSDK async interface.

### Hardcoded Network/Coin Data

**What happens:** Network chains and token lists embedded in code (was done for testing).

**Why it's wrong:** Difficult to update without recompile; no dynamic network addition.

**Do this instead:** Load from assets (JSON) via NetworkProvider and NetworkTokensProvider. See `lib/assets/read_asset.dart`.

## Error Handling

**Strategy:** Defensive: try-catch in services, emit error state in cubits, show user-facing toast/dialog

**Patterns:**
- **Service Layer:** BanxaApiService, CoinGeckoApi wrap HTTP calls in try-catch, throw custom exceptions or return null
- **BLoC/Cubit:** Catch exceptions, emit error status (e.g., `OrdersStatus.error`), caller checks status and renders error UI
- **UI Layer:** BlocListener catches errors, shows Toast via ToastManager or bottom drawer
- **Sentry Integration:** Global exception handler in main.dart captures crashes, logs to Sentry

Example (lib/banxa/banxa_order/banxa_order_cubit.dart:9-33):
```dart
Future<void> fetchOrders(String? externalCustomerId) async {
  emit(state.copyWith(status: OrdersStatus.loading, error: ''));
  try {
    final orders = await BanxaApiService().fetchAllOrders(...);
    emit(state.copyWith(status: OrdersStatus.success, orders: orders));
  } catch (e) {
    emit(state.copyWith(status: OrdersStatus.error, error: e.toString()));
  }
}
```

## Cross-Cutting Concerns

**Logging:**
- Approach: debugPrint() in Dart (console only); Sentry for production errors
- No persistent app logging framework; SDK logs in separate sgnslog.log (managed by native GeniusSDK)

**Validation:**
- Approach: Inline checks in cubits/services (wallet address format, amount > 0, etc.)
- No centralized validator; each feature validates its inputs

**Authentication:**
- Approach: N/A for this wallet (no user accounts); wallets authenticated via private key/mnemonic
- SGNUS connection managed by SDK; WalletConnect (Reown) handled by reown_walletkit package

**Responsive Design:**
- Approach: LayoutBuilder + MediaQuery + GeniusBreakpoints utility
- Mobile (<768px): MobileOverlay (bottom nav), single column layout
- Tablet/Desktop (>768px): DesktopOverlay (side nav or top nav), multi-column grid

---

*Architecture analysis: 2026-07-15*
