> **Superseded naming (read first):** the plans keep the class `AccountDrawer` in `lib/account/account_drawer.dart` instead of a new `AccountSwitcherDrawer` file, so `more_sheet.dart` and `wallet_overview.dart` need no edits. Where a snippet below says `AccountSwitcherDrawer`, read `AccountDrawer`. The plans are authoritative.

# Phase 35: Unified header switcher - Pattern Map

**Mapped:** 2026-09-29
**Files analyzed:** 10
**Analogs found:** 10 / 10 (every new file is a merge of two files that already exist — this phase has no "no analog" case)

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `lib/account/account_switcher.dart` (new) | component (header trigger) | request-response (opens drawer) | `lib/account/account_dropdown_selector.dart` (deleted after) | exact — same widget shape, superset of state |
| `lib/account/account_switcher_drawer.dart` (new) | component (drawer body + static `show()`) | CRUD (select/create/delete wallet & SDK account) | `lib/account/account_drawer.dart` + `lib/account/sdk_account_manager.dart` | exact — literal merge of two existing bodies |
| `lib/account/account_section_widgets.dart` (new, promoted) | component (shared private widgets) | transform (pure render) | `_AccountSectionHeader`/`_AccountSectionNote`/`_RowBadge` inside `account_drawer.dart` | exact — verbatim promotion, no logic change |
| `lib/components/overlay/responsive_overlay.dart` (modify) | component (action-row composition) | request-response | itself, `_buildActionRowWidgets` lines 22-87 | exact — in-place edit |
| `lib/components/overlay/mobile_header.dart` (modify) | component (`WalletPill.onTap`) | request-response | itself, line 432 | exact — one-line repoint |
| `lib/components/overlay/more_sheet.dart` (modify) | component (menu row) | request-response | itself, line 69 | exact — one-line repoint |
| `lib/components/wallet_overview.dart` (modify) | component (compute panel link) | request-response | itself, line 112 | exact — one-line repoint |
| `lib/reown/send_transaction_details.dart` (modify) | component | request-response | itself, line 78 (`GWCopyRow` call) | exact |
| `lib/components/data/gw_copy_row.dart` (modify) | component (data display) | transform | itself | exact — additive optional field |
| `lib/squid_router/swap_screen.dart` (modify) | component (screen) | request-response | itself, `_buildSwapCta` / compute panel's `_SublineRow` pattern (Phase 14, `wallet_overview.dart`) | role-match for the new sub-line + link shape |
| `lib/send/send_screen.dart` (modify) | component (screen) | request-response | itself, `_review()` lines 251-284 | exact |
| `lib/account/sdk_account_manager.dart` (modify: export dialog) | service/utility (dialog entry) | request-response | itself — `_AddAccountDialog` private class | exact — visibility change only |
| test files (5, listed below) | test | — | themselves | exact — pinned-string updates, not new tests |

## Pattern Assignments

### `lib/account/account_switcher.dart` (new)

**Analog:** `lib/account/account_dropdown_selector.dart` (full file, 74 lines — read this session)

