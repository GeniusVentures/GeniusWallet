import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/cards/gw_select_row.dart';
import 'package:genius_wallet/components/feedback/gw_warning_note.dart';
import 'package:genius_wallet/components/gw_icon.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/components/overlays/gw_dialog.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';
import 'package:genius_wallet/theme/nav_chip_style.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/utils/secret_clipboard.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// A widget that shows the currently selected SDK account and opens a drawer
/// for managing SDK accounts (select, add, delete).
///
/// This is separate from [AccountDropdownSelector] because it manages the
/// native SDK's account list rather than the app's wallet list. The SDK
/// account determines which identity the node uses for processing and
/// minting operations.
class SDKAccountManagerButton extends StatelessWidget {
  const SDKAccountManagerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final selected = state.selectedSDKAccount;
        final accounts = state.sdkAccounts;

        if (accounts.isEmpty) {
          return const SizedBox.shrink();
        }

        return Tooltip(
          message: 'SDK Accounts',
          child: TextButton(
            style: navContextChipStyle(context),
            onPressed: () => _showSDKAccountDrawer(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: GeniusWalletConsts.space4,
              children: [
                const GWIcon.material(Icons.settings_applications),
                if (MediaQuery.sizeOf(context).width >= GeniusBreakpoints.small)
                  Text(
                    selected != null
                        ? WalletUtils.getAddressForDisplay(selected)
                        : 'No account',
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                const GWIcon.material(Icons.arrow_drop_down),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showSDKAccountDrawer(BuildContext context) async {
    await ResponsiveDrawer.show(
      context: context,
      // Owns a scrolling viewport: the inset lives on the list so it scrolls
      // with the content and rows still reach the panel edge (kDrawerBodyPadding).
      bodyPadding: EdgeInsets.zero,
      // Sketch 068-A: the title is the SHELL's again. This drawer used to omit
      // it and render `BottomDrawer` inside instead -- a second header with a
      // CENTRED title and the ✕ on the LEFT, where the other eighteen drawers
      // have it top-right. That was a stand-off until 156-A, which turned it
      // into a visible defect: the panel is `surfaceElevated` #0C0E14 and
      // `BottomDrawer` paints itself `surfaceMenu` #171A21, so the header
      // became a lighter block sitting inside its own drawer.
      title: 'SDK Accounts',
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          final accounts = state.sdkAccounts;
          final selected = state.selectedSDKAccount;
          // Fail-soft read: registers the InheritedWidget dependency that
          // forces this content to rebuild on a live appearance toggle
          // (04-02 D-02).
          final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

          if (accounts.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(GeniusWalletConsts.space10),
              child: Text(
                'No SDK accounts available.\nAdd one to get started.',
                textAlign: TextAlign.center,
                style: GeniusWalletTypography.bodyMd.copyWith(
                  color: gw.textSecondary,
                ),
              ),
            );
          }

          // The inset lives on the scrolling viewport, so it scrolls with the
          // content and the rows still reach the panel edge
          // (kDrawerBodyPadding's documented opt-out).
          return ListView(
            padding: const EdgeInsets.all(GeniusWalletConsts.space10),
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: GeniusWalletConsts.space6,
                ),
                child: Text(
                  'Select the account the SDK uses for processing:',
                  style: GeniusWalletTypography.labelMd.copyWith(
                    color: gw.textSecondary,
                  ),
                ),
              ),
              // No separators: GWSelectRow carries its own bottom margin.
              for (final account in accounts)
                _buildAccountRow(
                  context,
                  account,
                  isSelected: account == selected,
                ),
            ],
          );
        },
      ),
      // ONE CTA, not two (sketch 069-A). Two `Expanded` buttons in a 420px
      // panel get 420 - 40 padding - 8 gap = 186px each, and "Add with private
      // key" plus its 20px leading icon needs about 210 -- so BOTH labels were
      // silently ellipsized to "Add with mn…" and "Add with priv…". Nothing was
      // misconfigured; the layout was asking for more room than exists.
      //
      // The mnemonic/private-key choice moved INTO the dialog, where it is one
      // segmented control rather than two competing CTAs, and where both paths
      // can share one warning and one field.
      footer: GWButton(
        label: 'Add account',
        leading: const GWIcon.material(Icons.add),
        variant: GWButtonVariant.gradient,
        size: GWButtonSize.lg,
        expand: true,
        onPressed: () => _showAddAccountDialog(context),
      ),
    );
  }

  Widget _buildAccountRow(
    BuildContext context,
    String address, {
    required bool isSelected,
  }) {
    // Fail-soft read: registers the InheritedWidget dependency (on the
    // per-row context passed in from the drawer's own itemBuilder, NOT the
    // widget-level this.context) that forces this row to rebuild on a live
    // appearance toggle while the drawer stays open (04-02 D-02).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    final mnemonic = context.read<AppBloc>().api.getSelectedAccountMnemonic();
    final can = sdkRowActions(
      isSelected: isSelected,
      hasMnemonic: mnemonic != null,
    );

    // Sketch 068-A. This was a `GWCard` whose selected state was a 2px brand
    // border -- which also meant the row's geometry changed by 1px on each side
    // when it became selected. `GWSelectRow` keeps its border width constant
    // and says "selected" with the tint, the brand edge and the check glyph,
    // the same three the token picker uses.
    return GWSelectRow(
      selected: isSelected,
      onTap: () {
        if (!isSelected) {
          context.read<AppBloc>().add(SelectSDKAccount(address));
          showToast(
            context,
            'SDK account selected',
            duration: const Duration(seconds: 1),
          );
        }
      },
      leading: GWIcon.material(
        Icons.account_balance_wallet,
        color: isSelected ? context.gw.brandPrimaryStrong : gw.textSecondary,
      ),
      // The address IS the title here, so it takes the mono treatment through
      // the row's own escape hatch rather than a hand-built Column.
      title: WalletUtils.getAddressForDisplay(address),
      titleStyle: GeniusWalletTypography.bodySm.copyWith(
        fontFamily: GeniusWalletTypography.monoFamily,
        color: gw.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      subtitle: isSelected ? 'Active processing account' : null,
      // ONE menu on EVERY row (sketch 069-A). Before this, the selected row got
      // a three-item menu and every OTHER row got a bare red delete
      // `IconButton` and no menu at all -- so Delete was never IN the menu, the
      // menu never appeared on a row you could delete, and the code's own
      // guard ("Cannot delete the currently selected SDK account") could never
      // fire from the UI, because the button it guards was not rendered there.
      //
      // Inapplicable items are DISABLED, not absent, so the menu keeps one
      // shape and one order whichever row you open it on.
      // No local `MenuStyle`: the container's fill, shape and surface tint are
      // `theme.dart`'s `menuTheme`, and its label typography is
      // `menuButtonTheme`. Both call sites used to duplicate this under a
      // comment claiming the theme supplied no menuTheme -- it always did.
      action: MenuAnchor(
        builder: (context, controller, child) => IconButton(
          icon: GWIcon.material(Icons.more_vert, color: gw.textSecondary),
          tooltip: 'Account options',
          onPressed: () =>
              controller.isOpen ? controller.close() : controller.open(),
        ),
        menuChildren: [
          _menuItem(
            gw,
            icon: Icons.edit_location_alt,
            label: 'Set payout address',
            // The SDK sets the payout address on the CURRENTLY SELECTED
            // account, so this is meaningless on any other row.
            onPressed: can.payout
                ? () => _showSetPayoutAddressDialog(context)
                : null,
          ),
          _menuItem(
            gw,
            icon: Icons.numbers,
            label: 'Copy recovery phrase',
            // Two gates, both real: the SDK only exposes the SELECTED
            // account's mnemonic, and an account imported from a private key
            // has no phrase at all.
            onPressed: can.phrase
                ? () => _copyMnemonic(context, mnemonic!)
                : null,
          ),
          _menuItem(
            gw,
            icon: Icons.qr_code,
            label: 'Show recovery QR',
            onPressed: can.qr
                ? () => _showMnemonicQr(context, mnemonic!)
                : null,
          ),
          const Divider(height: 9, indent: 12, endIndent: 12),
          _menuItem(
            gw,
            icon: Icons.delete_outline,
            label: 'Delete account',
            danger: true,
            // Disabled, not hidden. `GeniusApi.deleteAccount`'s own doc says
            // the SDK refuses to delete the selected account, so this is the
            // rule made visible rather than a new one invented here.
            onPressed: can.delete
                ? () => _confirmDeleteSDKAccount(context, address)
                : null,
          ),
        ],
      ),
    );
  }

  /// One menu row, so the four items cannot drift in icon size, colour or
  /// disabled treatment. `onPressed: null` is Material's own disabled state -
  /// nothing here fakes it with opacity.
  Widget _menuItem(
    GWColors gw, {
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool danger = false,
  }) {
    final enabled = onPressed != null;
    // The icon has to be dimmed HERE. `MenuItemButton` disables its own
    // foreground, but `leadingIcon` is a widget we hand it -- so a disabled
    // "Delete account" rendered a greyed label beside a full-strength red
    // trash glyph, which is exactly how it looked on the walk.
    final fg = !enabled
        ? gw.textSecondary.withValues(alpha: 0.5)
        : (danger ? gw.statusError : gw.textPrimary);
    return MenuItemButton(
      leadingIcon: GWIcon.material(icon, color: fg),
      style: MenuItemButton.styleFrom(
        foregroundColor: fg,
        // Without this, Material substitutes its own onSurface@38% for the
        // disabled label and the row disagrees with its own icon again.
        disabledForegroundColor: fg,
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }

  /// A seed phrase leaving the app deserves a word about it. This used to be
  /// `onPressed: () => {Clipboard.setData(...)}` and nothing else - no
  /// confirmation, no feedback - while every other copy in the app says
  /// "Address copied to clipboard". This is the one value where a silent
  /// clipboard write is a security event rather than a convenience.
  Future<void> _copyMnemonic(BuildContext context, String mnemonic) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    Navigator.of(context).pop();

    final confirmed = await GWDialog.show<bool>(
      context: navigator.context,
      title: 'Copy recovery phrase?',
      message:
          'Anyone who reads your clipboard gets full control of this account. '
          'Paste it where you need it and clear the clipboard afterwards.',
      actions: [
        GWDialogAction(label: 'Cancel', onPressed: () => navigator.pop(false)),
        GWDialogAction(
          label: 'Copy',
          variant: GWButtonVariant.primary,
          onPressed: () => navigator.pop(true),
        ),
      ],
    );

    if (confirmed != true) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: mnemonic));
    // The other half of the confirmation above: the dialog makes the exposure
    // deliberate, this ends it. Conditional, so a value the user copies in the
    // meantime survives.
    scheduleSecretClipboardClear(mnemonic);
    unawaited(HapticFeedback.lightImpact());
    if (navigator.context.mounted) {
      // `navigator.context` is the ROOT navigator's and outlives the popped
      // drawer, so the guard above is the correct one -- the analyzer
      // cannot see that and reads it as unrelated to this context.
      showToast(
        // ignore: use_build_context_synchronously
        navigator.context,
        'Recovery phrase copied to clipboard',
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// The recovery QR. Was the only dialog in this section still a raw
  /// `AlertDialog` with a stock `TextButton`; it is `GWDialog` now.
  ///
  /// The WHITE backdrop behind the code stays and is deliberately
  /// mode-invariant: a QR needs a light quiet zone to scan, so it is not
  /// routed through GWColors (03-GAP-INVENTORY §6).
  Future<void> _showMnemonicQr(BuildContext context, String mnemonic) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    Navigator.of(context).pop();

    await GWDialog.show<void>(
      context: navigator.context,
      title: 'Recovery phrase QR',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const GWWarningNote(
            'Anyone who photographs this code gets full control of the '
            'account. Do not show it on a shared or recorded screen.',
          ),
          const SizedBox(height: GeniusWalletConsts.space6),
          // Self-contained, exactly as `CryptoAddressQR` (sketch 034-A2) does
          // it: the QR carries its own size and its own white backing. The old
          // shape here was a `SizedBox(width: GeniusBreakpoints.small * 0.5)`
          // around a white `Container` - a BREAKPOINT constant used as a pixel
          // width, and a caller-supplied wrapper to shrink the code. That is
          // the exact pattern `crypto_address_qr.dart` records having already
          // fixed once ("no longer depends on the caller's wrapping SizedBox").
          //
          // `Colors.white` is deliberate and mode-invariant in both files: a
          // camera needs a light quiet zone, so this is NEVER an appearance
          // token.
          QrImageView(
            data: mnemonic,
            version: QrVersions.auto,
            size: 190,
            backgroundColor: Colors.white,
          ),
        ],
      ),
      actions: [
        GWDialogAction(label: 'Done', onPressed: () => navigator.pop()),
      ],
    );
  }

  /// The `isSelected` guard that used to live here is gone: the menu no longer
  /// offers Delete on the active account at all, so a guard here could never
  /// fire. The SDK's own refusal is still the real rule -- see the disabled
  /// item in `_menuItem` above.
  Future<void> _confirmDeleteSDKAccount(
    BuildContext context,
    String address,
  ) async {
    final bloc = context.read<AppBloc>();
    final navigator = Navigator.of(context, rootNavigator: true);
    Navigator.of(context).pop();

    final confirmed = await GWDialog.show<bool>(
      context: navigator.context,
      title: 'Delete SDK account',
      message:
          'The SDK will stop being able to sign with '
          '${WalletUtils.getAddressForDisplay(address)}. If you have no copy '
          'of its recovery phrase, this account cannot be restored.',
      actions: [
        GWDialogAction(label: 'Cancel', onPressed: () => navigator.pop(false)),
        GWDialogAction(
          label: 'Delete account',
          // Mode-invariant statusError destructive fill -- never
          // Colors.red/redAccent, never routed through GWColors.
          variant: GWButtonVariant.destructive,
          onPressed: () => navigator.pop(true),
        ),
      ],
    );

    if (confirmed != true) {
      return;
    }

    bloc.add(DeleteSDKAccount(address));

    // The old code said "SDK account deleted" UNCONDITIONALLY, one line after
    // dispatching and without checking anything -- and `_onDeleteSDKAccount`
    // emits only on `GENIUS_NODE_RET_OK` with no else branch, so a refusal was
    // silent at both layers and the user was told a delete worked when it had
    // not.
    //
    // The bloc exposes no error for this, so the observable truth is whether
    // the address left the list. The timeout is the "nothing happened" case,
    // which is exactly the refusal we could not see before.
    final removed = await bloc.stream
        .map((s) => !s.sdkAccounts.contains(address))
        .firstWhere((gone) => gone)
        .timeout(const Duration(seconds: 3), onTimeout: () => false);

    if (!navigator.context.mounted) {
      return;
    }
    // `navigator.context` is the ROOT navigator's and outlives the popped
    // drawer, so the guard above is the correct one -- the analyzer
    // cannot see that and reads it as unrelated to this context.
    showToast(
      // ignore: use_build_context_synchronously
      navigator.context,
      removed
          ? 'SDK account deleted'
          : 'The SDK refused to delete that account.',
      duration: Duration(seconds: removed ? 1 : 3),
    );
  }

  /// ONE dialog for both import paths (sketch 069-A). There used to be two,
  /// opened by two footer buttons that could not fit their own labels; they
  /// differed only in a hint string and which bloc event they fired, and each
  /// carried its own copy of the IME hardening. One dialog means one warning,
  /// one field and one place to get the security flags right.
  ///
  /// SECURITY (V6): this dialog handles key material. `GWTextField` is a pure
  /// presentation wrapper around the SAME `TextEditingController` -- it never
  /// reads or logs the value; the value flows straight from
  /// `controller.text.trim()` into the bloc event.
  Future<void> _showAddAccountDialog(BuildContext context) async {
    final controller = TextEditingController();
    // Owned here, so the footer action can read the switch the body owns --
    // the same pattern Swap Settings uses to keep its Apply honest about a
    // form it is a sibling of, not a parent.
    final usePhrase = ValueNotifier<bool>(true);
    final bloc = context.read<AppBloc>();
    final navigator = Navigator.of(context, rootNavigator: true);

    final result =
        await GWDialog.show<({bool phrase, String value})>(
          context: context,
          title: 'Add account',
          content: _AddAccountForm(
            controller: controller,
            usePhrase: usePhrase,
          ),
          actions: [
            GWDialogAction(label: 'Cancel', onPressed: () => navigator.pop()),
            GWDialogAction(
              label: 'Add account',
              variant: GWButtonVariant.primary,
              onPressed: () => navigator.pop((
                phrase: usePhrase.value,
                value: controller.text.trim(),
              )),
            ),
          ],
        ).whenComplete(() {
          controller.dispose();
          usePhrase.dispose();
        });

    if (result == null || result.value.isEmpty || !context.mounted) {
      return;
    }

    bloc.add(
      result.phrase
          ? AddSDKAccountWithMnemonic(result.value)
          : AddSDKAccountWithPrivateKey(result.value),
    );
    // Refresh after a short delay to let the SDK process the addition.
    await Future.delayed(const Duration(milliseconds: 500));
    if (!context.mounted) {
      return;
    }
    bloc.add(RefreshSDKAccounts());
    showToast(
      context,
      'Account added successfully',
      duration: const Duration(seconds: 1),
    );
  }

  Future<void> _showSetPayoutAddressDialog(BuildContext context) async {
    final controller = TextEditingController();
    final bloc = context.read<AppBloc>();
    final navigator = Navigator.of(context, rootNavigator: true);
    Navigator.of(context).pop();

    final payoutAddress = await GWDialog.show<String>(
      context: navigator.context,
      title: 'Set payout address',
      message: 'Processing rewards for this account are paid here.',
      content: _PayoutAddressForm(controller: controller),
      actions: [
        GWDialogAction(label: 'Cancel', onPressed: () => navigator.pop()),
        GWDialogAction(
          label: 'Set address',
          variant: GWButtonVariant.primary,
          onPressed: () {
            // Validation the field never had: it used to post any string at
            // all, and the SDK's rejection came back as an opaque enum name.
            if (!isEvmAddress(controller.text)) {
              return;
            }
            navigator.pop(controller.text.trim());
          },
        ),
      ],
    );

    if (payoutAddress == null || payoutAddress.isEmpty) {
      return;
    }

    bloc.add(SetSDKPayoutAddress(payoutAddress));

    // AWAIT the next state. The old code read `state.setPayoutAddressResult`
    // synchronously on the line after `add(...)`, and a bloc processes events
    // asynchronously -- so it reported the PREVIOUS attempt's result, or
    // "Failed to set payout address: null" on the first call after a start.
    final result = await bloc.stream
        .map((s) => s.setPayoutAddressResult)
        .first
        .timeout(const Duration(seconds: 5), onTimeout: () => null);

    if (!navigator.context.mounted) {
      return;
    }
    final ok = result == GeniusNodeReturnValue.GENIUS_NODE_RET_OK;
    // `navigator.context` is the ROOT navigator's and outlives the popped
    // drawer, so the guard above is the correct one -- the analyzer
    // cannot see that and reads it as unrelated to this context.
    showToast(
      // ignore: use_build_context_synchronously
      navigator.context,
      ok
          ? 'Payout address set'
          : 'The SDK refused that payout address'
                '${result == null ? '' : ' (${result.name})'}.',
      duration: Duration(seconds: ok ? 1 : 3),
    );
  }
}

