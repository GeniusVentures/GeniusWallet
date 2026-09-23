import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/bloc/pin_cubit.dart';
import 'package:genius_wallet/onboarding/bloc/new_pin_cubit.dart';
import 'package:genius_wallet/onboarding/bloc/new_pin_state.dart';
import 'package:genius_wallet/screens/pin_screen.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

/// Confirms the pin entered and saves it to the user if it matches with the previous pin.
/// A mismatch keeps the user here: only this entry is cleared, the first PIN is kept.
class ConfirmAndSavePinScreen extends StatelessWidget {
  final void Function() onPassed;
  const ConfirmAndSavePinScreen({super.key, required this.onPassed});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PinCubit(
        pinMaxLength: GeniusWalletConsts.pinCount,
        geniusApi: context.read<GeniusApi>(),
      ),
      child: BlocListener<NewPinCubit, NewPinState>(
        listener: (context, state) {
          if (state.pinConfirmStatus == PinConfirmStatus.failed) {
            context.read<PinCubit>().pinConfirmFailed();
          } else if (state.pinConfirmStatus == PinConfirmStatus.passed &&
              state.pinSaveStatus == PinSaveStatus.saved) {
            onPassed();
          }
        },
        child: PinScreen(
          title: 'Confirm PIN',
          onCompleted: (value) {
            context.read<NewPinCubit>().pinConfirmSubmitted(value);
          },
        ),
      ),
    );
  }
}
