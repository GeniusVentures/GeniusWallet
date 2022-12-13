import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/bloc/pin_cubit.dart';
import 'package:genius_wallet/app/bloc/pin_state.dart';
import 'package:genius_wallet/app/screens/pin_screen.dart';
import 'package:genius_wallet/onboarding/existing_wallet/bloc/existing_wallet_bloc.dart';

class ConfirmPinScreen extends StatelessWidget {
  final String pinToConfirm;

  const ConfirmPinScreen({
    Key? key,
    required this.pinToConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<PinCubit, PinState>(
      listener: (context, state) {
        if (state.savePinStatus == SavePinStatus.success) {
          context.flow<ExistingWalletState>().complete();
        } else if (state.savePinStatus == SavePinStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Something went wrong while saving your Pin')));
        }
      },
      child: PinScreen(
        text: 'Confirm PIN',
        onCompleted: (value) {
          if (value == pinToConfirm) {
            context.read<PinCubit>().onPinCheckSuccessful();
          } else {
            context.read<ExistingWalletBloc>().add(PinCheckFailed());
            context.read<PinCubit>().pinConfirmFailed();
          }
        },
      ),
    );
  }
}
