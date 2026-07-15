<!-- refreshed: 2026-07-15 -->
# Codebase Structure

**Analysis Date:** 2026-07-15

## Directory Layout

```
GeniusWallet/
├── lib/                                 # Main Flutter app code
│   ├── main.dart                        # App entry point, Sentry init, providers
│   ├── account/                         # SDK account management UI
│   │   ├── account_dropdown_selector.dart
│   │   └── sdk_account_manager.dart
│   ├── assets/                          # Asset loading utilities
│   │   └── read_asset.dart             # Load JSON from assets/
│   ├── banxa/                           # Banxa fiat buy integration
│   │   ├── banxa_model.dart            # Order, Payment models
│   │   ├── banxa_api_services.dart     # API client wrapper
│   │   ├── banxa_order/
│   │   │   ├── banxa_order_cubit.dart
│   │   │   ├── banxa_order_state.dart
│   │   │   ├── create_order_cubit.dart
│   │   │   └── polling_order_cubit.dart
│   │   ├── banxa_components/           # Banxa-specific UI widgets
│   │   ├── banxa_helpers/              # OrderService, DeepLinkService
│   │   ├── user_kyc/                   # KYC registration
│   │   ├── banxa_orders_history.dart   # Order list screen
│   │   ├── banxa_payment.dart          # WebView checkout
│   │   └── checkout_qr.dart            # QR code display
│   ├── bloc/                            # App-wide state
│   │   ├── app_bloc.dart               # Main BLoC (SDK, wallets, SGNUS)
│   │   ├── app_event.dart              # Events
│   │   └── app_state.dart              # State + AppStatus enum
│   ├── chart/                           # Chart components
│   │   └── crypto_live_chart.dart      # FL Chart integration
│   ├── components/                      # Shared UI components
│   │   ├── animation/                  # Animations (fade, slide)
│   │   ├── bottom_drawer/              # Slide-up drawer
│   │   ├── button/                     # Button variants (CTA, secondary)
│   │   ├── coins/                      # Coin/token list widget
│   │   ├── custom/                     # Custom builders (FutureBuilder)
│   │   ├── job/                        # Job submission UI
│   │   ├── overlay/
│   │   │   ├── responsive_overlay.dart # MobileOverlay, DesktopOverlay
│   │   │   └── (internal layout helpers)
│   │   ├── qr/                         # QR code generator
│   │   ├── scaffold/                   # Custom scaffold/appbar
│   │   ├── sgnus/                      # SGNUS token components
│   │   ├── toast/                      # Toast notifications
│   │   ├── loading.dart                # Loading spinner
│   │   ├── wallet_overview.dart        # Balance display
│   │   └── (other UI primitives)
│   ├── dashboard/                       # Dashboard & related screens
│   │   ├── home/
│   │   │   └── view/dashboard_screen.dart # Main dashboard
│   │   ├── bridge/
│   │   │   └── bridge_screen.dart      # Token bridge interface
│   │   ├── chart/
│   │   │   ├── markets_screen.dart     # CoinGecko market data
│   │   │   └── dashboard_markets.dart  # Market charts
│   │   ├── gnus/
│   │   │   └── cubit/gnus_cubit.dart   # GNUS token logic
│   │   ├── news/
│   │   │   └── view/crypto_news_screen.dart # Crypto news feed
│   │   ├── transactions/
│   │   │   ├── cubit/transactions_cubit.dart
│   │   │   ├── transactions_screen.dart
│   │   │   └── (tx list, filters, details)
│   ├── hive/                            # Local persistence
│   │   ├── init.dart                   # Hive box initialization
│   │   ├── constants/cache.dart        # Box names, keys
│   │   ├── models/
│   │   │   ├── coin_gecko_coin.dart
│   │   │   ├── coin_gecko_market_data.dart
│   │   │   ├── historical_price_cache_entry.dart
│   │   │   └── news_article.dart
│   │   └── services/
│   │       └── transaction_storage_service.dart
│   ├── logs/
│   │   └── submit_logs_screen.dart     # Logs submission for debugging
│   ├── navigation/
│   │   ├── router.dart                 # GoRouter definition, routes
│   │   └── web_view_extras.dart        # Web view configuration
│   ├── network/
│   │   └── network_page.dart           # Network status/selection
│   ├── onboarding/                      # Wallet creation & import flow
│   │   ├── bloc/new_pin_cubit.dart     # PIN setup
│   │   ├── new_wallet/
│   │   │   ├── bloc/new_wallet_bloc.dart
│   │   │   ├── view/
│   │   │   │   ├── backup_phrase_screen.dart
│   │   │   │   ├── recovery_phrase_screen.dart
│   │   │   │   └── verify_recovery_phrase_screen.dart
│   │   │   └── routes/new_wallet_flow.dart
│   │   ├── existing_wallet/
│   │   │   ├── bloc/existing_wallet_bloc.dart
│   │   │   ├── view/
│   │   │   │   ├── select_wallet_type_screen.dart
│   │   │   │   └── import_security_screen.dart
│   │   │   └── routes/existing_wallet_flow.dart
│   │   ├── view/wallet_creation_screen.dart # Entry screen
│   │   ├── routes/wallet_routes.dart       # Route definitions
│   │   └── widgets/                        # Reusable onboarding components
│   ├── providers/                       # App-wide data providers
│   │   ├── network_provider.dart       # ChangeNotifier (networks)
│   │   └── network_tokens_provider.dart # ChangeNotifier (tokens per network)
│   ├── reown/                           # WalletConnect integration
│   │   ├── reown_connect_button.dart   # Connect button
│   │   └── test/                        # Test utilities
│   ├── screens/                         # Top-level screens
│   │   ├── splash.dart                 # Splash screen
│   │   ├── loading_screen.dart         # Loading state
│   │   ├── pin_screen.dart             # PIN entry
│   │   ├── banxa_buy_screen.dart       # Banxa form
│   │   └── order_details_page.dart     # Order status display
│   ├── services/                        # External API clients
│   │   ├── coin_gecko/
│   │   │   └── coin_gecko_api.dart     # Market data fetching
│   │   ├── coin_telegraph/             # News aggregator
│   │   └── coins_service.dart          # Coin utility methods
│   ├── settings/
│   │   └── settings_screen.dart        # App settings UI
│   ├── squid_router/                    # Squid Protocol swaps
│   │   ├── swap_screen.dart            # Swap interface
│   │   ├── models/                     # Swap data models
│   │   └── (swap logic)
│   ├── submit_job/                      # Job submission (SGNUS compute)
│   │   ├── cubit/submit_job_cubit.dart
│   │   └── view/submit_job_screen.dart
│   ├── test/                            # Dev utilities
│   │   ├── dev_overrides.dart          # Mock data (test mode)
│   │   └── dev_tools_widget.dart       # Debug panel
│   ├── theme/                           # Design system
│   │   ├── theme.dart                  # MaterialTheme definition
│   │   ├── genius_wallet_colors.dart   # Color palette
│   │   ├── genius_wallet_consts.dart   # Padding, sizes, durations
│   │   └── genius_wallet_gradient.dart # Gradient definitions
│   ├── tokens/                          # Token info screen
│   │   └── token_info_screen.dart
│   ├── tokeninfo/                       # Token information
│   │   └── (token detail views)
│   ├── utils/                           # Utility functions
│   │   ├── breakpoints.dart            # Responsive layout helpers
│   │   ├── formatters.dart             # Number, date formatting
│   │   ├── image_utils.dart            # Image loading helpers
│   │   └── wallet_utils.dart           # Wallet address helpers
│   ├── wallets/                         # Wallet management
│   │   └── cubit/
│   │       ├── wallet_details_cubit.dart
│   │       └── wallet_details_state.dart
│   └── web/                             # Web-specific features
│       ├── web_view_screen.dart        # In-app browser
│       ├── windows_webview_shutdown.dart # Cleanup on exit
│       └── (platform-specific web logic)
│
├── packages/                            # Local path dependencies
│   ├── genius_api/                      # Core API abstraction (monorepo)
│   │   ├── lib/
│   │   │   ├── genius_api.dart         # Public exports
│   │   │   ├── src/genius_api.dart     # Main GeniusApi class
│   │   │   ├── ffi/
│   │   │   │   ├── genius_api_ffi.dart # FFI bindings to GeniusSDK
│   │   │   │   └── trust_wallet_api_ffi.dart # Trust Wallet FFI
│   │   │   ├── models/
│   │   │   │   ├── wallet.dart
│   │   │   │   ├── coin.dart
│   │   │   │   ├── network.dart
│   │   │   │   ├── account.dart
│   │   │   │   ├── sgnus_connection.dart
│   │   │   │   └── models.dart (exports)
│   │   │   ├── controllers/
│   │   │   │   ├── sgnus_connection_controller.dart
│   │   │   │   └── sgnus_transactions_controller.dart
│   │   │   ├── web3/
│   │   │   │   ├── web3.dart           # web3dart wrapper
│   │   │   │   └── api_response.dart   # Response modeling
│   │   │   ├── types/
│   │   │   │   ├── wallet_type.dart
│   │   │   │   ├── security_type.dart
│   │   │   │   └── (other enums/types)
│   │   │   ├── extensions/             # Dart extensions
│   │   │   ├── proto/                  # Protobuf-generated files
│   │   │   │   └── SGTransaction.pb.dart
│   │   │   ├── tw/                     # Trust Wallet FFI utilities
│   │   │   │   ├── hd_wallet.dart
│   │   │   │   ├── stored_key.dart
│   │   │   │   ├── any_address.dart
│   │   │   │   └── coin_util.dart
│   │   │   ├── ffi_bridge_prebuilt.dart # Binary coordination
│   │   │   ├── test/dev_overrides.dart # Test data
│   │   │   └── (other utilities)
│   │   ├── pubspec.yaml
│   │   └── (other package files)
│   │
│   └── local_secure_storage/            # Secure key-value storage (monorepo)
│       ├── lib/
│       │   ├── local_secure_storage.dart # Public exports
│       │   ├── src/
│       │   │   └── local_secure_storage.dart # Main class
│       │   └── (platform implementations)
│       └── pubspec.yaml
│
├── assets/                              # Static assets
│   ├── fonts/                           # Custom fonts
│   ├── images/                          # PNG, SVG images
│   │   └── crypto/                      # Cryptocurrency icons
│   └── json/
│       ├── networks/                    # Network configuration JSON
│       └── tokens/                      # Token list JSON
│
├── android/                             # Android platform code
│   ├── app/
│   │   └── src/
│   │       ├── debug/
│   │       ├── main/
│   │       │   ├── kotlin/ (or java/)   # Kotlin/Java platform glue
│   │       │   └── AndroidManifest.xml
│   │       └── profile/
│   └── build.gradle
│
├── ios/                                 # iOS platform code
│   ├── Runner/
│   │   ├── Info.plist
│   │   ├── GeneratedPluginRegistrant.swift
│   │   └── (other iOS files)
│   ├── native/                          # Custom iOS code
│   └── Runner.xcodeproj/
│
├── windows/                             # Windows platform code
│   ├── runner/
│   │   └── (Windows C++ entry)
│   └── (Windows project files)
│
├── macos/                               # macOS platform code
│   └── (macOS project files)
│
├── web/                                 # Web platform code
│   ├── index.html
│   └── (web assets)
│
├── linux/                               # Linux platform code
│   └── (Linux build files)
│
├── test/                                # Flutter unit/widget tests
│   └── (test files)
│
├── pubspec.yaml                         # Main project dependencies
├── pubspec.lock                         # Lockfile
├── analysis_options.yaml                # Dart linter config
├── CLAUDE.md                            # Project instructions
├── .sentry-native/                      # Sentry native SDK (generated)
└── (other root files: .gitignore, README, etc.)
```

