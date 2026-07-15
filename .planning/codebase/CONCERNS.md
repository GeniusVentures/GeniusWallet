# Codebase Concerns

**Analysis Date:** 2026-07-15

## Tech Debt

### Hardcoded Bridge Configuration

**Issue:** Bridge destination chain ID hardcoded in two locations
- Files: `lib/submit_job/cubit/submit_job_cubit.dart` (lines 142, 189)
- Impact: Cannot support multiple bridge destinations; requires code change for network updates
- Fix approach: Move to configurable network settings from `selectedNetwork` or a bridge config service
- Severity: HIGH - Blocks multi-chain bridge support

### Event Parameter Refactoring Needed

**Issue:** `WalletSecurityEntered` event has 5 separate parameters that should be grouped
- Files: `lib/onboarding/existing_wallet/bloc/existing_wallet_event.dart` (lines 14-32)
- Impact: Verbose API, error-prone when passing multiple params, hard to extend
- Fix approach: Create a single `SecurityConfig` or `ImportConfig` object
- Severity: LOW - Code maintainability issue

### Incomplete Chain/Network Configuration

**Issue:** Hardcoded chain references instead of dynamic discovery
- Files: `lib/squid_router/squid_token_service.dart` (line 85 TODO)
- Impact: Manual updates required when networks change; hardcoded asset list in `assets/networks.json`
- Fix approach: Implement dynamic chain/network discovery from API
- Severity: MEDIUM - Operational burden

## Error Handling & Logging

### Silent Exception Swallowing

**Issue:** Multiple catch blocks with underscore (_) that emit generic error states without logging root cause
- Files:
  - `lib/bloc/app_bloc.dart` (lines 154, 169, 188) - FetchAccount, CheckIfUserExists, processing timer
  - `lib/components/sgnus/sgnus_connection_widget.dart` - Silent catch
  - `lib/banxa/handle_banxa_drawer.dart` - Silent exception in transaction handling
- Impact: Debugging difficult; users see generic "error" with no context; loss of signal about actual failures
- Fix approach: Log exception message and stacktrace with `debugPrint('❌ [Context]: $e\n$st')` before emitting error state
- Severity: HIGH - Debugging and support burden

### Print Statements Instead of debugPrint

**Issue:** 26+ `print()` calls in production code instead of `debugPrint()`
- Files: Concentrated in `lib/banxa/banxa_api_services.dart` (13+ instances), also in `lib/web/web_view_mobile.dart`, `lib/tokeninfo/token_info_loader.dart`, `lib/banxa/banxa_order/create_order_cubit.dart`
- Impact: Logs persist in release builds; noise in production; potential security info leak (URLs, order details)
- Fix approach: Replace all `print(` with `debugPrint(` or use structured logging
- Severity: MEDIUM - Hygiene, potential security/performance

### TODO Comments Without Tracking

**Issue:** 11+ TODO comments scattered in code without issue tracking or priority
- Files:
  - `lib/squid_router/squid_token_service.dart:85` - Add chains dynamically
  - `lib/squid_router/swap_screen.dart:353,365` - Invoke Squid API, record transaction
  - `lib/reown/handle_dapp_requests.dart:138,141,163,164` - Parse tx data, confirm network, show pending tx, record coin symbol
  - `lib/submit_job/cubit/submit_job_cubit.dart:142,189` - Unhardcode bridge address
  - `lib/onboarding/existing_wallet/bloc/existing_wallet_event.dart:15` - Refactor into object
  - `lib/onboarding/existing_wallet/view/select_wallet_type_screen.dart:12` - Support other networks
- Impact: Unclear priority; unclear if they block features or are nice-to-haves; no assignment
- Fix approach: Create JIRA/issue tickets or link to them in code (e.g., `// GNUS-123: Dynamic chain support`)
- Severity: MEDIUM - Process/priority

## Security Considerations

### Recovery Phrase Handling

**Issue:** Seed phrase (recovery words) kept in unencrypted BLoC state in memory; can be copied to clipboard
- Files: `lib/onboarding/new_wallet/bloc/new_wallet_state.dart`, `lib/onboarding/new_wallet/view/recovery_phrase_screen.dart` (lines 104, 125)
- Current mitigation: Visual toggle to hide/show; clipboard copy without OS confirmation
- Risk:
  - Memory dump could expose recovery words
  - Clipboard accessible by other apps on most Android versions (pre-Android 10)
  - No additional user confirmation before clipboard copy
