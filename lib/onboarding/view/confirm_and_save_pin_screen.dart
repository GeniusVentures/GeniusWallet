import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/bloc/pin_cubit.dart';
import 'package:genius_wallet/screens/pin_screen.dart';
import 'package:genius_wallet/onboarding/bloc/new_pin_cubit.dart';
import 'package:genius_wallet/onboarding/bloc/new_pin_state.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

/// Confirms the pin entered and saves it to the user if it matches with the previous pin
class ConfirmAndSavePinScreen extends StatelessWidget {
  final void Function() onFailed;
  final void Function() onPassed;
  const ConfirmAndSavePinScreen(
      {Key? key, required this.onFailed, required this.onPassed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<NewPinCubit, NewPinState>(
      listener: (context, state) {
        if (state.pinConfirmStatus == PinConfirmStatus.failed) {
          onFailed();
        } else if (state.pinConfirmStatus == PinConfirmStatus.passed &&
            state.pinSaveStatus == PinSaveStatus.saved) {
          onPassed();
        }
      },
      child: BlocProvider(
        create: (context) => PinCubit(
          pinMaxLength: GeniusWalletConsts.pinCount,
          geniusApi: context.read<GeniusApi>(),
        ),
        child: PinScreen(
          text: 'Confirm PIN',
          onCompleted: (value) {
            context.read<NewPinCubit>().pinConfirmSubmitted(value);
          },
        ),
      ),
    );
  }
}