/// Which of the row menu's four actions are available, as a rule rather than
/// four conditions spread through a widget tree.
///
/// The gates are not cosmetic. **`GeniusSDKGetMnemonic` returns the SELECTED
/// account's phrase**, so offering Copy or QR on any other row would show one
/// account's recovery phrase under another account's address. And an account
/// imported from a private key has no phrase at all, which is why
/// [hasMnemonic] is separate from [isSelected].
///
/// Delete inverts: the SDK refuses to delete the account it is currently
/// using (`GeniusApi.deleteAccount`'s own doc), so the active row is the one
/// row where it must be off.
({bool payout, bool phrase, bool qr, bool delete}) sdkRowActions({
  required bool isSelected,
  required bool hasMnemonic,
}) => (
  payout: isSelected,
  phrase: isSelected && hasMnemonic,
  qr: isSelected && hasMnemonic,
  delete: !isSelected,
);

/// A 42-character `0x`-prefixed hex address. Deliberately not a checksum test:
/// the SDK does that, and rejecting a valid lowercase address because it is not
/// EIP-55 cased would be worse than the no-validation this replaces.
bool isEvmAddress(String raw) {
  final v = raw.trim();
  return RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(v);
}

/// The merged add-account body: pick the import method, then paste.
///
/// The method switch is built to `CONVENTIONS.md`'s **Control track** recipe
/// (`surfaceSunken` fill, `borderSubtle` hairline, `radiusPill`, 3px track
/// padding, 2px chip gap) rather than to a component, because there is no
/// component - there are FIVE private implementations of this recipe already
/// (`_TimeframeSegment` twice, the transactions filter track, `_PresetChip`,
/// and now this). A todo is filed; building `GWSegmentedControl` for one
/// consumer would fail the promotion test 065 and 068 both used.
class _AddAccountForm extends StatefulWidget {
  const _AddAccountForm({required this.controller, required this.usePhrase});

