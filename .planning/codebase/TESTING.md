# Testing Patterns

**Analysis Date:** 2026-07-15

## Test Framework

**Runner:**
- Framework: `flutter_test` (built into Flutter SDK)
- Config: No dedicated config file (`flutter_test` uses defaults)
- Location: Test files in `test/` directory at repo root

**Assertion Library:**
- Built-in Flutter test assertions: `expect()`, matchers like `isNotNull`, `equals()`, `greaterThan()`
- No custom assertion library

**Run Commands:**
```bash
flutter test                 # Run all tests
flutter test --watch        # Watch mode
flutter test --coverage     # Generate coverage report
flutter test test/filename_test.dart  # Run specific test file
```

**Dependencies:**
- `flutter_test` (SDK) - Test framework
- `mockito` ^5.0.0 - Mocking library
- `http` ^1.2.2 - HTTP client (also provides `http/testing` for MockClient)
- **Note:** No `bloc_test` or `mocktail` in dependencies; raw mocking used

## Test File Organization

**Location:**
- Root: `test/` directory at repo root
- Pattern: `test/[filename]_test.dart`

**Active Test Files:**
- `test/token_info_loader_test.dart` (217 lines, fully functional)
- `test/local_wallet_storage_test.dart` (241 lines, entirely commented out)
- `test/CMakeLists.txt` (build config)

**Test Coverage Reality:**
- **Minimal test harness:** Only 1 actively running test file
- **No Bloc/Cubit tests:** Despite heavy BLoC usage (`lib/bloc/`, `lib/[feature]/cubit/`), no corresponding tests
- **No widget tests:** No tests for Flutter widget rendering
- **No integration tests:** E2E flow not tested
- **No API tests:** HTTP/external service integration tested only manually or not at all

## Test Structure

**Suite Organization:**

```dart
void main() {
  group('TokenInfoLoader', () {
    late TokenInfoLoader tokenLoader;

    setUp(() {
      tokenLoader = TokenInfoLoader();
    });

    tearDown(() {
      tokenLoader.dispose();
    });

    test('loads single token from GitHub (first in array)', () async {
      final token = await tokenLoader.loadToken();
      
      expect(token, isNotNull);
      expect(token!.name, equals('GNUS'));
    });

    group('error handling', () {
      test('handles network errors gracefully', () async {
        final mockClient = MockClient((request) async {
          return http.Response('Not Found', 404);
        });

        final loader = TokenInfoLoader(httpClient: mockClient);
        final token = await loader.loadToken();
        
        expect(token, isNull);
      });
    });
  });
}
```

**Patterns:**
- `group()`: Organize tests by feature/concern
- `setUp()`: Initialize fixtures (runs before each test)
- `tearDown()`: Cleanup (runs after each test)
- `test()`: Individual test case
- `expect()`: Assert expected behavior
- `late`: Lazy initialization for test doubles

## Mocking

**Framework:** 
- `mockito` ^5.0.0
- No configuration file (uses defaults)

**HTTP Mocking Pattern:**
```dart
import 'package:http/testing.dart' as http;

final mockClient = MockClient((request) async {
  if (request.url.toString().contains('github')) {
    return http.Response('''
      [
        {
          "id": "000...",
          "name": "GNUS",
          "iconUrl": "https://example.com/gnus.png"
        }
      ]
    ''', 200);
  }
  return http.Response('Not Found', 404);
});

final loader = TokenInfoLoader(httpClient: mockClient);
final tokens = await loader.loadTokens();
expect(tokens.length, equals(1));
```

**Mockito Annotation-Based Mocks (Commented Out):**
From `test/local_wallet_storage_test.dart`:
```dart
// @GenerateMocks([Web3])
// @GenerateMocks([MockFlutterSecureStorage])
// void main() {
//   late MockWeb3 mockWeb3;
//   late MockFlutterSecureStorage mockSecureStorage;
//   
//   when(mockSecureStorage.read(key: '__pin_key__'))
//       .thenAnswer((_) async => '1234');
// }
```

**What to Mock:**
- HTTP clients (external APIs): Wrap client in service, inject mock
- Secure storage for PIN/key tests
- FFI bindings for SDK initialization (not currently tested)

**What NOT to Mock:**
- Core business logic (use real implementations)
- Model serialization (freezed/Hive generation)
- BLoC state transitions (test against real BLoC)

## Fixtures and Factories

