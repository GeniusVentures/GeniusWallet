import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/feedback/gw_warning_note.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/send/send_cubit.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';

/// The `/send` recipient input: paste, a self-send warning, a contract
/// warning, and (where the platform supports it) a QR scan. Reads
/// [SendCubit] directly -- owns no state beyond the controller it is given,
/// which the screen keeps in step with [SendState.recipient].
class RecipientField extends StatelessWidget {
  const RecipientField({super.key, this.controller});

  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<SendCubit>();
    final state = cubit.state;
    final trimmed = state.recipient.trim();
    final invalid = trimmed.isNotEmpty && !isEvmAddress(trimmed);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GWTextField(
          controller: controller,
          label: 'To',
          hint: '0x...',
          errorText: invalid
              ? 'Enter a 0x address of 40 hex characters.'
              : null,
          onChanged: cubit.setRecipient,
          suffix: GWButton(
            label: 'Paste',
            variant: GWButtonVariant.ghost,
            size: GWButtonSize.sm,
            onPressed: () => _paste(cubit),
          ),
        ),
        if (state.selfSend) ...[
          const SizedBox(height: GeniusWalletConsts.space4),
          const GWWarningNote(
            'This is your own address. Sending here moves nothing and still '
            'costs a fee.',
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
}
