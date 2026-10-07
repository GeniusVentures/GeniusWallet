# Phase 40: Always-available GNUS bridge - Pattern Map

**Mapped:** 2026-10-07
**Files analyzed:** 17 (3 new lib, 1 new widget set, 8 modified lib, 5 test)
**Analogs found:** 16 / 17

Line numbers are from the GW-v3 worktree; re-check at execution time.

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match |
|---|---|---|---|---|
| `lib/dashboard/bridge/bridge_gate.dart` (new) | utility (pure resolver) | transform | `lib/dashboard/bridge/bridge_cta_state.dart` | exact |
| `lib/dashboard/bridge/bridge_gate_cubit.dart` (new) | store (cubit) | event-driven (3 streams) + async probes | `lib/child_wallets/child_operations_cubit.dart` (stream-fed, `readAppState`/`appStates`) + `wallet_details_cubit.dart` (`_coinsGeneration`) | role-match |
| `lib/dashboard/bridge/bridge_entry.dart` (new: `BridgeButton`, `BridgeReasonCaption`, `openGnusBridge`) | component + handler | request-response | `token_info_screen.dart` Bridge `GWButton` + `_pushBridgeScreen` | exact |
| `lib/reown/utilities.dart` (mod: split `walletCanSign`) | utility | transform | itself, `canSendFrom` lines 22-29 | exact |
| `lib/main.dart` (mod: provide `BridgeGateCubit`) | config | provider | `BlocProvider<ChildOperationsCubit>` lines 431-438 | exact |
| `lib/navigation/router.dart` (mod: drop StreamBuilder + import) | route | request-response | itself, lines 286-299 | exact |
| `lib/tokens/token_info_screen.dart` (mod) | component | request-response | itself, `_CoinActionRow` 704-813 | exact |
| `lib/dashboard/assets/assets_screen.dart` (mod) | component | CRUD (list) | itself, `_body` loop 600-630 | exact |
| `lib/dashboard/compute/compute_panel.dart` (mod: `bridge`, `onBridge`) | component | request-response | itself, CTA at 159-165 | exact |
| `lib/dashboard/home/view/dashboard_screen.dart` (mod: slot 340 -> 360, comments) | config | n/a | itself (`kDashboardPanelSlotHeight` ~line 72) | exact |
| `lib/components/wallet_overview.dart` (mod: pass gate to `ComputePanel`) | component | request-response | itself, lines 239-264 | exact |
| `lib/dashboard/bridge/bridge_screen.dart` (mod: submit-time refusal, D-13) | component | request-response | itself, `_submitBridge` 304-341 | exact |
| `test/dashboard/bridge/bridge_gate_test.dart` | test | transform | `test/dashboard/bridge/bridge_cta_state_test.dart` | exact |
| `test/dashboard/bridge/bridge_gate_cubit_test.dart` | test | event-driven | `test/dashboard/compute_panel_wiring_test.dart` (`_SeededAppBloc`) | role-match |
| `test/dashboard/bridge/bridge_entry_test.dart` | test | request-response | `test/banxa/buy_entry_points_test.dart` | role-match |
| `test/dashboard/compute_panel_height_test.dart`, 4 `TokenInfoScreen` tests (mod) | test | n/a | themselves | exact |

## Pattern Assignments

### `bridge_gate.dart` (utility, transform)

**Analog:** `lib/dashboard/bridge/bridge_cta_state.dart`

Shape: enum with one doc line per rung, a resolver of `required` named params with early `return`s (each `if` braced), a copy function using `switch` with no default, and a one-line `enabled` getter.

```dart
// bridge_cta_state.dart:42-56, 91-93, 111-112
BridgeCtaState resolveBridgeCtaState({
  required String amount, ...
}) {
  if (isSubmitting) {
    return BridgeCtaState.submitting;
  }
  ...
}
String bridgeCtaLabel(BridgeCtaState state, {String? symbol}) {
  switch (state) {
    case BridgeCtaState.enterAmount:
      return 'Enter an amount';
    ...
  }
}
bool bridgeCtaEnabled(BridgeCtaState state) => state == BridgeCtaState.ready;
```

