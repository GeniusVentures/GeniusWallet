import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/genius_api.dart' show SDKAddOutcome;
import 'package:genius_wallet/account/add_account_secret_cubit.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/feedback/gw_warning_note.dart';
import 'package:genius_wallet/components/gw_control_track.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/components/overlays/gw_dialog.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';
import 'package:genius_wallet/utils/secret_clipboard.dart';
import 'package:genius_wallet/utils/secure_screen.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// A seed phrase leaving the app deserves a word about it. This used to be
/// `onPressed: () => {Clipboard.setData(...)}` and nothing else - no
/// confirmation, no feedback - while every other copy in the app says
/// "Address copied to clipboard". This is the one value where a silent
/// clipboard write is a security event rather than a convenience.
///
/// Public: any row carrying an SDK account reaches this from its own menu.
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

/// The recovery QR. Was the only dialog in this section still a raw
/// `AlertDialog` with a stock `TextButton`; it is `GWDialog` now.
///
/// The WHITE backdrop behind the code stays and is deliberately
/// mode-invariant: a QR needs a light quiet zone to scan, so it is not
/// routed through GWColors (03-GAP-INVENTORY §6).
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

/// The `isSelected` guard that used to live here is gone: the menu no longer
/// offers Delete on the active account at all, so a guard here could never
/// fire. The SDK's own refusal is still the real rule -- see the disabled
/// item [sdkRowActions] gates.
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
  final navigator = Navigator.of(context, rootNavigator: true);
  Navigator.of(context).pop();

  if (block == SDKDeleteBlock.defaultAccount) {
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
    title: 'Delete SDK account',
    message: linked != null
        ? 'This deletes the SDK account and removes the wallet '
              '"${linked.walletName}" from the app. If you have no copy of '
              'its recovery phrase, neither can be restored.'
        : 'The SDK will stop being able to sign with '
              '${WalletUtils.getAddressForDisplay(address)}. If you have no '
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
    removed ? 'SDK account deleted' : 'The SDK refused to delete that account.',
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
      .firstWhere((_) => true, orElse: () => null)
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

/// One dialog for both import paths: a segmented control picks mnemonic vs
/// private key, sharing one warning and one field. The bloc reports exactly
/// what happened to the pasted secret rather than assuming success.
Future<void> showAddSdkAccountDialog(BuildContext context) async {
  final bloc = context.read<AppBloc>();
  final validity = AddAccountSecretCubit(bloc.api);
  final result = await showDialog<({bool phrase, String value})>(
    context: context,
    barrierColor: context.gw.surfaceOverlay,
    builder: (_) => _AddAccountDialog(validity: validity),
  ).whenComplete(validity.close);

  if (result == null) {
    return;
  }

  final done = Completer<SDKAddOutcome>();
  bloc.add(
    result.phrase
        ? AddSDKAccountWithMnemonic(result.value, done: done)
        : AddSDKAccountWithPrivateKey(result.value, done: done),
  );
  final outcome = await done.future.timeout(
    const Duration(seconds: 60),
    onTimeout: () => SDKAddOutcome.failed,
  );

  if (!context.mounted) {
    return;
  }
  final (message, type, seconds) = switch (outcome) {
    SDKAddOutcome.added => ('Account added', ToastType.success, 1),
    SDKAddOutcome.alreadyThere => (
      'That wallet is already in the app.',
      ToastType.success,
      2,
    ),
    SDKAddOutcome.pending => (
      'Wallet saved. Its SDK account is pending and will be added once '
          'the node is running.',
      ToastType.warning,
      4,
    ),
    SDKAddOutcome.failed => (
      'That account could not be added.',
      ToastType.error,
      3,
    ),
  };
  showToast(
    context,
    message,
    type: type,
    duration: Duration(seconds: seconds),
  );
}

/// The merged add-account dialog: pick the import method, then paste.
class _AddAccountDialog extends StatefulWidget {
  const _AddAccountDialog({required this.validity});

  final AddAccountSecretCubit validity;

  @override
  State<_AddAccountDialog> createState() => _AddAccountDialogState();
}

// Owns the controller, so it is disposed when the route is gone rather than
// when `showDialog` returns -- the exit animation still rebuilds the field.
class _AddAccountDialogState extends State<_AddAccountDialog> {
  final _controller = TextEditingController();
  bool _phrase = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final phrase = _phrase;

    return BlocBuilder<AddAccountSecretCubit, bool>(
      bloc: widget.validity,
      builder: (context, valid) => GWDialog(
        title: 'Add account',
        actions: [
          GWDialogAction(
            label: 'Cancel',
            onPressed: () => Navigator.of(context).pop(),
          ),
          GWDialogAction(
            label: 'Add account',
            variant: GWButtonVariant.primary,
            onPressed: valid
                ? () => Navigator.of(
                    context,
                  ).pop((phrase: phrase, value: _controller.text.trim()))
                : null,
          ),
        ],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            GWControlTrack(
              children: [
                Expanded(
                  child: _MethodChip(
                    label: 'Recovery phrase',
                    selected: phrase,
                    onTap: () => _setMethod(phrase: true),
                  ),
                ),
                Expanded(
                  child: _MethodChip(
                    label: 'Private key',
                    selected: !phrase,
                    onTap: () => _setMethod(phrase: false),
                  ),
                ),
              ],
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
              controller: _controller,
              onChanged: (_) => _recheck(),
              label: phrase ? 'Recovery phrase' : 'Private key',
              hint: phrase
                  ? 'Paste 12 or 24 words, separated by spaces'
                  : 'Paste the Ethereum private key (hex)',
              maxLines: phrase ? 4 : 1,
              // The brand gradient on focus, not the flat `brandPrimaryStrong`
              // stroke `focusedBorder` draws -- "no flat blue as the accent" is
              // the app's rule and this is the state it matters most in.
              focusRing: true,
              // A well on the dialog's white `surfaceElevated`, like the method
              // track above it; only fields inside a `surfaceMenu` drawer need the
              // darker `surfaceSunken` to stay visible.
              fill: gw.surfaceWell,
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
      ),
    );
  }

  void _recheck() =>
      widget.validity.check(phrase: _phrase, value: _controller.text.trim());

  void _setMethod({required bool phrase}) {
    // Checked against state, not the chip's last-built `selected`, so a
    // double tap cannot clear the field twice or flip the method back.
    if (_phrase == phrase) {
      return;
    }
    // Switching method clears the field: a mnemonic left in the box while
    // the label says "Private key" is the kind of thing that gets pasted
    // into the wrong import.
    _controller.clear();
    setState(() => _phrase = phrase);
    _recheck();
  }
}

/// One option of the add-account method switch. Stays enabled when selected
/// so it keeps keyboard focus and is announced as "selected", not "disabled".
class _MethodChip extends StatelessWidget {
  const _MethodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Semantics(
      button: true,
      selected: selected,
      // Transparent Material so the ink paints above the track's well
      // instead of underneath it.
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusPill),
          onTap: onTap,
          child: Container(
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: selected ? GeniusWalletGradient.brandCta : null,
              borderRadius: BorderRadius.circular(
                GeniusWalletConsts.radiusPill,
              ),
            ),
            child: Text(
              label,
              style: GeniusWalletTypography.labelMd.copyWith(
                color: selected ? gw.textOnBrand : gw.textMutedOnSunken,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
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
