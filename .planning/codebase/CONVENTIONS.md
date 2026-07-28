# Coding Conventions

**Analysis Date:** 2026-07-15

## Naming Patterns

**Files:**
- Snake case: `lib/bloc/pin_cubit.dart`, `lib/components/coins/view/coin_card_row.dart`
- Directory hierarchy follows feature structure: `lib/[feature]/[type]/`

**Classes/Types:**
- Pascal case: `PinCubit`, `CoinCardRow`, `NewWalletBloc`, `GeniusWalletColors`
- Widget classes: `CoinCardRow`, `CoinTableRow` (describe UI component)
- Bloc/Cubit: `PinCubit`, `NewWalletBloc`, `GnusCubit` (suffix with Bloc/Cubit)
- State classes: `PinState`, `NewWalletState` (suffix with State)
- Event classes: `RecoveryPhraseContinue`, `RecoveryWordTapped` (verb phrases)
- Enums: `PinFullness`, `VerificationStatus`, `SavePinStatus`

**Functions/Methods:**
- Camel case: `clearAll()`, `add()`, `verifyPin()`, `desktopOnChanged()`
- Private methods prefix with underscore: `_onRecoveryPhraseContinue()`, `_showAddWithMnemonicDialog()`
- Boolean getters/predicates: `pinExists()`, `noBalance` (natural language)

**Variables:**
- Camel case: `pinMaxLength`, `textController`, `displayIncorrectPin`, `pinController`
- Constants (within classes): `static const String _partnerCode = 'gnus'`
- Theme/design tokens: Static class properties in `GeniusWalletColors`, `GeniusWalletConsts`

**Imports:**
- Path aliases: None observed; uses relative imports within features

## Code Style

**Formatting:**
- Tool: No explicit tool configured (relies on IDE default + Dart formatter)
- Page width: 80 characters (set in `analysis_options.yaml`)
- Indentation: 2 spaces

**Linting:**
- Primary: `flutter_lints` ^6.0.0 (uses `package:flutter_lints/flutter.yaml`)
- Fallback: `lints` ^6.1.0
- Configuration: `analysis_options.yaml` at root; `lints/recommended.yaml` in packages
- Exclusions: Generated files excluded (`lib/**/*.g.dart`, `lib/**/*.freezed.dart`)

**Linting File Organization:**
```yaml
# Main app (analysis_options.yaml)
include: package:flutter_lints/flutter.yaml
analyzer:
  exclude:
    - lib/**/*.g.dart
    - lib/**/*.freezed.dart
    - banxa
    - squidrouter
    - packages/genius_api/lib/proto
formatter:
  page_width: 80

# Packages (genius_api/analysis_options.yaml)
include: package:lints/recommended.yaml
formatter:
  page_width: 80
```

**Ignore Comments:**
- Used where needed: `// ignore_for_file: avoid_print`
- Lint suppressions: `// ignore: unused_element`

## Import Organization

**Order:**
1. Dart standard library: `import 'dart:async'`, `import 'dart:convert'`
2. Flutter framework: `import 'package:flutter/material.dart'`
3. External packages: `import 'package:flutter_bloc/flutter_bloc.dart'`
4. Local packages (monorepo): `import 'package:genius_api/genius_api.dart'`
5. Local project imports: `import 'package:genius_wallet/bloc/pin_state.dart'`

**Example:**
```dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';

import 'package:genius_wallet/bloc/pin_state.dart';
import 'package:genius_wallet/utils/image_utils.dart';
```

## Error Handling

**Patterns:**
- **Try/catch with underscore:** Catch unused exceptions with `_` variable name
  ```dart
  try {
    final account = await api.getAccount();
    emit(state.copyWith(accountStatus: AppStatus.loaded, account: account));
  } catch (_) {
    emit(state.copyWith(accountStatus: AppStatus.error));
  }
  ```

- **Explicit exception throwing:**
  ```dart
  if ((fiatAmount == null || fiatAmount.isEmpty) &&
      (cryptoAmount == null || cryptoAmount.isEmpty)) {
    throw ArgumentError('Either fiatAmount or cryptoAmount must be provided.');
  }
  ```

- **Null returns for recoverable errors:**
  ```dart
  try {
    final response = await http.post(url, headers: _headers, body: jsonEncode(kycData));
    if (response.statusCode == 200) {
      return BanxaKycResponse.fromJson(jsonDecode(response.body));
    } else {
      print('Banxa KYC failed: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Banxa KYC error: $e');
    return null;
  }
  ```

