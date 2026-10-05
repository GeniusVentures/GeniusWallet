import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/child_wallets/child_operations_cubit.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/feedback/gw_warning_note.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/components/overlays/gw_dialog.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/secret_clipboard.dart';
import 'package:genius_wallet/utils/secure_screen.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Copies the recovery phrase after a confirmation. Unlike an address copy,
/// a silent clipboard write of a seed phrase is a security event. Public: any
/// row carrying an SDK account reaches this from its own menu.
Future<void> copyRecoveryPhrase(BuildContext context, String mnemonic) async {
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

/// Shows the recovery QR. The white backdrop is deliberately mode-invariant:
/// a QR needs a light quiet zone to scan, so it does not use GWColors.
Future<void> showRecoveryQr(BuildContext context, String mnemonic) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  Navigator.of(context).pop();

  await GWDialog.show<void>(
    context: navigator.context,
    title: 'Recovery phrase QR',
    content: SecureScreen(
      child: Column(
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
    ),
    actions: [GWDialogAction(label: 'Done', onPressed: () => navigator.pop())],
  );
}

/// Confirms and deletes an SDK account. No active-account guard here: the
/// menu never offers Delete on it, and the SDK's own refusal is the real rule
/// (see the item [sdkRowActions] disables).
Future<void> confirmDeleteSDKAccount(
  BuildContext context,
  String address,
) async {
  final bloc = context.read<AppBloc>();
  // Read straight off the bloc and its own cubit - no provider lookup - so
  // the block and the wallet it names agree with what the delete itself
  // will enforce.
  final block = AppBloc.sdkDeleteBlock(
    sdkAddress: address,
    defaultAccount: bloc.state.defaultSDKAccount,
    links: bloc.state.sdkAccountLinks,
    wallets: bloc.state.wallets,
    activeWallet: bloc.walletDetailsCubit.state.selectedWallet,
  );
  final linked = AppBloc.linkedWallet(
    address,
    bloc.state.sdkAccountLinks,
    bloc.state.wallets,
  );
  // Checked again here, not only by the menu, against a fresh registrations
  // read: the menu's cached one can be stale by the time the user confirms.
  final operations = context.read<ChildOperationsCubit?>();
  final deleteLock = operations?.deleteLockReason(
    address,
    operations.ownRegistrations(),
  );
  final navigator = Navigator.of(context, rootNavigator: true);
  Navigator.of(context).pop();

  if (block == SDKDeleteBlock.defaultAccount) {
    return;
  }
  if (deleteLock != null) {
    await GWDialog.show<void>(
      context: navigator.context,
      title: 'Cannot delete this account',
      message: '$deleteLock.',
      actions: [GWDialogAction(label: 'OK', onPressed: () => navigator.pop())],
    );
    return;
  }
  if (block == SDKDeleteBlock.activeWallet) {
    await GWDialog.show<void>(
      context: navigator.context,
      title: 'Cannot delete this account',
      message:
          '"${linked?.walletName}" is your active wallet. Pick another '
          'active wallet first, then delete this account.',
      actions: [GWDialogAction(label: 'OK', onPressed: () => navigator.pop())],
    );
    return;
  }
  if (block == SDKDeleteBlock.lastWallet) {
    await GWDialog.show<void>(
      context: navigator.context,
      title: 'Cannot delete this account',
      message:
          'Deleting this account also removes "${linked?.walletName}", and '
          'you must keep at least one wallet.',
      actions: [GWDialogAction(label: 'OK', onPressed: () => navigator.pop())],
    );
    return;
  }

  final confirmed = await GWDialog.show<bool>(
    context: navigator.context,
    title: 'Delete earning account',
    message: linked != null
        ? 'This deletes the earning account and removes the wallet '
              '"${linked.walletName}" from the app. If you have no copy of '
              'its recovery phrase, neither can be restored.'
        : 'The earning account '
              '${WalletUtils.getAddressForDisplay(address)} will be removed. If you have no '
              'copy of its recovery phrase, this account cannot be restored.',
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
      .firstWhere((gone) => gone, orElse: () => false)
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
    removed ? 'Earning account deleted' : "Couldn't delete that account.",
    type: removed ? ToastType.success : ToastType.error,
    duration: Duration(seconds: removed ? 1 : 3),
  );
}

Future<void> showSetPayoutAddressDialog(BuildContext context) async {
  final controller = TextEditingController();
  final bloc = context.read<AppBloc>();
  final navigator = Navigator.of(context, rootNavigator: true);
  Navigator.of(context).pop();

  final payoutAddress = await GWDialog.show<String>(
    context: navigator.context,
    title: 'Set payout address',
    message: 'Earnings for this account are paid here.',
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

  final request = SetSDKPayoutAddress(payoutAddress);
  bloc.add(request);
  // This request's own result: any state emission, or a repeat of the last
  // result, says nothing about this attempt.
  final ok = await request.result.future
      .then((r) => r == GeniusNodeReturnValue.GENIUS_NODE_RET_OK)
      .timeout(const Duration(seconds: 5), onTimeout: () => false);

  if (!navigator.context.mounted) {
    return;
  }
  // `navigator.context` is the ROOT navigator's and outlives the popped
  // drawer, so the guard above is the correct one -- the analyzer
  // cannot see that and reads it as unrelated to this context.
  showToast(
    // ignore: use_build_context_synchronously
    navigator.context,
    ok ? 'Payout address set' : "Couldn't save that payout address.",
    type: ok ? ToastType.success : ToastType.error,
    duration: Duration(seconds: ok ? 1 : 3),
  );
}

/// Which of the row menu's five actions are available, as a rule rather than
/// five conditions spread through a widget tree.
///
/// The gates are not cosmetic. **`GeniusSDKGetMnemonic` returns the SELECTED
/// account's phrase**, so offering Copy or QR on any other row would show one
/// account's recovery phrase under another account's address. And an account
/// imported from a private key has no phrase at all, which is why
/// [hasMnemonic] is separate from [isSelected].
///
/// Delete inverts: the SDK refuses to delete the account it is currently
/// using (`GeniusApi.deleteAccount`'s own doc), and the account the app starts
/// with would be re-imported on the next start, so both rows keep it off.
({bool payout, bool phrase, bool qr, bool delete, bool childWallets})
sdkRowActions({
  required bool isSelected,
  required bool hasMnemonic,
  bool isStartAccount = false,
}) => (
  payout: isSelected,
  phrase: isSelected && hasMnemonic,
  qr: isSelected && hasMnemonic,
  delete: !isSelected && !isStartAccount,
  childWallets: isSelected,
);

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