## Directory Purposes

**lib/** - All Dart/Flutter source code (main app)

**lib/bloc/** - App-wide state management (AppBloc) coordinating SDK init, wallets, SGNUS stream

**lib/banxa/** - Fiat on-ramp feature (Banxa API integration, order lifecycle, KYC)

**lib/components/** - Shared, reusable UI widgets (buttons, overlays, QR, toast)

**lib/dashboard/** - Home screen and related modules (markets, news, transactions, bridges)

**lib/hive/** - Local NoSQL persistence (Hive models, box initialization, cache keys)

**lib/navigation/** - Navigation routing with GoRouter, deep link handling, route guards

**lib/onboarding/** - Wallet creation & import flows (new wallet, existing wallet import)

**lib/providers/** - App-wide data providers (ChangeNotifier) for networks and tokens

**lib/services/** - External API integrations (CoinGecko, Banxa, news, coin utilities)

**lib/squid_router/** - Token swap interface (Squid Protocol integration)

**lib/theme/** - Design system (colors, gradients, sizes, responsive breakpoints)

**lib/utils/** - Utility functions (formatters, image utils, wallet helpers)

**lib/wallets/** - Wallet selection & details state management (WalletDetailsCubit)

**packages/genius_api/** - Local path package: GeniusApi facade, FFI bindings, models, controllers

**packages/local_secure_storage/** - Local path package: secure wallet key storage (platform-specific)

**assets/json/** - Network and token metadata (loaded by providers)

**android/, ios/, windows/, macos/, linux/, web/** - Platform-specific code and build configs

## Key File Locations

**Entry Points:**
- `lib/main.dart` - App bootstrap, Sentry init, provider setup
- `lib/navigation/router.dart` - All route definitions via GoRouter
- `lib/onboarding/routes/wallet_routes.dart` - Onboarding subroutes

**Configuration:**
- `pubspec.yaml` - Dependencies, assets
- `analysis_options.yaml` - Dart lint rules
- `lib/theme/` - Design tokens
- `assets/json/networks/`, `assets/json/tokens/` - Blockchain metadata

**Core Logic:**
- `packages/genius_api/lib/src/genius_api.dart` - Main API facade
- `lib/bloc/app_bloc.dart` - App state orchestration
- `lib/hive/init.dart` - Database initialization
- `lib/providers/` - Global data loaders

**Testing & Dev:**
- `lib/test/dev_overrides.dart` - Mock wallet data
- `lib/test/dev_tools_widget.dart` - Debug panel (kDebugMode only)
- `test/` - Unit/widget test files

## Naming Conventions

**Files:**
- `*_screen.dart` - Full-page view (StatelessWidget or StatefulWidget)
- `*_cubit.dart` - Cubit state manager (single method, copyWith state)
- `*_bloc.dart` - BLoC state manager (multiple events)
- `*_state.dart` - State class (partner to cubit/bloc)
- `*_model.dart` - Data model (Equatable or freezed)
- `*_provider.dart` - ChangeNotifier provider
- `*_widget.dart` - Reusable component (not a full screen)
- `*_controller.dart` - Stream/service controller (RxDart, StreamController)
- `*_service.dart` or `*_client.dart` - External API wrapper
- `*_helper.dart` or `*_util.dart` - Utility functions

**Directories:**
- `*/view/` - View layer (screens, layouts)
- `*/cubit/` or `*/bloc/` - State management
- `*/routes/` - Navigation routes and flows
- `*/models/` - Data models
- `*/widgets/` - Reusable UI components
- `*/services/` or `*/api/` - External integrations

**Dart Classes:**
- `CamelCase` for class names (ScreenName, CubitName, Widget)
- `camelCase` for functions and variables
- `UPPER_SNAKE_CASE` for constants (but rarely used; prefer static const)
- Avoid single-letter names except loop iterators

**Routes (GoRouter):**
- `/` - Splash
- `/dashboard`, `/transactions`, `/swap`, `/markets`, `/news`, `/web`, `/logs`, `/settings` - Main shell routes
- `/landing_screen`, `/backup_phrase`, `/recovery_phrase`, `/verify_recovery_phrase`, `/import_wallet`, `/import_existing_wallet`, `/create_wallet` - Onboarding routes
- `/buy`, `/createOrder`, `/orderDetails`, `/checkout`, `/checkoutQR`, `/kyc`, `/banxa/callback` - Banxa routes
- `/token-info`, `/bridge`, `/submit_job`, `/network` - Feature routes

## Where to Add New Code

**New Feature (e.g., Staking):**
- Primary code: `lib/staking/` (mirror structure: cubit, view, models, routes)
- Cubit: `lib/staking/cubit/staking_cubit.dart`, `staking_state.dart`
- Screens: `lib/staking/view/staking_screen.dart`, `staking_details_screen.dart`
- Routes: `lib/staking/routes/staking_routes.dart`, add to `lib/navigation/router.dart`
- Models: `lib/staking/models/stake.dart`, `reward.dart`
- State: Add to AppBloc or create top-level cubit injected in router

**New Component/Widget:**
- Implementation: `lib/components/{category}/` (e.g., `lib/components/card/stake_card.dart`)
- Reusable? → `lib/components/`; Feature-specific? → `lib/{feature}/widgets/`
- Always use StatelessWidget unless state needed; prefer Cubit for logic

**Utilities:**
- Shared helpers: `lib/utils/{category}.dart` (e.g., `utils/date_format.dart`)
- Feature-specific helpers: `lib/{feature}/helpers/` or `lib/{feature}/{category}_helper.dart`

**Service/API Client:**
- External integrations: `lib/services/{service_name}/` (e.g., `lib/services/coingecko/`)
- API wrapper: `lib/services/{service_name}/{service_name}_api.dart` or `{service_name}_client.dart`
- Models: `lib/services/{service_name}/models/`

**Database Model:**
- Hive models: `lib/hive/models/{entity}.dart` (use @HiveType annotation)
- Register in `lib/hive/init.dart` before Hive.openBox()
- Reference in cache.dart constants

**BLoC/Cubit:**
- Feature cubit: `lib/{feature}/cubit/{feature}_cubit.dart`
- App-wide bloc: `lib/bloc/app_bloc.dart` (only this one, no others at top level)
- Always split event/state into separate part files or imports

**Test:**
- Widget tests: `test/{feature}_test.dart` or `test/{feature}/screen_test.dart`
- Mock dependencies via package:mockito
- Run: `flutter test`

## Special Directories

**lib/test/ (not test/):**
- Purpose: Dev-mode overrides and debug tools
- Generated: No (manually maintained)
- Committed: Yes (controlled via kDebugMode conditionals)

**lib/hive/:**
- Purpose: Hive box definitions and schemas
- Generated: models.g.dart (auto-generated by hive_generator, run `flutter pub run build_runner build`)
- Committed: models.dart and init.dart; excluded: *.g.dart (or committed, varies by project)

**packages/**
- Purpose: Local monorepo packages (shared libraries)
- Generated: No
- Committed: Yes (part of source tree)

**assets/json/:**
- Purpose: Blockchain and token metadata (networks, tokens)
- Generated: No (manually maintained or fetched externally)
- Committed: Yes

**build/, .dart_tool/, pubspec.lock:**
- Purpose: Build artifacts and dependency cache
- Generated: Yes
- Committed: pubspec.lock only (not build/ or .dart_tool/)

---

*Structure analysis: 2026-07-15*