**Error Reporting:** Sentry integration at app level (`lib/main.dart`). Errors logged via `debugPrint()` for debug builds, print() for API errors.

## Logging

**Framework:** 
- `debugPrint()` for debug output (shown only in debug builds)
- `print()` for API/service errors (rare, used in `BanxaApiService`)

**Patterns:**
- Debug output with emoji prefixes:
  ```dart
  debugPrint('⚠️ Error fetching native token for ${network.name}: $e');
  debugPrint('❌ Could not find token ${tokenContract.name}, skipping');
  debugPrint('🧭 Received deep link: $uri');
  debugPrint('📍 Navigating to: $fullPath');
  ```

**When to log:**
- Errors in services/repositories
- Entry/exit points of critical operations (deep links, navigation)
- State transitions (rarely necessary in bloc)

**Sentry:** Error tracking via `sentry_flutter` ^9.0.0, configured in `main()` with custom `beforeSend` filter.

## Comments

**When to Comment:**
- Non-obvious algorithm or state logic
- Workarounds or temporary fixes
- Integration points with external systems

**JSDoc/TSDoc Pattern:**
- Use `///` for doc comments on public APIs
- Single `//` for inline explanations
- Rare in event/state classes; used in API/business logic

**Example:**
```dart
/// Verifies [pin] with the user-set pin
Future<void> verifyPin() async {
  final pin = _textController.text;
  final isVerified = await geniusApi.verifyUserPin(pin);
  
  if (isVerified) {
    emit(state.copyWith(verificationStatus: VerificationStatus.pass));
  } else {
    pinConfirmFailed();
  }
}

/// Event thrown when the user acknowledges the recovery phrase they received
class RecoveryVerificationContinue extends NewWalletEvent {}
```

## Function Design

**Size:** Keep functions under 50 lines; extract private helpers for complex logic.

**Parameters:** 
- Named parameters: `final TextEditingController _textController => state.pinController.textController;`
- Use `required` keyword for mandatory params
- Default values for optional params

**Return Values:**
- Future-based for async operations: `Future<void>`, `Future<BanxaKycResponse?>`
- Sync operations: Direct returns or null
- Bloc event handlers: void (use emit for state changes)

**Example from `PinCubit`:**
```dart
class PinCubit extends Cubit<PinState> {
  final int pinMaxLength;
  final GeniusApi geniusApi;
  
  PinCubit({required this.pinMaxLength, required this.geniusApi})
    : super(PinState(pinController: PinInputController()));

  void clearAll() {
    _textController.clear();
    emit(state.copyWith(
      pinController: state.pinController,
      pinFullness: PinFullness.inProgress,
    ));
  }
}
```

## Module Design

**Exports:** 
- Barrel files not consistently used; direct imports preferred
- Example: `import 'package:genius_api/genius_api.dart'` for package-level exports

**Bloc/Cubit Organization:**
- Event, State, Bloc in separate files or as `part` of bloc file
- Pattern in `NewWalletBloc`:
  ```dart
  // new_wallet_bloc.dart
  part 'new_wallet_event.dart';
  part 'new_wallet_state.dart';
  
  class NewWalletBloc extends Bloc<NewWalletEvent, NewWalletState> {
    // ...
  }
  ```

**State/Cubit Immutability:**
- Use `copyWith()` for state immutability
- States extend `Equatable` for value equality
- Example:
  ```dart
  class PinState {
    final PinInputController pinController;
    final bool displayIncorrectPin;
    
    PinState copyWith({
      PinInputController? pinController,
      bool? displayIncorrectPin,
    }) {
      return PinState(
        pinController: pinController ?? this.pinController,
        displayIncorrectPin: displayIncorrectPin ?? this.displayIncorrectPin,
      );
    }
  }
  ```

## Serialization & Generated Code

**Hive (Local Storage):**
- Decorator: `@HiveType(typeId: 0)`
- Fields: `@HiveField(0)` with type ID
- Manual serialization: `fromJson()` factory and `toJson()` method
- Example:
  ```dart
  @HiveType(typeId: 0)
  class CoinGeckoCoin {
    @HiveField(0)
    final String id;
    
    factory CoinGeckoCoin.fromJson(Map<String, dynamic> json) => CoinGeckoCoin(
      id: json['id'] ?? '',
    );
    
    Map<String, dynamic> toJson() => {'id': id};
  }
  ```

**Freezed (Immutable Models):**
- Used in `packages/genius_api` for API models
- Decorator: `@freezed` with `abstract class Model with _$Model`
- Auto-generates `fromJson()` and `toJson()`
- Example:
  ```dart
  @freezed
  abstract class Coin with _$Coin {
    const factory Coin({
      String? name,
      String? symbol,
      String? address,
    }) = _Coin;
    
    factory Coin.fromJson(Map<String, Object?> json) => _$CoinFromJson(json);
  }
  ```

