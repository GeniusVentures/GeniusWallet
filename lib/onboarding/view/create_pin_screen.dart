import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/bloc/pin_cubit.dart';
import 'package:genius_wallet/app/screens/pin_screen.dart';
import 'package:genius_wallet/onboarding/bloc/new_pin_cubit.dart';
import 'package:genius_wallet/onboarding/bloc/new_pin_state.dart';

class CreatePinScreen extends StatelessWidget {
  final void Function(String) onCompleted;
  const CreatePinScreen({
    Key? key,
    required this.onCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PinCubit(
        pinMaxLength: 6,
        geniusApi: context.read<GeniusApi>(),
      ),
      child: BlocListener<NewPinCubit, NewPinState>(
        listener: (context, state) {
          if (state.pinConfirmStatus == PinConfirmStatus.failed) {
            context.read<PinCubit>().pinConfirmFailed();
          }
        },
        child: PinScreen(
          text: 'Create PIN',
          onCompleted: onCompleted,
        ),
      ),
    );
  }
}