**Imports pattern** (lines 1-11 of the analog):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/account/account_drawer.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/nav_chip_style.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
```
Swap the `account_drawer.dart` import for `account_switcher_drawer.dart`; everything else carries over unchanged.

**Core pattern — chip shell + two-source state** (lines 16-72, analog): `TextButton` with `navContextChipStyle(context)`, `Row(mainAxisSize: min, spacing: space4)` of `[AccountAvatar, Flexible(Text, hidden below GeniusBreakpoints.small), Icon(arrow_drop_down)]`, wrapped in `Tooltip`. The analog reads only `AppBloc`/`WalletDetailsCubit.state.selectedWallet`; per UI-SPEC and Pitfall 3, `AccountSwitcher` needs **two** `BlocBuilder`s (or two `context.watch<T>()`) — one for `WalletDetailsCubit` (active wallet), one for `AppBloc` (SDK account name + connection state for the tooltip's second clause) — not a merged state class:
```dart
final selectedWallet = context.watch<WalletDetailsCubit>().state.selectedWallet;
final appState = context.watch<AppBloc>().state; // sdkAccountName, node-connected flag
```
**D-04 delta from the analog:** delete the analog's `if (wallets.isEmpty) return Center(...)` early-return equivalent — `AccountSwitcher` always renders the chip (no `sdkAccounts.isNotEmpty` guard either, matching the track-level change in `responsive_overlay.dart`).

**Tooltip pattern** — analog uses a static `"Select wallet"` string (line 37); replace with the D-01/D-14 composed string: `"Sending from $walletName · Node running as $sdkAccountName"` (or `"· Node not running"` when disconnected).

---

### `lib/account/account_switcher_drawer.dart` (new)

**Analogs:** `lib/account/account_drawer.dart` (`AccountDrawer.show`, lines 36-110, and `_AccountDrawerBody`'s `ownWallets` branch ~lines 580-668) + `lib/account/sdk_account_manager.dart` (`_buildAccountRow`, `sdkRowActions`).

**`show()` entry pattern** (verbatim shape to copy, `account_drawer.dart:55-109`):
```dart
static Future<Wallet?> show(
  BuildContext context, {
  bool includeNetwork = false,
}) async {
  final walletCubit = context.read<WalletDetailsCubit>();
  final networks = includeNetwork
      ? Provider.of<NetworkProvider>(context, listen: false).networks
      : const <Network>[];
  final currentNetwork = includeNetwork
      ? walletCubit.state.selectedNetwork
      : null;

  final selected = await ResponsiveDrawer.show<Wallet>(
    context: context,
    bodyPadding: EdgeInsets.zero,
    title: includeNetwork ? "Wallet and network" : "Accounts", // UNCHANGED strings — keeps existing test pins green
    child: _AccountSwitcherBody(networks: networks, currentNetwork: currentNetwork),
    footer: GWButton(
      label: 'Add wallet', // D-09 recapitalization (was 'Add Wallet')
      leading: const Icon(Icons.add),
      variant: GWButtonVariant.gradient,
      size: GWButtonSize.lg,
      expand: true,
      onPressed: () => context.push('/landing_screen', extra: true),
    ),
  );

  if (selected == null) return null;
  await walletCubit.selectWallet(selected);
  return selected;
}
```
Note the doc-comment convention in the analog (why-not-history, ≤ a few lines per AGENTS.md) — keep any new doc comment on this class equally short and free of phase/decision numbers (e.g. do not write "per D-05" in the shipped comment).

**Section composition pattern** — build two sections in one `ListView`, per UI-SPEC's ASCII layout:
```
[if includeNetwork] network field
_AccountSectionHeader('Sending from', 'Sends, swaps and balances use this wallet.')
...ownWallets rows (GWSelectRow, via _buildDrawerRow) OR _AccountSectionNote('No wallets yet.')
SizedBox(space8)
_AccountSectionHeader('Node running as', 'The GNUS node processes and earns as this account.')
...sdkAccounts rows (GWSelectRow, via _buildAccountRow) OR _AccountSectionNote('Node not running' | 'No SDK accounts yet')
SizedBox(space8)
GWButton('Add from phrase or key', secondary, sm)
```
D-06: each row's `onTap` stays independent — own-wallet rows still call `walletCubit.selectWallet(wallet)`, SDK rows still dispatch `SelectSDKAccount` — do not add a shared handler that touches both.

**"View balance" menu item pattern (D-07)** — same call shape the own-wallet row tap already uses, reached from a `MenuItemButton` instead:
```dart
onPressed: () {
  final sgnusWallet = appState.wallets.firstWhere(
    (w) => w.walletType == WalletType.sgnus &&
        w.address.toLowerCase() == account.toLowerCase(),
  );
  context.read<WalletDetailsCubit>().selectWallet(sgnusWallet);
}
```
(match style borrowed from `walletSDKBadge()`'s own lowercase-address comparison, `account_drawer.dart:139-144`).

**Error handling / validation:** none new — every dialog/toast this body opens (`_AddAccountDialog`, delete-confirm flows, `ToastManager`) is reused verbatim; do not add a new try/catch layer here.

---

### `lib/account/account_section_widgets.dart` (new, promoted)

**Analog:** `_AccountSectionHeader`, `_AccountSectionNote`, `_RowBadge` — currently private classes inside `account_drawer.dart`.

**Promotion pattern:** cut the three classes as-is (no signature change), paste into the new file, make them `public` (drop leading `_`) only insofar as needed for a second file to import them, and import from both `account_drawer.dart` (if it still exists for anything) and `account_switcher_drawer.dart`. D-08 explicitly gates this: only promote because a **second** consumer now exists — do not promote anything else in that file that stays single-consumer.

`_AccountSectionHeader` two call sites needed:
```dart
_AccountSectionHeader('Sending from', 'Sends, swaps and balances use this wallet.')
_AccountSectionHeader('Node running as', 'The GNUS node processes and earns as this account.')
```
`_AccountSectionNote` three call sites needed: `'No wallets yet.'`, `'Node not running'`, `'No SDK accounts yet'`.

---

### `lib/components/overlay/responsive_overlay.dart` (modify, lines 22-87)

**Analog:** itself — `_buildActionRowWidgets`. Delete the `if (context.watch<AppBloc>().state.sdkAccounts.isNotEmpty)` wrapper (closes the `ponytail:` note at lines 37-41) and the two `Flexible` chips (`SDKAccountManagerButton`, `AccountDropdownSelector`), replace with:
```dart
Flexible(child: AccountSwitcher()),
```
in the same slot, keeping the surrounding `_trackDivider` calls and the `NetworkDropdownSelector`/`ReownConnectButton` siblings untouched (per UI-SPEC "Desktop control track").

---

### `lib/components/overlay/mobile_header.dart` (modify, line 432)

**Analog:** itself — `WalletPill.onTap`. One-line repoint only:
```dart
onTap: () => AccountSwitcherDrawer.show(context, includeNetwork: true),
```
No change to the 44×44 `kHeaderControlSize` circle, `WalletIdentityAvatar`, or the fixed 100px header cluster width (D-02, load-bearing).

---

### `lib/components/overlay/more_sheet.dart` (line 69) and `lib/components/wallet_overview.dart` (line 112)

**Analog:** themselves. Same mechanical repoint: `AccountDrawer.show(context)` → `AccountSwitcherDrawer.show(context)`. Row/link copy at each call site ("Accounts" menu row, "Switch wallet ›" compute-panel link) is unrelated UI and stays unchanged.

---

### `lib/components/data/gw_copy_row.dart` (modify)

**Analog:** itself (full file, read this session, 139 lines).

**Additive-field pattern** (matches the file's own "call site owns the wrapper, component owns display" split):
```dart
const GWCopyRow({
  super.key,
  required this.label,
  required this.value,
  this.shorten = true,
  this.caption, // NEW — optional, default null, renders byte-identical when omitted
});

