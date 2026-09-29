# Phase 36: Child wallet bindings & read-only view - Pattern Map

**Mapped:** 2026-09-29
**Files analyzed:** 12
**Analogs found:** 12 / 12

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `packages/genius_api/lib/ffi/genius_api_ffi.dart` (splice) | FFI binding | request-response | same file, existing bindings (lines 343-348, 554-567, 920-956) | exact (splice into self) |
| `packages/genius_api/lib/genius_api.dart` (splice: 12 wrappers) | service/wrapper | CRUD + file-I/O (native memory) | `getAvailableAccounts()` (`genius_api.dart:1237-1252`), `GetOutTransactions`+free (`:1108-1171`) | exact |
| `lib/child_wallets/child_wallets_cubit.dart` (new) | store/cubit | request-response + polling | `GeniusBalanceDisplay` polling cubit consumer (`lib/wallets/view/genius_balance_display.dart:58`) | role-match |
| `lib/child_wallets/child_wallets_screen.dart` (new) | component (screen) | request-response | `lib/settings/settings_screen.dart` (`GWScreen(appBar:...)`), routing shape from `lib/network/network_page.dart` | role-match (chrome from Settings, routing from Network) |
| `lib/child_wallets/child_wallets_header.dart` (new) | component | request-response | `SDKAccountRow` title/subtitle block (`sdk_account_manager.dart:83-95`), `AccountAvatar` (`account_drawer.dart:~672`) | role-match |
| `lib/child_wallets/child_wallet_row.dart` (new) | component | request-response | `GWSelectRow` content shape (`lib/components/cards/gw_select_row.dart:104-140`) | role-match (content only, not interactive) |
| `lib/dev/dev_mock_child_wallets.dart` (new) | utility/fixture | in-memory mock | `lib/dev/dev_mock_sgnus.dart` (singleton pattern) | exact |
| `lib/dev/dev_tools_bubble.dart` (modify: add `_Section`) | component | event-driven | existing `_Section`/`_devButton` blocks (lines 365-430, 771-870) | exact |
| `lib/account/sdk_account_manager.dart` (modify: `sdkRowActions` + menu item) | component/utility | request-response | same file, existing gate + `_menuItem` calls (lines 496-505, 122-170) | exact (self-extend) |
| `lib/navigation/router.dart` (modify: add route) | route | request-response | `/network` `GoRoute` (lines 197-205) | exact |
| `test/ffi/child_wallet_struct_layout_test.dart` (new) | test | transform | any `ffi.sizeOf<T>()` style test (pattern implied by D-16, no direct analog needed — trivial) | n/a |
| `test/child_wallets/child_wallets_screen_test.dart` (new) | test | request-response | `test/account/sdk_account_rows_test.dart` (`implements GeniusApi` + `noSuchMethod` fake, lines 52-72) | exact |

## Pattern Assignments

### `genius_api_ffi.dart` splice (FFI bindings + structs + enum)

**Analog:** same file's own existing bindings/structs.

**Simple lookup pattern** (mirror for `GeniusSDKGetPubSub`, style at lines 343-348 for `GeniusSDKGetVersion`):
```dart
ffi.Pointer<ffi.Void> GeniusSDKGetPubSub() => _GeniusSDKGetPubSub();
late final _GeniusSDKGetPubSubPtr =
    _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Void> Function()>>('GeniusSDKGetPubSub');
late final _GeniusSDKGetPubSub = _GeniusSDKGetPubSubPtr.asFunction<ffi.Pointer<ffi.Void> Function()>();
```

**Out-param + struct-by-value pattern** — see RESEARCH.md's fully-verified `GeniusSDKGetRegistrationsForMain` binding (splice before line 772, structs after line 1153). Copy verbatim — RESEARCH.md already derived exact field layouts (392 / 664 bytes) and splice line numbers from a direct header read this session; do not re-derive.

**Enum extension:** `GeniusNodeReturnValue` (lines 971-993) gets `GENIUS_NODE_ERROR_REGISTRATION(7)` + matching `fromValue` case. `_mapNodeReturnValue` (`genius_api.dart:1434-1441`) needs no change (already catches unmapped ints via try/catch).