  final TextEditingController controller;
  final ValueNotifier<bool> usePhrase;

  @override
  State<_AddAccountForm> createState() => _AddAccountFormState();
}

class _AddAccountFormState extends State<_AddAccountForm> {
  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    return ValueListenableBuilder<bool>(
      valueListenable: widget.usePhrase,
      builder: (context, phrase, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: gw.surfaceSunken,
              border: Border.all(color: gw.borderSubtle),
              borderRadius: BorderRadius.circular(
                GeniusWalletConsts.radiusPill,
              ),
            ),
            child: Row(
              children: [
                _modeChip('Recovery phrase', selected: phrase, value: true),
                const SizedBox(width: 2),
                _modeChip('Private key', selected: !phrase, value: false),
              ],
            ),
          ),
          const SizedBox(height: GeniusWalletConsts.space6),
          if (phrase) ...[
            const GWWarningNote(
              'Anyone with this phrase controls the account. Only paste one '
              'you own.',
            ),
            const SizedBox(height: GeniusWalletConsts.space6),
          ],
          GWTextField(
            controller: widget.controller,
            label: phrase ? 'Recovery phrase' : 'Private key',
            hint: phrase
                ? 'Paste 12 or 24 words, separated by spaces'
                : 'Paste the Ethereum private key (hex)',
            maxLines: phrase ? 4 : 1,
            // The brand gradient on focus, not the flat `brandPrimaryStrong`
            // stroke `focusedBorder` draws -- "no flat blue as the accent" is
            // the app's rule and this is the state it matters most in.
            focusRing: true,
            // Recessed on the dialog's own `surfaceElevated`, the same call the
            // drawer fields took: at `surfaceElevated` the field would be
            // painted its own background's colour.
            fill: gw.surfaceSunken,
            // IME hardening (06-04 §3.6) -- do not remove.
            // `enableIMEPersonalizedLearning` is the one that maps to
            // Android's IME_FLAG_NO_PERSONALIZED_LEARNING; the other three do
            // not close the keyboard learning-store leak on their own. It was
            // duplicated across the two dialogs this replaces; now it is one
            // place, which is most of why merging them was worth doing.
            autocorrect: false,
            enableSuggestions: false,
            enableIMEPersonalizedLearning: false,
            textCapitalization: TextCapitalization.none,
          ),
        ],
      ),
    );
  }

  Widget _modeChip(
    String label, {
    required bool selected,
    required bool value,
  }) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusPill),
        onTap: selected
            ? null
            : () {
                // Switching method clears the field: a mnemonic left in the
                // box while the label says "Private key" is the kind of thing
                // that gets pasted into the wrong import.
                widget.controller.clear();
                widget.usePhrase.value = value;
              },
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: selected ? GeniusWalletGradient.brandCta : null,
            borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusPill),
          ),
          child: Text(
            label,
            style: GeniusWalletTypography.labelMd.copyWith(
              color: selected ? context.gw.textOnBrand : gw.textSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/// The payout field, with the validation it never had. Live rather than
/// on-submit: a 42-character address is not something anyone re-reads after
/// being told "invalid".
class _PayoutAddressForm extends StatefulWidget {
  const _PayoutAddressForm({required this.controller});

  final TextEditingController controller;

  @override
  State<_PayoutAddressForm> createState() => _PayoutAddressFormState();
}

class _PayoutAddressFormState extends State<_PayoutAddressForm> {
  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text.trim();
    // Empty is neutral, not wrong -- the same rule the slippage field follows.
    final invalid = text.isNotEmpty && !isEvmAddress(text);
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return GWTextField(
      controller: widget.controller,
      label: 'Payout address',
      hint: '0x…',
      focusRing: true,
      fill: gw.surfaceSunken,
      errorText: invalid
          ? 'Not a complete address - 42 characters starting with 0x.'
          : null,
      onChanged: (_) => setState(() {}),
      autocorrect: false,
      enableSuggestions: false,
      textCapitalization: TextCapitalization.none,
    );
  }
}