Rules:
- No Flutter imports (copy header doc: colour stays at the call site).
- The resolver skeleton is in RESEARCH "Resolver skeleton"; captions are the exact strings in UI-SPEC "Reason captions". `gnusElsewhere` takes `{network}` with fallback `GNUS is on another network.`.
- `isEarningWallet`: use the RESEARCH Q1 one-liner, lowercase both sides; sgnus wallets compare their own address.
- Do not cite plan numbers in doc comments (the analog's `08-04-PLAN.md` references are what NOT to copy).

### `bridge_gate_cubit.dart` (cubit, event-driven)

**Analog:** `lib/child_wallets/child_operations_cubit.dart` (constructor takes `readAppState` + `appStates` stream; imports lines 1-13)

```dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/dev/dev_flags.dart';
// main.dart:431-438 construction precedent
BlocProvider<ChildOperationsCubit>(
  create: (context) => ChildOperationsCubit(
    api: geniusApi,
    readAppState: () => context.read<AppBloc>().state,
    appStates: context.read<AppBloc>().stream,
    onResolved: context.read<WalletDetailsCubit>().getCoins,
  ),
),
```

Stale-async guard to copy (`wallet_details_cubit.dart:324-326, 349, 440, 461`):

```dart
int _coinsGeneration = 0;
final generation = ++_coinsGeneration;
...
if (!isClosed && generation == _coinsGeneration) { ... }
```

Dev-mock skip (`wallet_details_cubit.dart:341`): `if (kDebugMode && kShowDevTools && mockMode) { return; }` with the const bools first.

Other inputs:
- Child detection: `ChildOperationsCubit.ownRegistrations()` (lines 219-257), returns null when the node is down.
- Other-network probe: `Web3().balanceOf(address:, contractAddress:, rpcUrl:)` at `packages/genius_api/lib/web3/web3.dart:223`, `NetworkProvider.networks`, `NetworkTokensProvider.getTokensByNetwork`.
- Subscribe to the AppBloc, WalletDetailsCubit and ChildOperationsCubit streams, cancel in `close()`.
- State holds public addresses only (no key material).
- Mark ceilings with `ponytail:` (foreign-main child, probe staleness).

### `bridge_entry.dart` (widgets + handler)

**Analog:** `token_info_screen.dart:46-52` and `789-802`.

```dart
// Handler being moved (46-52)
Future<void> _pushBridgeScreen(BuildContext context, WalletDetailsCubit c) async {
  await GoRouter.of(context).push('/bridge', extra: walletDetailsCubit);
  walletDetailsCubit.getCoins();
}
// Button treatment being replaced (789-802)
GWButton(
  variant: GWButtonVariant.gradientOutline,
  size: GWButtonSize.sm,
  label: 'Bridge',
  leading: const Icon(Icons.alt_route),
  onPressed: ...,
),
```

Changes:
- `BridgeButton` picks `enabled ? gradientOutline : tertiary` and wraps `GWButton` in `Semantics(...)` per UI-SPEC "Semantics".
- `openGnusBridge` uses the RESEARCH "Shared open handler": re-read the gate, `selectCoin(gate.coin)`, `push('/bridge')`, `getCoins()`.
- `/bridge` ignores `extra` (router.dart:304-313), so `selectCoin` is load-bearing.
- Caption text style: `GeniusWalletTypography.labelMd.copyWith(color: gw.textSecondary)`, with `gw` read in `build`. For the 18px metric see `compute_panel.dart:180-181`: `numericBody.copyWith(fontSize: 13, height: 18 / 13, color: gw.textSecondary)`. Use `maxLines: 1`, `softWrap: false`, ellipsis.
- Widgets only, no `_buildFoo()`.
- Nullable cubit read for old harnesses, precedent `account_drawer.dart:448`: `final operations = context.watch<ChildOperationsCubit?>();`. Use `context.watch<BridgeGateCubit?>()` with a fallback `checking` gate.

### `lib/reown/utilities.dart` (split)

**Analog:** itself (lines 19-29). Behaviour-preserving refactor.

```dart
bool walletCanSign(Wallet wallet) =>
    wallet.walletType != WalletType.tracking &&
    wallet.walletType != WalletType.sgnus;

bool canSendFrom(Wallet? wallet, Network? network) =>
    wallet != null && walletCanSign(wallet) && network != null && canSignOn(network);
```

Callers of `canSendFrom` stay unchanged: `bridge_screen.dart:728`, `send_screen.dart:50`, `swap_screen.dart` (3 sites), `token_info_screen.dart:746,789`. Add a 4-row table test.

### `main.dart`

Add `BlocProvider<BridgeGateCubit>` after the `ChildOperationsCubit` provider (line 438), because it reads AppBloc, WalletDetailsCubit and ChildOperationsCubit. Copy the construction shape above.

### `router.dart`

Replace lines 286-299 with a plain `TokenInfoScreen(walletDetailsCubit: walletCubit, args: args)`. Remove the `sgnus_connection.dart` import (line 6). Update the 4 test constructors listed in RESEARCH Q5. The `/bridge` route (304-313) stays as is.

### `token_info_screen.dart`

- Delete `_pushBridgeScreen` (46-52) and the `isGnusWalletConnected` param/field (~132, 148, 252).
- In `_CoinActionRow`, replace line 789 `if (isGnusBridgeEnabled && canSendFrom(...))` with `if (pageSymbol == 'gnus')`. This is the exact test Buy uses at line 803.
- The caption goes on its own line below the `Wrap` (704), with `SizedBox(height: GeniusWalletConsts.space4)` above it.

### `assets_screen.dart`

Insert between `CoinCardRow` and `Divider` in the loop (lines 602-629), only for the first coin whose symbol is `gnus`. Keep the `walletCubit.selectCoin(coin)` write untouched.

```dart
if (i < visible.length - 1)
  Divider(height: 1, thickness: 1, color: gw.borderSubtle),
```

Padding per UI-SPEC: `kGWRowWall` left and right, `kGWRowSeparatorGap` bottom. Do not edit `CoinCardRow`.

### `compute_panel.dart`

Replace the CTA at lines 159-165 with a `Row` when `bridge != null`, else keep the old full-width button.

```dart
GWButton(
  variant: GWButtonVariant.primary,
  size: GWButtonSize.sm,
  expand: true,
  label: 'New processing job',
  onPressed: view.ctaEnabled ? onNewJob : null,
),
```

- With a bridge, wrap the job button in `Expanded`, then `SizedBox(width: space4)`, then `BridgeButton`.
- The caption goes below the row after `SizedBox(height: space2)`.
- Update the 340/314/306 comments (lines ~134-143, plus `dashboard_screen.dart` and `wallet_overview.dart`).
- `ComputePanel` reads no bloc by design, so the gate arrives as a param. `wallet_overview.dart` (the singular file, not `wallets_overview.dart`) reads `BridgeGateCubit` inside its existing BlocBuilders.

### `bridge_screen.dart` (D-13)

**Analog:** `_submitBridge` 304-341 and the toast call.

```dart
showToast(
  context,
  isSuccess ? 'Bridge transaction completed.' : failureMessage,
  title: isSuccess ? 'Success' : 'Error',
  type: isSuccess ? ToastType.success : ToastType.error,
);
```

At the top of `_submitBridge`, before `setState(() => isSubmitting = true)` at line 308, re-read the gate. If it is not enabled, call `showToast(context, <caption>, title: "Can't bridge", type: ToastType.error)` and return, with no `bridgeOut` call. The caption comes from the shared gate copy function. Note the file's own comment says the closure stays "byte-identical"; this guard is the one deliberate exception (D-13).

### Tests

- `bridge_gate_test.dart`: copy the `bridge_cta_state_test.dart` shape (plain `flutter_test`, `group` per rung, `expect(state, X)` plus enabled plus caption). Add the exhaustive `BridgeGateState.values` loop for distinct and non-empty captions (idiom: `test/dashboard/compute_state_distinct_test.dart`). Add a mixed-case address test.
- `bridge_gate_cubit_test.dart`: use `_SeededAppBloc extends AppBloc` (`compute_panel_wiring_test.dart:78-98`), `_UnusedApi implements GeniusApi` with `noSuchMethod` (`assets_screen_test.dart:50-53`), and `tester.runAsync(appBloc.close)` teardown.
- `bridge_entry_test.dart`: copy the `buy_entry_points_test.dart` host (a `GoRouter` recording pushes; `WalletDetailsCubit(initialState: ...)` seeding at :57-70; the 360px both-modes loop at :195-213). Contrast via `contrastRatio`/`themeFor` from `test/theme/theme_contrast_test.dart:21`.
- Extend `compute_panel_height_test.dart` (bridge-present, disabled-with-caption at 320 and 290).

## Shared Patterns

### Brace rule
**Apply to:** all new Dart. Every `if` braced, body on its own line (`tool/check_brace_style.sh`).

### Tokens only
**Source:** `lib/theme/gw_colors.dart`. **Apply to:** `bridge_entry.dart`. Read `Theme.of(context).extension<GWColors>()` inside `build`. The caption uses `gw.textSecondary`. No `Colors.*` (`tool/check_raw_colors.sh`).

### Nullable provider read
**Source:** `account_drawer.dart:448`. **Apply to:** the three surfaces, so existing test harnesses need no new provider.

### Tap-time gate re-read
**Source:** RESEARCH "Shared open handler". **Apply to:** `openGnusBridge` and `BridgeScreen._submitBridge`.

## No Analog Found

| File | Role | Reason |
|---|---|---|
| One-line reason caption widget (`BridgeReasonCaption`) | component | `GWWarningNote` is a bordered box and `_AccountSectionNote` is private; use the `compute_panel.dart` sub-line style recipe |

## Metadata

**Analog search scope:** `lib/dashboard/bridge`, `lib/dashboard/compute`, `lib/dashboard/assets`, `lib/tokens`, `lib/navigation`, `lib/child_wallets`, `lib/wallets/cubit`, `lib/reown`, `lib/main.dart`, `lib/account`
**Files scanned:** about 14 read plus greps
**Pattern extraction date:** 2026-10-07
