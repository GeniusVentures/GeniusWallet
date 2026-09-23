import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/bloc/pin_cubit.dart';
import 'package:genius_wallet/screens/pin_screen.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

class CreatePinScreen extends StatelessWidget {
  final void Function(String) onCompleted;
  const CreatePinScreen({super.key, required this.onCompleted});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PinCubit(
        pinMaxLength: GeniusWalletConsts.pinCount,
        geniusApi: context.read<GeniusApi>(),
      ),
      child: PinScreen(title: "Create a PIN", onCompleted: onCompleted),
    );
  }
}