- Recommendations:
  - Add explicit user confirmation ("Are you sure?") before copy-to-clipboard
  - Use native clipboard APIs where possible to leverage OS protections
  - Consider never exposing full phrase; use numbered grid only
  - Implement memory wiping after use (though Dart's GC makes this difficult)
- Severity: CRITICAL - Core wallet security

### Private Key Management in FFI Boundary

**Issue:** Private keys converted to hex strings for passing to native GeniusSDK via FFI
- Files: `packages/genius_api/lib/src/genius_api.dart` (lines 227-241)
- Current mitigation: String is allocated via `toNativeUtf8()` and freed via `malloc.free()`
- Risk:
  - Hex string representation in memory longer than binary form
  - String may linger in Dart's string pool
  - No cryptographic zeroization guarantee
- Recommendations:
  - Verify native FFI functions properly zeroize input buffers
  - Implement custom Uint8List zeroization helper before/after FFI calls
  - Consider Securable uint8 FFI types (if available in packages)
- Severity: HIGH - Direct key exposure vector

### JavaScript Injection in WebView

**Issue:** Hardcoded JavaScript code injected into WebView to force dark mode and remove Uniswap banner
- Files: `lib/web/web_view_mobile.dart` (lines 58-115)
- Current mitigation: Script is hardcoded; not user-provided data
- Risk:
  - If webview URL is user-controlled, could allow XSS
  - Modifying page DOM and localStorage affects Uniswap behavior
- Recommendations:
  - Validate that URL domain is whitelisted before injecting any JS
  - Consider using CSS injection or WebView platform channel instead
  - Document that this only runs on `uniswap.org`
- Severity: MEDIUM - Depends on URL source validation

### WalletConnect Request Handling

**Issue:** Hardcoded "ETH" coin symbol in WalletConnect transaction handling
- Files: `lib/reown/handle_dapp_requests.dart` (line 139, 164)
- Risk: User may approve transaction in one token but record/display as ETH
- TODO Comments also indicate:
  - Transaction data parsing not implemented (line 138)
  - Network validation not implemented (line 141)
- Fix approach: Parse `tx.data` for token contract and amount; validate chainId matches user's selected network
- Severity: HIGH - User confusion, potential loss

## Performance Bottlenecks

### Aggressive Polling Intervals

**Issue:** 5-second polling on order status; multiple 1-minute refresh intervals
- Files:
  - `lib/banxa/banxa_order/polling_order_cubit.dart:19` - Order status polling every 5 seconds
  - `lib/chart/crypto_live_chart.dart:81` - Chart refresh every 1 minute
  - `lib/components/coins/view/coins_screen.dart:44` - Coins list refresh every 1 minute
- Impact: Battery drain on mobile; repeated API calls even if data unchanged; server load
- Improvement path:
  - Implement exponential backoff after no-change responses
  - Add user-configurable refresh rate (with default of 5+ minutes for non-critical data)
  - Use WebSocket or server-sent events for real-time updates instead of polling
  - Clear timers when screen is backgrounded
- Severity: MEDIUM - User experience, battery life

### Per-Rebuild Refetch Pattern

**Issue:** Dashboard calls `walletCubit.getCoins()` in `initState` within a `addPostFrameCallback`
- Files: `lib/dashboard/home/view/dashboard_screen.dart:35-41`
- Risk: If dashboard rebuilds for other reasons, getCoins() may be called again unnecessarily
- Fix approach: Use a `mounted` check or BLoC event deduplication; or move fetch to router redirect (already done for wallets)
- Severity: LOW - Minimal if getCoins() is already deduplicated internally

### Large UI Files

**Issue:** Single screen exceeds 726 lines
- Files: `lib/dashboard/bridge/bridge_screen.dart` (726 lines)
- Impact: Hard to navigate; multiple concerns mixed; refactoring risk
- Fix approach: Extract sub-widgets and cubits into separate files (e.g., `bridge_form.dart`, `bridge_status.dart`)
- Severity: MEDIUM - Maintainability

## Code Quality Issues

### Analyzer Blind Spots

**Issue:** `analysis_options.yaml` excludes `*.g.dart` files (generated code)
- Files: `.planning/codebase/analysis_options.yaml` (line 5)
- Impact: Broken generated widgets (e.g., `@freezed`, `@JsonSerializable`) not caught during analysis
- Risk: Type errors in generated code, incompatible API changes to generators not detected
- Recommendation: 
  - Run analyzer on `*.g.dart` files in CI only (expensive but catches generator bugs)
  - Or: Keep exclusion but ensure regeneration is part of CI before commit
- Severity: MEDIUM - Hidden bugs

### Unsafe Casts in JSON Deserialization

**Issue:** Multiple `as` casts without null-coalescing in banxa_model.dart
- Files: `lib/banxa/banxa_model.dart` (lines 264-320)
- Pattern: `json['field'] as String` will throw if field is null
- Recommendation: Use `json['field'] as String?` or `?? ''` for safety
- Severity: LOW - Mostly safe if JSON validated upstream, but fragile

### Missing Null Checks

**Issue:** Navigator.of(context) called without null check in reown request handler
- Files: `lib/reown/handle_dapp_requests.dart:108` - `navigatorKey.currentContext!`
- Risk: Will crash if router not yet initialized or context popped
- Fix: Use navigatorKey.currentContext?. and check for null before showing drawer
- Severity: MEDIUM - Runtime crash if triggered

## Fragile Areas

### WalletConnect Implementation

**Files:** `lib/reown/`

**Why fragile:**
- Multiple TODOs indicate incomplete feature gates (network validation, tx parsing, pending UI)
- Duplicate request detection via `pendingRequestIds` set is in-memory only (lost on app restart)
- No timeout for pending approvals; drawer could be left open indefinitely

**Safe modification:**
- Add request timeout (e.g., 5 min, then auto-reject)
- Persist `pendingRequestIds` to local storage
- Implement transaction data parsing in separate, testable function
- Add unit tests for request deduplication

**Test coverage:** No visible WalletConnect-specific tests in codebase

### Secure Storage Initialization

**Files:** `packages/local_secure_storage/lib/src/local_secure_storage_base.dart`

**Why fragile:**
- `init()` method iterates all keys and validates them; if there are many wallets, could hang
- Errors during `init()` are logged but not propagated; init could silently fail
- If StoredKey.importJson() throws, key is deleted without user consent

**Safe modification:**
- Wrap init in timeout (e.g., 30 sec)
- Add progress callback for large key sets
- Log deletion events explicitly
- Add recovery path if init fails

**Test coverage:** No visible tests

### FFI Bridge

**Files:** `packages/genius_api/lib/ffi_bridge_prebuilt.dart`, `lib/src/genius_api.dart`

**Why fragile:**
- `FFIBridgePrebuilt()` silently returns if DynamicLibrary.open() fails; `_ffiBridgePrebuilt.sgns_lib` will be uninitialized
- Late initialization: `_address` and `_basePath` are `late` vars; accessing before `_initSDK()` completes will throw `LateInitializationError`
- No guard against double-initialization (though `_isSdkInitialized` flag helps)

**Safe modification:**
- Throw or return error in FFIBridgePrebuilt if load fails; don't silently return
- Add safety checks before accessing late vars; use `_isSdkInitialized` guard
- Add integration tests for FFI initialization flow
- Document that `initSDK()` must be called before any FFI calls

**Test coverage:** Minimal; mostly happy-path

## Scaling Limits

### Memory Usage of in-Memory State

**Issue:** BLoC state holds lists of wallets, transactions, recovery words, all in memory
- Files: Multiple BLoCs in `lib/bloc/`, `lib/banxa/banxa_order/`, etc.
- Current capacity: Unknown; likely fine for <100 wallets/1000 transactions, but not tested
- Limit: Large transaction history (1000+) could cause OOM on low-end Android devices
- Scaling path:
  - Paginate transactions (load first 50, lazy-load on scroll)
  - Use Hive database queries instead of in-memory lists
  - Implement transaction caching strategy (only keep last N days in memory)

### API Rate Limiting

**Issue:** No visible rate-limiting or retry backoff logic
- Files: `lib/banxa/banxa_api_services.dart`, `lib/dashboard/home/`
- Risk: Banxa/Squid/external APIs could rate-limit or block on high activity
- Scaling path: Implement exponential backoff with jitter; cache responses where possible

## Missing Critical Features

### Transaction Data Parsing from WalletConnect

**Issue:** Token swap amounts and symbols not parsed from eth_sendTransaction data field
- Files: `lib/reown/handle_dapp_requests.dart:138` (TODO comment)
- Impact: User sees only amount in Wei, not token name/decimals; hardcoded "ETH" symbol
- Blocks: Proper swap confirmation UI; accurate transaction recording

### Network Validation for Swap Confirmation

**Issue:** No validation that dApp-requested network matches user's selected wallet network
- Files: `lib/reown/handle_dapp_requests.dart:141` (TODO comment)
- Impact: User could approve ETH transaction on Polygon network, leading to confusion/loss
- Blocks: Safe WalletConnect signing

### Pending Transaction UI

**Issue:** After signing WalletConnect transaction, transaction immediately marked as completed without waiting for block confirmation
- Files: `lib/reown/handle_dapp_requests.dart:165-172`
- Impact: User sees success before tx is actually included in block; could be misleading
- Fix: Use pending status and update from blockchain confirmation

## Disabled CTA Contrast Issues

**Issue:** Disabled button text/background contrast may not meet WCAG AA standards
- Files: `lib/theme/theme.dart` (lines 120-127), `lib/theme/genius_wallet_colors.dart` (line 15)
- Current: Background `Colors.grey.shade900` (very dark), foreground `colorScheme.onSurfaceVariant` (grey)
- Risk: Users with visual impairments cannot see disabled state; violates accessibility guidelines
- Fix approach:
  - Use higher contrast color for disabled foreground (lighter grey)
  - Test with contrast checker (WCAG AA requires 4.5:1 for text)
  - Consider different background for disabled state (e.g., darker surface with border)
- Severity: MEDIUM - Accessibility issue

---

*Concerns audit: 2026-07-15*