**FFI Bindings (Native Code):**
- Generated by `ffigen` ^20.1.1
- File: `packages/genius_api/lib/ffi/genius_api_ffi.dart`
- Pattern: Auto-generated, do not edit manually
- Comments: Preserve C function documentation as-is
- Example binding:
  ```dart
  // AUTO GENERATED FILE, DO NOT EDIT.
  // Generated by `package:ffigen`.
  ffi.Pointer<ffi.Char> GeniusSDKInit(
    ffi.Pointer<ffi.Char> base_path,
    ffi.Pointer<ffi.Char> dev_config,
  ) {
    return _GeniusSDKInit(base_path, dev_config);
  }
  ```

## Router Patterns

**GoRouter Configuration:**
- Location: `lib/navigation/router.dart`
- Route definition: `GoRoute(path: '/path', builder: (context, state) => Widget())`
- Extra data passing: `state.extra as Map<String, dynamic>?`
- Redirect guards: Checked in router's `redirect` callback

**Example:**
```dart
final geniusWalletRouter = GoRouter(
  navigatorKey: navigatorKey,
  redirect: (context, state) {
    final appBloc = context.read<AppBloc>();
    if (appBloc.state.sdkStatus == AppStatus.initial) {
      appBloc.add(InitializeSDK());
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Splash(),
    ),
  ],
);
```

## Theme & Design Tokens

**Location:** `lib/theme/` 
- `genius_wallet_colors.dart`: Color constants
- `genius_wallet_consts.dart`: Size, padding constants (likely)
- `genius_wallet_gradient.dart`: Gradient definitions

**Pattern:**
```dart
class GeniusWalletColors {
  static const Color lightGreenPrimary = Colors.greenAccent;
  static const Color deepBlueTertiary = Color(0xff05090F);
  
  static Color btnFilterSelected = lightGreenPrimary.withValues(alpha: 0.1);
}
```

**Usage:** Access via class properties (`GeniusWalletColors.lightGreenPrimary`) or Material ColorScheme from `Theme.of(context).colorScheme`.

### Control track (segmented control / filter bar)

<!-- HAND-WRITTEN 2026-07-26. Not produced by /gsd-map-codebase. Preserve on regeneration. -->

A control track is the pill-shaped container holding a row of small chips (a segmented
control or a filter bar). Two exist today. The recipe is fixed - partial adoption reads as a
different design language on the same screen:

| Part | Value |
|------|-------|
| Fill | `gw.surfaceSunken` |
| Border | `Border.all(color: gw.borderSubtle)` (hairline) |
| Radius | `GeniusWalletConsts.radiusPill` |
| Track padding | `EdgeInsets.all(3)` |
| Gap between chips | `SizedBox(width: 2)` |

**Why sunken, not the raised-chip `surfaceMenu`.** Measured this session in dark mode, real
hex values from `lib/theme/genius_wallet_colors.dart`: panel fill `surfaceElevated` is
`#0C0E14`; `surfaceMenu` `#171A21` sits about 1.11:1 above it; `surfaceSunken` `#06080C` sits
about 1.10:1 below it. The fill step itself is not what makes the control visible - the
hairline border is. `surfaceSunken` was chosen so the panel stays the brightest plane and the
control reads as a recessed well rather than a raised chip. This only became legible after
`GWDecorations._surfaceSheenDark` was flattened this session from a `#181B24` → `#0C0E14`
gradient into a flat `#0C0E14`, matching the Swap tab's boxes. Light mode's sunken step
(`#FFFFFF` panel vs `#CFD4DB` track) is a much larger, already-visible step; any light-only
follow-up belongs to the deferred app-wide light pass, not here.

**Pairing rule.** `lib/dashboard/home/view/dashboard_screen.dart` (`_TimeframeSegment`) and
`lib/dashboard/home/widgets/transactions_slim_view.dart` (`_TransactionFilterBar`) are
deliberately identical in geometry and CHANGE TOGETHER. They already drifted once (pill vs
radiusMd, 3 vs 4 padding) and briefly read as two design languages on one screen; timeframe is
the approved shape (sketch 006/008), so the filter bar follows it, never the reverse. The full
history is written at `transactions_slim_view.dart:601-606`.


*Convention analysis: 2026-07-15*
*CTA weight section added 2026-07-27, removed 2026-07-28 at Jakub's request*
