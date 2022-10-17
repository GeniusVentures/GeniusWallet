import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/screens/pin_screen.dart';
import 'package:genius_wallet/onboarding/existing_wallet/bloc/existing_wallet_bloc.dart';

class CreatePinScreen extends StatelessWidget {
  const CreatePinScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PinScreen(
      text: 'Create PIN',
      onCompleted: (value) {
        context.read<ExistingWalletBloc>().add(PinCreated(pin: value));
      },
    );
  }
}