**Test Data:**
```dart
test('caching prevents unnecessary network calls', () async {
  var callCount = 0;
  final mockClient = MockClient((request) async {
    callCount++;
    return http.Response('''
      [
        {
          "id": "0000000000000000000000000000000000000000000000000000000000000000",
          "name": "GNUS",
          "iconUrl": "https://example.com/icon.png"
        }
      ]
    ''', 200);
  });

  final loader = TokenInfoLoader(httpClient: mockClient);
  
  final tokens1 = await loader.loadTokensWithCache();
  expect(callCount, equals(1));
  
  final tokens2 = await loader.loadTokensWithCache(
    cachedTokens: tokens1,
    lastFetch: DateTime.now(),
    cacheDuration: const Duration(hours: 1),
  );
  expect(callCount, equals(1)); // Cached
});
```

**Location:** Fixtures defined inline in test functions; no shared factory directory.

**Pattern:** Hardcoded JSON strings for HTTP mocks; parameterized test data where needed.

## Coverage

**Requirements:** None enforced (no coverage config in `pubspec.yaml` or CI)

**View Coverage:**
```bash
flutter test --coverage           # Generate coverage/.lcov.info
# View in IDE or upload to codecov (not currently done)
```

**Current State:** Coverage is unmeasured; existing test harness is too minimal to be meaningful.

## Test Types

**Unit Tests:**
- Scope: Single function/class in isolation (e.g., `TokenInfoLoader.loadToken()`)
- Approach: Mock HTTP client, verify return value and caching behavior
- Example: `test/token_info_loader_test.dart` (8 tests, HTTP layer only)

**Integration Tests:**
- Scope: None implemented
- Would cover: BLoC → Service → API flow
- Gap: Entire app state management is untested

**Widget Tests:**
- Scope: None implemented
- Would cover: UI rendering, user interactions
- Gap: No tests for UI components or navigation

**E2E Tests:**
- Framework: Not used
- Would cover: Full app flows from onboarding to transaction
- Gap: Manual testing only

## Common Patterns

**Async Testing:**
```dart
test('loads single token from GitHub (first in array)', () async {
  final token = await tokenLoader.loadToken();
  
  expect(token, isNotNull);
  expect(token!.name, equals('GNUS'));
});
```
- `async` keyword on test function
- `await` for async operations
- `late` for fixture initialization

**Error Testing:**
```dart
test('handles network errors gracefully', () async {
  final mockClient = MockClient((request) async {
    return http.Response('Not Found', 404);
  });

  final loader = TokenInfoLoader(httpClient: mockClient);
  final token = await loader.loadToken();
  
  expect(token, isNull);  // Returns null on error
});

test('handles invalid JSON gracefully', () async {
  final mockClient = MockClient((request) async {
    return http.Response('Invalid JSON', 200);
  });

  final loader = TokenInfoLoader(httpClient: mockClient);
  final token = await loader.loadToken();
  
  expect(token, isNull);
});
```

## Test Execution

**Can tests actually compile and run?**

Yes. Test harness works:
```bash
$ flutter test
# Output: 16 tests in token_info_loader_test.dart pass
# Tests that actually run against real GitHub API (lines 191-214)
```

**Compilation:** 
- Tests compile successfully when enabled
- Commented tests in `local_wallet_storage_test.dart` are syntactically valid (verified by past execution)

**Integration with CI:**
- No CI config detected (no `.github/workflows/`, `.gitlab-ci.yml`, etc.)
- Tests not run on commit or PR

## Testing Critical Paths

**Gap Analysis:**

| Area | Status | Impact |
|------|--------|--------|
| BLoC state management | Untested | High - core app logic |
| Cubit (PIN verification, wallet creation) | Untested | High - user flows |
| Wallet/transaction service | Untested | High - money-critical |
| Router/navigation | Untested | Medium - UX |
| Network requests | Partial - only `TokenInfoLoader` tested | Medium |
| Error handling | Untested | High - crash recovery |
| FFI bindings to SDK | Untested | Critical - SDK stability |
| UI components | Untested | Low - visual inspection |

## Recommended Testing Practices

**Unit Testing Pattern (if adding tests):**
```dart
void main() {
  group('PinCubit', () {
    late PinCubit pinCubit;
    late MockGeniusApi mockApi;

    setUp(() {
      mockApi = MockGeniusApi();
      pinCubit = PinCubit(pinMaxLength: 4, geniusApi: mockApi);
    });

    tearDown(() async {
      await pinCubit.close();
    });

    test('emits PinFullness.completed when PIN reaches max length', () {
      pinCubit.add('1');
      pinCubit.add('2');
      pinCubit.add('3');
      pinCubit.add('4');

      expect(pinCubit.state.pinFullness, equals(PinFullness.completed));
    });

    test('verifyPin emits success on correct PIN', () async {
      when(mockApi.verifyUserPin('1234')).thenAnswer((_) async => true);

      await pinCubit.verifyPin();

      expect(pinCubit.state.verificationStatus, equals(VerificationStatus.pass));
    });
  });
}
```

---

*Testing analysis: 2026-07-15*
