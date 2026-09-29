# Phase 37: Child write operations & pending model - Pattern Map

**Mapped:** 2026-09-29
**Files analyzed:** 10 (6 new, 4 extended)
**Analogs found:** 10 / 10

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `lib/child_wallets/child_operations_cubit.dart` (new) | store | event-driven | `lib/child_wallets/child_wallets_cubit.dart` | role-match (poll/emit shape identical; this one has no FFI read of its own, just derives from existing polls) |
| `lib/child_wallets/child_operation_dialogs.dart` (new, 6 dialogs) | component | request-response | `lib/account/sdk_account_manager.dart` (`_confirmDeleteSDKAccount`, `_showSetPayoutAddressDialog`) | exact |
| `lib/child_wallets/child_operation_switch_dialog.dart` (new) | component | request-response | `lib/account/sdk_account_manager.dart` (`_confirmDeleteSDKAccount`'s await-the-real-signal tail) | exact |
| `lib/child_wallets/child_main_picker_dialog.dart` (new) | component | request-response | `lib/account/sdk_account_manager.dart` (`_AddAccountDialog`, `_PayoutAddressForm`) | role-match |
| `lib/components/data/gw_row_badge.dart` (new, promoted) | component | transform | `lib/account/account_drawer.dart` (`_RowBadge`) | exact (byte-identical body, just moved + exported) |
| `lib/child_wallets/child_wallets_screen.dart` (extended: menu, card actions, badges) | component | request-response | `lib/account/sdk_account_manager.dart` (`SDKAccountRow`'s `MenuAnchor`/`_menuItem`) | exact |
| `lib/account/account_drawer.dart` (extended: `SDKAccountRow.lockedReason`) | component | request-response | same file, `_menuItem`'s disabled-foreground treatment | exact (self-analog) |
| `lib/dev/dev_mock_child_wallets.dart` (extended: write modes) | utility | event-driven | same file (existing read-preset `ValueNotifier<enum>` gate) | exact (self-analog) |
| `lib/dev/dev_tools_bubble.dart` (extended: 3 buttons) | component | event-driven | same file, existing `_devButton` calls in the CHILD WALLETS section (~1181-1253) | exact (self-analog) |
| `lib/main.dart` (extended: provide `ChildOperationsCubit`) | config | event-driven | same file, existing `AppBloc` provider (~408-421) | exact (self-analog) |

## Pattern Assignments

### `lib/child_wallets/child_operations_cubit.dart` (store, event-driven)

**Analog:** `lib/child_wallets/child_wallets_cubit.dart` (read in full above)

**Core pattern — Cubit + dev-gate + derived-from-polls, not its own timer** (lines 67-92, 106-108):
```dart
class ChildWalletsCubit extends Cubit<ChildWalletsState> {
  ChildWalletsCubit({required GeniusApi api, ...}) : ... {
    refresh();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) => refresh());
    if (kDebugMode && kShowDevTools) {
      DevMockChildWallets.instance.preset.addListener(refresh);
    }
  }
  final devPreset = (kDebugMode && kShowDevTools)
      ? DevMockChildWallets.instance.preset.value
      : null;
```
Copy the constructor-registers-a-listener / `close()` removes-it idiom (lines 184-191) verbatim for
`ChildOperationsCubit`, but do NOT add a second `Timer.periodic` (Pitfall 3, RESEARCH.md) — instead
expose `resolve()` and have `ChildWalletsCubit.refresh()` (or its own `DevMockChildWallets` write-mode
listener) call it, or have the screen call both on the same tick.

**State shape idiom — `copyWith`, immutable list swap** (lines 39-62):
```dart
class ChildWalletsState {
  const ChildWalletsState({required this.status, ...});
  ChildWalletsState copyWith({...}) => ChildWalletsState(...);
}
```
Model `ChildOperation` (kind, fromAccount, target, newMain?, amountGnus?, submittedAt,
baselineBalance?) the same way: an immutable value class, `List<ChildOperation>` held on state,
replaced wholesale on `start()`/`resolve()`, never mutated in place.

**Exact-decimal GNUS → BigInt conversion, reuse directly:**
```dart
// Source: lib/child_wallets/child_wallets_cubit.dart:12-17
String minionsToGnus(BigInt minions) {
  final million = BigInt.from(1000000);
  final whole = minions ~/ million;
  final remainder = (minions % million).toString().padLeft(6, '0');
  return '$whole.$remainder';
}
```

---

### `lib/child_wallets/child_operation_dialogs.dart` (component, request-response) — 6 dialogs

**Analog:** `lib/account/sdk_account_manager.dart` — `_confirmDeleteSDKAccount` (lines ~325-435) and `_showSetPayoutAddressDialog` (lines 437-497, both read above)

**Imports pattern** — same file's top-of-class usage: `GWDialog`, `GWDialogAction`, `GWButtonVariant`, `showToast`/`ToastType`, `context.read<AppBloc>()`, `Navigator.of(context, rootNavigator: true)`.

**Root-navigator capture before the triggering menu closes** (lines 437-441):
```dart
final navigator = Navigator.of(context, rootNavigator: true);
Navigator.of(context).pop();               // close the menu/card first
final result = await GWDialog.show<T>(context: navigator.context, ...);
```
Every one of the six new dialogs (Fund/Recover/Revoke/Detach/Move/Register) opens this way.

**Destructive confirm pattern** (lines 380-398) — copy verbatim for Revoke/Detach/Move:
```dart
actions: [
  GWDialogAction(label: 'Cancel', onPressed: () => navigator.pop(false)),
  GWDialogAction(
    label: 'Delete account',   // -> 'Revoke' / 'Detach' / 'Move'
    variant: GWButtonVariant.destructive,
    onPressed: () => navigator.pop(true),
  ),
],
```

**"Consume the return value exactly once" + toast idiom** (lines 404-434) — this IS Pattern 1 from RESEARCH.md, already shipped here for delete:
```dart
bloc.add(DeleteSDKAccount(address));
final removed = await bloc.stream
    .map((s) => !s.sdkAccounts.contains(address))
    .firstWhere((gone) => gone, orElse: () => false)
    .timeout(const Duration(seconds: 3), onTimeout: () => false);
if (!navigator.context.mounted) return;
showToast(navigator.context, removed ? 'SDK account deleted' : 'The SDK refused to delete that account.',
    type: removed ? ToastType.success : ToastType.error, duration: Duration(seconds: removed ? 1 : 3));
```
For Fund/Recover/Revoke/Detach/Move/Register: replace the `bloc.stream`/list-membership wait with a
direct, synchronous `GeniusApi` call (these are synchronous FFI writes per RESEARCH.md, no async
gap) — check the returned `GeniusNodeReturnValue` immediately:
```dart
// Source: packages/genius_api/lib/src/genius_api.dart:1749 (fundChildGnus), per RESEARCH.md Pattern 1
final result = api.fundChildGnus(amountGnus, childAddress);
if (result != GeniusNodeReturnValue.GENIUS_NODE_RET_OK) {
  showToast(context, 'The SDK refused to fund this child (${result.name}).', type: ToastType.error);
  return;
}
context.read<ChildOperationsCubit>().start(ChildOperation(kind: fund, fromAccount: mainAddress,
    target: childAddress, amountGnus: amountGnus,
    baselineBalanceMinions: api.getChildBalanceAll(childAddress), submittedAt: DateTime.now()));
```
This is the one departure from the delete-flow analog: submission is synchronous, so there is no
`bloc.stream.firstWhere` here — `start()` on the registry replaces it, and the toast only fires later
from `resolve()` (never from the submit handler) per D-12/D-11.

**Amount field, reuse verbatim (`send_screen.dart:206-228`, `send_cubit.dart:498-522` read above):**
```dart
final typed = state.amount.trim();
final rawAmount = toBaseUnits(typed, decimals);   // decimals = 6, symbol = 'GNUS'
if (rawAmount != null && RegExp('\\.\\d{$decimals}\\d*[1-9]').hasMatch(typed)) {
  emit(state.copyWith(amountError: '$symbol supports up to $decimals decimal $places.'));
  return;
}
if (rawAmount == null || rawAmount <= BigInt.zero) {
  emit(state.copyWith(amountError: 'Enter an amount to send.'));  // -> 'Enter an amount.'
  return;
}
```
Add the balance-cap check UI-SPEC requires (not in `send_cubit` verbatim — Send has no such cap):
`if (rawAmount > payingSideBalanceMinions) { amountError: '{Main/Child} doesn't have that much GNUS.'; }`

---

### `lib/child_wallets/child_operation_switch_dialog.dart` (component, request-response)

**Analog:** `lib/account/sdk_account_manager.dart`'s await-the-real-signal tail (lines 415-418, read above), adapted to `AppState.selectedSDKAccount`:
```dart
bloc.add(SelectSDKAccount(requiredAccount));
final landed = await bloc.stream
    .map((s) => s.selectedSDKAccount == requiredAccount)
    .firstWhere((ok) => ok, orElse: () => false)
    .timeout(const Duration(seconds: 3), onTimeout: () => false);
```
Same `GWDialog`/`GWDialogAction` chrome as the delete-confirm dialog above. The SWT-06-refused
variant (single "OK" action, no `Cancel`) still uses `GWDialogAction` — just one entry in the list.

---

### `lib/child_wallets/child_main_picker_dialog.dart` (component, request-response)

**Analog:** `lib/account/sdk_account_manager.dart`'s `_AddAccountDialog` (method-toggle idiom, ~594-707) and `_PayoutAddressForm` (~761-792) — read the file's own inventory citation; core shape to copy is a `StatefulWidget` with an internal mode enum (`list` / `manualEntry`) swapped via `setState`, list rendered as `GWSelectRow`s with a `selected` field, manual mode showing a `GWTextField` with live `onChanged` validation and a "‹ Back" link that returns to `list` mode without discarding a prior selection.

**Address validation — do NOT reuse `isEvmAddress`** (per RESEARCH.md's correction): the SGNUS format is `0x` + 128 hex, distinct from `isEvmAddress`'s 42-char EVM check used elsewhere in this exact file (`lib/utils/wallet_utils.dart:7-11`, used at `sdk_account_manager.dart:456`). Write a new regex `^0x[0-9a-fA-F]{128}$` (case-insensitive) local to this dialog file — there is no existing SGNUS validator to copy.

---

### `lib/components/data/gw_row_badge.dart` (component, transform) — promotion, not a rewrite

**Analog:** `lib/account/account_drawer.dart`'s `_RowBadge` (lines 144-173, read above) — copy the whole class body unchanged into the new file, make it public (`GWRowBadge`), update the three existing call sites in `account_drawer.dart` to import it, and add the two new call sites in `lib/child_wallets/` with `color: gw.statusWarningText`. No visual or API change — this is a file move plus a rename, exactly as `35-UI-SPEC.md` already did for `_AccountSectionHeader`/`_AccountSectionNote`.

---

### `lib/child_wallets/child_wallets_screen.dart` extension (component, request-response)

**Analog:** `lib/account/sdk_account_manager.dart`'s `SDKAccountRow` `MenuAnchor` + `_menuItem` (lines 115-225, read above).

**Menu shape to copy verbatim, `onPressed: null` as the disabled mechanism** (lines 115-132, 198-220):
```dart
action: MenuAnchor(
  builder: (context, controller, child) => IconButton(
    icon: GWIcon.material(Icons.more_vert, color: gw.textSecondary),
    tooltip: 'Child actions',
    onPressed: () => controller.isOpen ? controller.close() : controller.open(),
  ),
  menuChildren: [
    _menuItem(gw, icon: ..., label: 'Fund', onPressed: locked ? null : () => ...),
    // 'Recover', 'Revoke' likewise
  ],
);
Widget _menuItem(GWColors gw, {required IconData icon, required String label, required VoidCallback? onPressed, bool danger = false}) {
  final enabled = onPressed != null;
  final fg = !enabled ? gw.textSecondary.withValues(alpha: 0.5) : (danger ? gw.statusErrorText : gw.textPrimary);
  return MenuItemButton(
    leadingIcon: GWIcon.material(icon, color: fg),
    style: MenuItemButton.styleFrom(foregroundColor: fg, disabledForegroundColor: fg),
    ...
  );
}
```
Wrap each disabled `MenuItemButton` in a `Tooltip(message: lockReason)` per UI-SPEC's Locks table — `sdk_account_manager.dart` disables but does not tooltip today; this phase adds that (AGENTS.md: disabled states need a visible reason, not just dimming).

---

### `lib/account/account_drawer.dart` extension — `SDKAccountRow.lockedReason` (component, request-response)

**Analog:** same file's own `_menuItem` disabled-foreground treatment (`sdk_account_manager.dart:210-212`, cross-file reuse) applied to a WHOLE row for the first time:
```dart
final fg = !enabled ? gw.textSecondary.withValues(alpha: 0.5) : (danger ? gw.statusErrorText : gw.textPrimary);
```
Combine with a `Tooltip(message: lockedReason)` wrap and swap `onTap`'s `SelectSDKAccount` dispatch for a `showToast(..., type: ToastType.warning)` call, mirroring the existing lightweight "SDK account selected" toast at `sdk_account_manager.dart:76-81`.

---

### `lib/dev/dev_mock_child_wallets.dart` extension (utility, event-driven)

**Analog:** the file's own existing read-preset gate, consumed at `child_wallets_cubit.dart:82-88,106-108,111-116` (read above) — a `ValueNotifier<Preset?>` the cubit listens to and reads on each `refresh()`. Add `DevChildWalletsWriteMode { confirm, timeout, fail }` as a second, orthogonal `ValueNotifier`, read the same way from `ChildOperationsCubit.resolve()`'s dev-gated branch — `kDebugMode && kShowDevTools`, identical to line 106.

---

### `lib/dev/dev_tools_bubble.dart` extension (component, event-driven)

**Analog:** same file, existing `_devButton` calls in the CHILD WALLETS `_Section` (~1181-1253, per UI-SPEC citation) — append three more `_devButton` calls with the same `Wrap` layout and tooltip-register-of-record style, no new widget shape.

---

### `lib/main.dart` extension (config, event-driven)

**Analog:** same file's existing `MultiBlocProvider` entry for `AppBloc` (~408-421, per UI-SPEC citation) — add `BlocProvider<ChildOperationsCubit>(create: (_) => ChildOperationsCubit(...))` immediately after it, so both the `/child-wallets` screen and `account_drawer.dart`'s switcher rows read the same instance via `context.watch`/`context.read`.

## Shared Patterns

### Dialog chrome
**Source:** `lib/components/overlays/gw_dialog.dart` (`GWDialog`/`GWDialogAction`)
**Apply to:** all 8 new dialogs (6 write dialogs + switch dialog + main picker) — no new dialog widget is ever built, only new `title`/`message`/`content`/`actions` arguments.

### Root-navigator-before-dialog idiom
**Source:** `lib/account/sdk_account_manager.dart:440-441` (`Navigator.of(context, rootNavigator: true)` captured, then the triggering surface popped)
**Apply to:** every dialog opened from the child row's `MenuAnchor` or the "This account" card's buttons.

### Await-the-real-signal, never trust a dispatch
**Source:** `lib/account/sdk_account_manager.dart:415-418` (`bloc.stream.map(...).firstWhere(...).timeout(...)`)
**Apply to:** `child_operation_switch_dialog.dart` (D-06's `SelectSDKAccount` wait) — the only new-code use of this exact idiom, since the six write submissions are synchronous FFI calls, not bloc round-trips.

### Submit-consumes-return-value-once
**Source:** RESEARCH.md Pattern 1, `packages/genius_api/lib/src/genius_api.dart:1749`
**Apply to:** all six write dialogs' submit handlers — `GENIUS_NODE_RET_OK` → `registry.start(...)`; anything else → immediate `ToastType.error`, never pending.

### Disabled-item dim + tooltip
**Source:** `lib/account/sdk_account_manager.dart:210-212` (`_menuItem`'s `fg` computation)
**Apply to:** PEND-02 locked menu items (`child_wallets_screen.dart`) and SWT-06 locked switcher rows (`account_drawer.dart`) — same foreground math, now paired with a `Tooltip` naming the reason on both surfaces.

### Exact-decimal amount validation
**Source:** `lib/send/send_cubit.dart:498-522`
**Apply to:** Fund/Recover dialogs, with `decimals=6`, `symbol='GNUS'`, plus a new balance-cap check `send_cubit.dart` doesn't need.

## No Analog Found

| File | Role | Data Flow | Reason |
|---|---|---|---|
| SGNUS address validator (inline in `child_main_picker_dialog.dart`) | utility | transform | No existing `0x`+128-hex validator in the codebase — `isEvmAddress` is the wrong shape (42-char EVM) per RESEARCH.md's explicit correction; write a small new regex, not a reusable util unless a second caller appears (Rule of Three). |

## Metadata

**Analog search scope:** `lib/child_wallets/`, `lib/account/`, `lib/send/`, `lib/dev/`, `lib/components/overlays/`, `lib/main.dart`
**Files scanned:** `child_wallets_cubit.dart`, `child_wallets_screen.dart`, `sdk_account_manager.dart`, `account_drawer.dart`, `send_cubit.dart`, `send_screen.dart`, `dev_mock_child_wallets.dart`, `dev_tools_bubble.dart`, `gw_dialog.dart`
**Pattern extraction date:** 2026-09-29