---

### `genius_api.dart` wrapper functions (12 new methods)

**Analog:** `getAvailableAccounts()` (`genius_api.dart:1237-1252`) for the alloc/call/free/finally shape; `GetOutTransactions` (`:1108-1171`) for the multi-entry-copy-then-free shape.

**Free pattern to copy exactly** (RESEARCH.md Code Examples, verified this session):
```dart
final entriesPtrPtr = calloc<ffi.Pointer<GeniusRegistrationDiscoveryEntry>>();
final countPtr = calloc<ffi.Uint64>();
try {
  final rv = _ffiBridgePrebuilt.sgnsLib.GeniusSDKGetRegistrationsForMain(mainPtr, entriesPtrPtr, countPtr);
  final mapped = _mapNodeReturnValue(rv);
  if (mapped != GeniusNodeReturnValue.GENIUS_NODE_RET_OK) {
    return (result: mapped, entries: <ChildRegistration>[]);
  }
  final entries = entriesPtrPtr.value;
  // ...copy fields, then:
  if (entries != nullptr) {
    _ffiBridgePrebuilt.sgnsLib.GeniusSDKFree(entries.cast<ffi.Void>());
  }
  return (result: mapped, entries: list);
} finally {
  malloc.free(mainPtr);
  calloc.free(entriesPtrPtr);
  calloc.free(countPtr);
}
```
**Record return type** (not a bare `List<T>`) is required — mirrors `sdkRowActions`'s own record idiom (`sdk_account_manager.dart:496`) — so D-13 (0-count success = empty) and D-08 (error + Retry) stay distinguishable at the call site.

**GetPubSub wrapper:** returns the raw `ffi.Pointer<ffi.Void>` (or wraps it opaquely) and is never passed to `GeniusSDKFree` — no free-pattern to copy, this is the one deliberate exception.

**Write-op wrappers (Fund/Recover/Detach/Revoke/ReplaceMain/RegisterChild):** each is a simple ret-code call, no out-params — copy the plainest existing ret-code wrapper (e.g. any single-call wrapper near `_mapNodeReturnValue` usage in `genius_api.dart:940-1100`). Bind+wrap only, no UI caller this phase.

---

### `lib/child_wallets/child_wallets_cubit.dart` (new)

**Analog:** `GeniusBalanceDisplay`'s `Timer.periodic(10s)` poll, cancelled on dispose (`lib/wallets/view/genius_balance_display.dart:58`; also `wallet_overview.dart:74`).

**Core pattern:**
```dart
Timer? _pollTimer;
@override
void onStart() { // or in State.initState
  _load();
  _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) => _load());
}
@override
Future<void> close() {
  _pollTimer?.cancel();
  return super.close();
}
```
Reads only through `GeniusApi` (D-17) — no FFI/Hive import in this file. Dev-mock check: `if (kDebugMode && kShowDevTools && DevMockChildWallets.instance.preset != null) { ... }` mirrors `DevMockSgnus`'s gated call sites.

**Node-not-running test:** reuse `state.selectedSDKAccount == null` (`lib/account/account_switcher.dart:41-44`), same check `AccountSwitcher` already uses for its "Node not running" copy.

---

### `lib/child_wallets/child_wallets_screen.dart` (new)

**Analog (chrome):** `lib/settings/settings_screen.dart:171` — `GWScreen(appBar: AppBar(title: const Text('Settings')))`.
**Analog (routing shape only, not body styling):** `lib/network/network_page.dart` via `router.dart:197-205` — explicitly NOT a visual reference (pre-redesign, raw `Colors.*`).

```dart
GWScreen(
  appBar: AppBar(title: const Text('Child wallets')),
  scroll: false, // required override — variable-length list, GWScreen.scroll defaults true
  child: Column(children: [
    ChildWalletsHeader(...),        // ALWAYS rendered, all states (D-08)
    const SizedBox(height: GeniusWalletConsts.space8),
    Expanded(child: /* list | GWEmptyState | GWErrorState */),
    if (populatedOrConnectedEmpty) ...[
      const SizedBox(height: GeniusWalletConsts.space6),
      Text("Balances come from the node's synced view and can lag.",
           style: GeniusWalletTypography.bodySm.copyWith(color: gw.textSecondary)),
    ],
  ]),
)
```

