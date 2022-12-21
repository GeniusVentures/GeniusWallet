import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/bloc/pin_cubit.dart';
import 'package:genius_wallet/app/screens/pin_screen.dart';
import 'package:genius_wallet/onboarding/bloc/new_pin_cubit.dart';

/// Confirms the pin entered and saves it to the user if it matches with the previous pin
class ConfirmAndSavePinScreen extends StatelessWidget {
  const ConfirmAndSavePinScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PinCubit(
        pinMaxLength: 6,
        geniusApi: context.read<GeniusApi>(),
      ),
      child: PinScreen(
        text: 'Confirm PIN',
        onCompleted: (value) {
          context.read<NewPinCubit>().pinConfirmSubmitted(value);
        },
      ),
    );
  }
}
