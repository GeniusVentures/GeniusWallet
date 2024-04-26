import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/bloc/pin_cubit.dart';
import 'package:genius_wallet/app/bloc/pin_state.dart';
import 'package:genius_wallet/app/screens/pin_screen.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

/// Class that wraps [PinScreen] to verify the user's pin to perform an action
class VerifyPinScreen extends StatelessWidget {
  final void Function() onPass;
  final void Function()? onFail;

  const VerifyPinScreen({
    Key? key,
    required this.onPass,
    this.onFail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PinCubit(
        pinMaxLength: GeniusWalletConsts.pinCount,
        geniusApi: context.read<GeniusApi>(),
      ),
      child: VerifyPinView(
        onPass: onPass,
        onFail: onFail,
      ),
    );
  }
}

class VerifyPinView extends StatelessWidget {
  final void Function() onPass;
  final void Function()? onFail;
  const VerifyPinView({
    Key? key,
    required this.onPass,
    this.onFail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<PinCubit, PinState>(
      listener: verificationListener,
      child: PinScreen(
        text: 'Enter your pin',
        onCompleted: (value) {
          context.read<PinCubit>().verifyPin();
        },
      ),
    );
  }

  void verificationListener(BuildContext context, PinState state) {
    if (state.verificationStatus == VerificationStatus.pass) {
      onPass();
    } else if (onFail != null) {
      onFail!();
    }
  }
}
