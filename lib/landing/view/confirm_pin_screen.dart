import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/bloc/pin_cubit.dart';
import 'package:genius_wallet/app/screens/pin_screen.dart';

class ConfirmPinScreen extends StatelessWidget {
  const ConfirmPinScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(context.read<PinCubit>().state.controller.text);
    return PinScreen(
      text: 'Confirm PIN',
      onCompleted: (value) {},
    );
  }
}