final String? caption;
```
Render `caption` (when non-null) as a `bodySm`/`textPrimary` line above the existing mono `_displayValue` Text inside the same `Flexible`/`Row` — do not touch `_displayValue`, the `Clipboard.setData` call, or the hover/toast plumbing (`GWHoverable`, `showToast`) at all; those stay byte-identical per the file's own security-property comment (full value always copied, regardless of any display option).

---

### `lib/reown/send_transaction_details.dart` (line 78) + `lib/send/send_screen.dart` (`_review()`, lines 251-284)

**Analog:** the two call sites themselves, cross-referenced via `Grep` (3 callers of `SendTransactionDetails` total — `send_screen.dart:275`, `handle_dapp_requests.dart:155`, `dev_tools_bubble.dart:966`).

**Pattern — plain caller-supplied param, no internal Provider read** (Pitfall 4 forbids the alternative):
```dart
// send_transaction_details.dart:78
GWCopyRow(label: 'From', value: fromAddress, caption: fromWalletName),
```
```dart
// send_screen.dart, inside _review(), near line 275
SendTransactionDetails(
  fromAddress: cubit.walletAddress,
  fromWalletName: cubit.walletDetailsState.selectedWallet?.walletName ?? '',
  ...
),
```
Leave `handle_dapp_requests.dart:155` and `dev_tools_bubble.dart:966` passing `fromWalletName: null`/omitted — an optional field with a `null` default must not silently gain a caption at those two sites (D-12 names only Send).

---

### `lib/squid_router/swap_screen.dart` (near line 1109-1112, `_buildSwapCta`)

**Analog:** the Phase 14 compute-panel sub-line + inline-link shape already shipped in `lib/components/wallet_overview.dart` (`_SublineRow`), reused verbatim per UI-SPEC Typography ("reuses the exact sub-line + inline link shape Phase 14 already established... rather than inventing a new pattern").

**Core pattern to copy:**
```dart
Padding(
  padding: const EdgeInsets.only(bottom: GeniusWalletConsts.space6),
  child: Row(
    children: [
      Flexible(
        child: Text(
          'Sending from ${wallet.walletName}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GeniusWalletTypography.bodySm.copyWith(color: gw.textSecondary),
        ),
      ),
      const SizedBox(width: GeniusWalletConsts.space3),
      _SwitchLink('Switch ›', onTap: () => AccountSwitcherDrawer.show(context)),
    ],
  ),
),
```
Insert directly above line 1112 (the existing CTA `GWButton`), inside the same `Column`. Active wallet is read the same way `_submitSwap()` already reads it (`context.read<WalletDetailsCubit>().state.selectedWallet`, lines 453-454) — no new accessor. No confirm step, `onPressed: _submitSwap` unchanged (D-13).

---

## Shared Patterns

### `GWSelectRow` (row shape for both sections)
**Source:** `lib/components/cards/gw_select_row.dart` — API unchanged (`leading`/`title`/`subtitle`/`trailing`/`action`/`selected`).
**Apply to:** every row in `AccountSwitcherDrawer`, both sections. Do not add a new row shape.

### `ResponsiveDrawer.show`
**Source:** `lib/components/bottom_drawer/responsive_drawer.dart:91` — side panel at `GeniusBreakpoints.medium`+, bottom sheet below.
**Apply to:** `AccountSwitcherDrawer.show`'s single call, same as today's `AccountDrawer.show`.

### `navContextChipStyle` + `Flexible`/breakpoint-hidden label
**Source:** `lib/theme/nav_chip_style.dart`, used identically in `account_dropdown_selector.dart:39` and (previously) `sdk_account_manager.dart`'s chip.
**Apply to:** `AccountSwitcher`'s `TextButton` — the one surviving chip shell.

### Address lookup by lowercase match
**Source:** `walletSDKBadge()`, `account_drawer.dart:139-144`.
**Apply to:** D-07's "View balance" sgnus-wallet lookup — same comparison style, no new index/map.

### Doc-comment discipline
**Source:** `account_drawer.dart:28-54`'s own class doc (why, not phase history) and AGENTS.md's "≤3 lines, no plan/phase numbers in source" rule.
**Apply to:** any new doc comment on `AccountSwitcher`/`AccountSwitcherDrawer` — state the constraint ("two independent selections, changing one never touches the other"), not which decision (D-06) produced it.

## No Analog Found

None. Every file in this phase is either a straight merge of two files read this session (`account_drawer.dart` + `sdk_account_manager.dart`), a one-line repoint at a callsite that already exists, or an additive/optional field on a file already read in full.

## Test Files Requiring Pinned-String Updates (not new analogs — edits to existing tests)

| Test file | Change |
|---|---|
| `test/account/account_drawer_show_test.dart:362` | `'YOUR ACCOUNTS'` → `'SENDING FROM'` |
| `test/account/account_drawer_show_test.dart:366` | `findsNothing` → assert the D-04 note text matching the fixture's seeded connection/account state |
| `test/account/account_drawer_show_test.dart:369` | `'Add Wallet'` → `'Add wallet'` |
| `test/account/account_drawer_network_section_test.dart:284,315` | `'YOUR ACCOUNTS'` → `'SENDING FROM'` |
| `test/account/account_drawer_network_section_test.dart:317` | `'Add Wallet'` → `'Add wallet'` |

`test/account/sdk_account_rows_test.dart`, `sdk_account_delete_coupling_test.dart`, `sdk_start_account_delete_test.dart`, `sdk_add_account_test.dart` need re-pointing at the new host widget only (pump `AccountSwitcherDrawer`/`AccountSwitcher` instead of `SDKAccountManagerButton`); their assertions are unchanged.

## Metadata

**Analog search scope:** `lib/account/`, `lib/components/overlay/`, `lib/components/data/`, `lib/send/`, `lib/reown/`, `lib/squid_router/`
**Files scanned:** `account_dropdown_selector.dart` (full), `account_drawer.dart` (partial, structure grepped), `sdk_account_manager.dart` (structure grepped), `gw_copy_row.dart` (full) — plus every line/file citation already verified in `35-RESEARCH.md` this session
**Pattern extraction date:** 2026-09-29