**Error/empty state constructors** (`lib/components/feedback/gw_empty_state.dart:8-21`, `lib/components/feedback/gw_error_state.dart:8-19`):
```dart
GWEmptyState({icon = Icons.inbox_outlined, required title, message, actionLabel, onAction});
GWErrorState({title = 'Something went wrong', message, onRetry, retryLabel = 'Retry'});
```
No `actionLabel`/`onAction` passed for either empty state (no CTA this phase); `GWErrorState(title: "Couldn't load child wallets", onRetry: () => cubit.refresh())`.

---

### `lib/child_wallets/child_wallets_header.dart` (new)

**Analog:** `SDKAccountRow`'s title/subtitle rendering (`sdk_account_manager.dart:83-95`) for text roles; `AccountAvatar`'s brand-fill circle avatar (`lib/account/account_drawer.dart:~672`) for the leading slot — reused for its fill/icon-colour recipe without requiring a `Wallet` object:
```dart
CircleAvatar(radius: 16, backgroundColor: gw.brandPrimaryStrong,
  child: Icon(Icons.account_balance_wallet, size: 18, color: gw.textOnBrand))
```
Container is `surfaceWell`-filled (NOT a `GWCard`), per UI-SPEC Component Inventory.

---

### `lib/child_wallets/child_wallet_row.dart` (new)

**Analog:** `GWSelectRow`'s content shape (`lib/components/cards/gw_select_row.dart:104-140`) — copy padding/gap/text-style values only, NOT the widget itself (no `onTap`, no selection tint — nothing is tappable this phase). Linked leading uses `AccountAvatar(wallet: linkedWallet, isSelected: false, size: 36)`; unlinked leading uses a neutral `CircleAvatar(radius: 16, backgroundColor: gw.surfaceSunken, child: Icon(Icons.question_mark, ...))` — same geometry, no jitter between states.

Balance conversion helper (no float divide, per D-05):
```dart
String minionsToGnusString(int minions) =>
    '${minions ~/ 1000000}.${(minions % 1000000).toString().padLeft(6, '0')}';
```
Feed the result string into `formatTxAmount` (`lib/dashboard/home/widgets/transaction_utils.dart:112-134`) — do not build a second formatter.

---

### `lib/dev/dev_mock_child_wallets.dart` (new)

**Analog:** `lib/dev/dev_mock_sgnus.dart` — singleton pattern, verified this session:
```dart
class DevMockChildWallets {
  DevMockChildWallets._();
  static final DevMockChildWallets instance = DevMockChildWallets._();
  // one nullable "preset" field the cubit reads under kDebugMode && kShowDevTools
}
```
Five presets per D-18: none, one child, three children (mixed linked/unlinked, one zero balance), query error, node not running — plus a clear action. Address strings should stay obviously synthetic (`0xDEV...`) as `DevMockSgnus.address` does.

---

### `lib/dev/dev_tools_bubble.dart` (modify)

**Analog:** existing `_Section`/`_devButton` blocks (e.g. lines 365-430 for the "Populated"/"Long"/"Unpriced"/"Clear" buttons under one `_Section`).
```dart
_Section(
  label: 'CHILD WALLETS',
  children: [
    Wrap(children: [
      _devButton('None', () => DevMockChildWallets.instance.setPreset(...)),
      _devButton('One child', () => ...),
      _devButton('Three children', () => ...),
      _devButton('Query error', () => ...),
      _devButton('Node not running', () => ...),
      _devButton('Clear', () => DevMockChildWallets.instance.clear()),
    ]),
  ],
),
```
Insert after the existing `BANXA` section, before `NAVIGATE` (per UI-SPEC ordering).

---

### `lib/account/sdk_account_manager.dart` (modify)

