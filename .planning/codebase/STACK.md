# Technology Stack

**Analysis Date:** 2026-07-15

## Languages

**Primary:**
- Dart 3.10.0+ - All Flutter application logic, BLoC state management, service layer
- C++ - GeniusSDK native bindings via FFI (Windows/Linux desktop integration)

**Secondary:**
- CMake - Windows native build configuration

## Runtime

**Environment:**
- Flutter 3.x (revision e3c29ec00c9c825c891d75054c63fcc46454dca1 on stable channel)
- Dart SDK ^3.10.0

**Package Manager:**
- Pub (Dart/Flutter package manager)
- Lockfile: `pubspec.lock` present

## Frameworks

**Core:**
- Flutter 3.x - Cross-platform UI framework (Windows, macOS, Linux, iOS, Android, Web)

**State Management:**
- flutter_bloc 9.1.1 - BLoC pattern for state management via cubits and blocs
  - Location: `lib/bloc/`, `lib/wallets/cubit/`, `lib/banxa/banxa_order/`, `lib/dashboard/transactions/cubit/`
  - bloc_concurrency 0.3.0 - Concurrency handling for bloc events

**Navigation:**
- go_router 17.2.2 - Declarative routing system
  - Location: `lib/navigation/router.dart`

**Serialization:**
- json_serializable 6.8.0 - JSON code generation for models
- freezed 3.2.3 - Immutable model generation with union types
- build_runner 2.4.9 - Code generation orchestrator

**UI Components:**
- auto_size_text 3.0.0 - Responsive text sizing
- flutter_svg 2.0.17 - SVG rendering
- font_awesome_flutter 11.0.0 - Icon library
- fl_chart 1.2.0 - Chart visualization
- flutter_staggered_grid_view 0.7.0 - Staggered grid layouts
- qr_flutter 4.1.0 - QR code generation
- loading_animation_widget 1.3.0 - Loading indicators
- pin_code_fields 9.3.0 - PIN/code input UI
- cached_network_image 3.4.1 - Optimized image loading
- clipboard 3.0.14 - Clipboard operations

**Dependency Injection:**
- provider 6.1.2 - Service locator and state provider pattern

**Local Storage:**
- hive_ce 2.19.3 - Local NoSQL database for caching
- hive_ce_flutter 2.3.4 - Flutter integration
- hive_ce_generator 1.10.0 - Adapter code generation (dev)

**HTTP & Networking:**
- http 1.2.2 - HTTP client for API requests
- connectivity_plus 7.0.0 - Network connectivity detection

**Web Integration:**
- webview_flutter 4.1.0 - Embedded WebView (mobile/web)
- webview_windows 0.4.0 - WebView for Windows desktop
- app_links 7.0.0 - Deep linking support
- url_launcher 6.1.6 - URL/link launching

**Blockchain & Cryptography:**
- web3dart 3.0.0 - EVM interaction (Ethereum, Polygon, BSC, etc.)
- crypto 3.0.6 - Cryptographic functions (HMAC, SHA-256, etc.)
- wallet 0.0.13 - Wallet utilities (from Reown)

**Reactive Programming:**
- rxdart 0.27.7 - Reactive extensions for Dart

**Device & Platform:**
- window_manager 0.5.1 - Window management (desktop)
- path_provider 2.1.6 - Application directory paths
- file_picker 11.0.2 - File selection dialogs
- permission_handler 12.0.1 - Runtime permission requests
- device_preview 1.2.0 - Device preview for UI testing

**Error Tracking & Monitoring:**
- sentry_flutter 9.0.0 - Error reporting and performance monitoring

**Utilities:**
- equatable 2.0.5 - Value equality for models
- timeago 3.7.0 - Relative time formatting (e.g., "2 hours ago")
- intl 0.20.2 - Internationalization and formatting
- html_unescape 2.0.0 - HTML entity decoding
- xml 6.5.0 - XML parsing
- protobuf 6.0.0 - Protocol Buffer support
- convert 3.1.1 - Data format conversions
- ffi 2.0.1 - Foreign Function Interface for native bindings

**Screenshots & Testing:**
- screenshot 3.0.0 - Screenshot capture for testing

## Testing

**Framework:**
- test 1.24.1 - Dart testing framework
- flutter_test (SDK) - Flutter widget testing

**Mocking:**
- mockito 5.0.0 - Mocking library for tests

**Linting:**
- flutter_lints 6.0.0 - Flutter lint rules
- lints 6.1.0 - Dart lint rules

## Code Generation

**Tools:**
- ffigen 20.1.1 - FFI binding generator (generates Dart FFI from C headers)
- json_serializable 6.8.0 - Generates `.g.dart` files for JSON serialization
- hive_ce_generator 1.10.0 - Generates Hive adapter code for type adapters

**Configuration:**
- `analysis_options.yaml` - Excludes generated files (`*.g.dart`, `*.freezed.dart`)
- Location: `C:\Users\User\Documents\Projects\GNUS\GeniusWallet\analysis_options.yaml`

## Build System

**Desktop (Windows):**
- CMake 3.18+ - Windows native build orchestration
  - Location: `windows/CMakeLists.txt`
  - Supports Debug, Profile, Release configurations
  - MSVC runtime configuration
  - Multi-config generator support

**Build Tools:**
- build_runner 2.4.9 - Code generation and watch mode
- flutter build (Flutter SDK commands)

## Platform Targets

**Development:**
- Windows (primary desktop development target)
- macOS (supported)
- Linux x86_64 & aarch64 (supported)

**Runtime Deployment:**
- Windows - Native exe via CMake
- macOS - .pkg installer
- Linux x86_64 - x86 builds (tested on Ubuntu 22+)
- Linux aarch64 - ARM64 builds (tested on Debian Bullseye, Ubuntu 22+)
- iOS - App distribution via TestFlight
- Android - APK releases
- Web - Web platform supported

## Configuration

**Environment:**
- Flutter channel: `stable`
- SDK constraint: `"^3.10.0"` (pubspec.yaml)
- Min Flutter version: 3.10.0

**Build Configuration Files:**
- `pubspec.yaml` - Main dependencies and app metadata
- `packages/genius_api/pubspec.yaml` - FFI package dependencies
- `packages/local_secure_storage/pubspec.yaml` - Secure storage wrapper
- `windows/CMakeLists.txt` - Windows native build config
- `analysis_options.yaml` - Linting and analyzer configuration
- `.metadata` - Flutter project metadata and platform tracking

**Asset Configuration:**
- `assets/json/networks/networks.json` - Network/blockchain configuration
- `assets/json/networks/bridge.json` - Bridge configuration
- `assets/json/tokens/` - Token definitions
- `assets/network_config.json` - P2P/IPFS bootstrap nodes
- `assets/log_config.json` - Logging configuration
- `assets/dev_config.json` - Development configuration
- `assets/crdt_config.json` - CRDT (Conflict-free Replicated Data Type) config
- `assets/sgns_config.json` - SGNUS (Genius SDK) configuration

**Font Configuration:**
- Custom font: JetBrainsMono (Regular, Italic, Bold, ExtraBold variants)
  - Location: `assets/fonts/JetBrainsMono-*.ttf`

---

*Stack analysis: 2026-07-15*
