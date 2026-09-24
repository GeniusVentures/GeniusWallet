import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/feedback/gw_warning_note.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/send/send_cubit.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Whether this platform has a `mobile_scanner` camera backend -- it has
/// none on Windows or Linux, so the Scan button is hidden rather than shown
/// disabled or crashing on tap.
bool get defaultCanScanQr => !(Platform.isWindows || Platform.isLinux);

/// The payee in a scanned bare address or EIP-681 link, else null. A token
/// link's target is the token contract, so its payee is `?address=`; the
/// link's chain and amount are never read -- the form's own decide.
String? addressFromScan(String raw) {
  final s = raw.trim();
  if (isEvmAddress(s)) {
    return s;
  }
  final uri = Uri.tryParse(s);
  if (uri == null || uri.scheme != 'ethereum') {
    return null;
  }
  final match = RegExp(
    r'^(?:pay-)?(0x[0-9a-fA-F]{40})(?:@\d+)?(?:/(\w+))?$',
  ).firstMatch(uri.path);
  if (match == null) {
    return null;
  }
  final function = match.group(2);
  if (function == null) {
    return match.group(1);
  }
  if (function != 'transfer') {
    return null;
  }
  final payee = uri.queryParameters['address'];
  return payee != null && isEvmAddress(payee) ? payee : null;
}

/// The `/send` recipient input: paste, self-send and contract warnings, and a
/// QR scan where supported. Owns no state beyond the controller it is given,
/// which the screen keeps in step with [SendState.recipient].
class RecipientField extends StatelessWidget {
  RecipientField({super.key, this.controller, this.errorText, bool? canScan})
    : canScan = canScan ?? defaultCanScanQr;

  final TextEditingController? controller;

  /// The recipient's error from a failed review, shown when the field's own
  /// format check below has nothing to say about the current text.
  final String? errorText;

  final bool canScan;

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<SendCubit>();
    final state = cubit.state;
    final trimmed = state.recipient.trim();
    // Lowercase always passes the checksum, so this tells a casing typo apart
    // from a malformed address.
    final fieldError = trimmed.isEmpty || isEvmAddress(trimmed)
        ? errorText
        : isEvmAddress(trimmed.toLowerCase())
        ? "This address's capitals don't match its checksum. Check it for a "
              'typo.'
        : 'Enter a 0x address of 40 hex characters.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GWTextField(
          controller: controller,
          label: 'To',
          hint: '0x...',
          errorText: fieldError,
          onChanged: cubit.setRecipient,
          suffix: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GWButton(
                label: 'Paste',
                variant: GWButtonVariant.ghost,
                size: GWButtonSize.sm,
                onPressed: () => _paste(cubit),
              ),
              if (canScan) ...[
                const SizedBox(width: GeniusWalletConsts.space4),
                GWButton(
                  label: 'Scan',
                  variant: GWButtonVariant.ghost,
                  size: GWButtonSize.sm,
                  onPressed: () => _scan(context, cubit),
                ),
              ],
            ],
          ),
        ),
        if (state.selfSend) ...[
          const SizedBox(height: GeniusWalletConsts.space4),
          const GWWarningNote(
            'This is your own address. Sending here moves nothing and still '
            'costs a fee.',
          ),
        ] else if (state.contractRecipient) ...[
          const SizedBox(height: GeniusWalletConsts.space4),
          const GWWarningNote(
            'This address is a contract. Coins or tokens sent to a contract '
            'that cannot handle them are usually lost for good.',
          ),
        ],
      ],
    );
  }

  Future<void> _paste(SendCubit cubit) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text != null && text.isNotEmpty) {
      cubit.setRecipient(text);
    }
  }

  Future<void> _scan(BuildContext context, SendCubit cubit) async {
    final raw = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const _ScanPage()));
    final address = raw == null ? null : addressFromScan(raw);
    if (address != null) {
      cubit.setRecipient(address);
    }
  }
}

/// A full-screen camera view that pops with the first detection's raw value.
/// `onDetect` keeps firing while the camera is open, so each callback checks
/// the route is still current -- a second detection would otherwise pop twice.
class _ScanPage extends StatelessWidget {
  const _ScanPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan a QR code')),
      body: MobileScanner(
        onDetect: (capture) {
          if (!(ModalRoute.of(context)?.isCurrent ?? false)) {
            return;
          }
          final barcodes = capture.barcodes;
          final raw = barcodes.isEmpty ? null : barcodes.first.rawValue;
          if (raw != null) {
            Navigator.of(context).pop(raw);
          }
        },
      ),
    );
  }
}