**Analog:** the file's own gate tuple and menu items.

**Gate extension** (`sdkRowActions`, line 496):
```dart
({bool payout, bool phrase, bool qr, bool delete, bool childWallets}) sdkRowActions({...}) => (
  payout: isSelected,
  phrase: isSelected && hasMnemonic,
  qr: isSelected && hasMnemonic,
  delete: !isSelected && !isStartAccount,
  childWallets: isSelected,
);
```

**Menu item insertion** (after "View balance" at line ~144, before the `Divider` at line ~155):
```dart
_menuItem(
  gw,
  icon: Icons.account_tree,
  label: 'Child wallets',
  onPressed: can.childWallets ? () => context.push('/child-wallets') : null,
),
```
No change to `_menuItem` itself — disabled dimming is automatic via `onPressed: null` (lines 189-196).

---

### `lib/navigation/router.dart` (modify)

**Analog:** `/network` route (lines 197-205), copied verbatim in shape:
```dart
GoRoute(
  path: '/child-wallets',
  builder: (context, state) => BlocProvider(
    create: (_) => ChildWalletsCubit(context.read<GeniusApi>(), context.read<AppBloc>()),
    child: const ChildWalletsScreen(),
  ),
),
```

---

### `test/child_wallets/child_wallets_screen_test.dart` (new)

**Analog:** `test/account/sdk_account_rows_test.dart:52-72` — hand-rolled `implements GeniusApi` + `noSuchMethod` fake, avoiding a mock framework:
```dart
class _FakeGeniusApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
  // override only the methods this test calls
}
```

### `test/ffi/child_wallet_struct_layout_test.dart` (new)

Pure-Dart, no analog needed — copy verbatim from RESEARCH.md Code Examples:
```dart
test('GeniusRegistrationMetadata matches GeniusSDK.h layout', () {
  expect(ffi.sizeOf<GeniusRegistrationMetadata>(), 392);
});
test('GeniusRegistrationDiscoveryEntry matches GeniusSDK.h layout', () {
  expect(ffi.sizeOf<GeniusRegistrationDiscoveryEntry>(), 664);
});
```

## Shared Patterns

### Memory ownership (free exactly once, only if non-null)
**Source:** `genius_api.dart:1237-1252` (`getAvailableAccounts`)
**Apply to:** every new wrapper with an out-param pointer (`GetRegistrationsForMain`); never applied to `GetPubSub` (node-owned, D-14).

### Return-code mapping
**Source:** `_mapNodeReturnValue` (`genius_api.dart:1434-1441`)
**Apply to:** all 12 new wrappers — no change needed to the mapper itself, only the enum gains one member.

### Disabled-menu-item treatment
**Source:** `_menuItem` (`sdk_account_manager.dart:182-201`)
**Apply to:** the new "Child wallets" menu item — no code change to `_menuItem`, just pass `onPressed: null` when `!can.childWallets`.

### GNUS amount formatting
**Source:** `formatTxAmount` (`lib/dashboard/home/widgets/transaction_utils.dart:112-134`)
**Apply to:** `ChildWalletRow`'s trailing balance — feed it the integer-exact `minionsToGnusString` output, never a float.

### Screen chrome (GWScreen + AppBar)
**Source:** `lib/settings/settings_screen.dart:171`
**Apply to:** `ChildWalletsScreen` — `scroll: false` override required (list is variable-length).

## No Analog Found

None — all 12 files/edits have a direct or role-matched analog in the current codebase; RESEARCH.md already supplies verified exact declarations/line numbers for the FFI splice, which is the only genuinely new surface this phase introduces.

## Metadata

**Analog search scope:** `packages/genius_api/lib/`, `lib/account/`, `lib/dev/`, `lib/components/`, `lib/wallets/view/`, `lib/network/`, `lib/settings/`, `lib/navigation/`, `test/account/`
**Files scanned:** ~15 (direct reads) + RESEARCH.md's already-verified header/ffi/wrapper reads (reused, not re-read)
**Pattern extraction date:** 2026-09-29
</content>
