import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/landing/existing_wallet/bloc/existing_wallet_bloc.dart';

import 'package:flutter/material.dart';

class WalletAgreementCustom extends StatefulWidget {
  final Widget? child;
  WalletAgreementCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _WalletAgreementCustomState createState() => _WalletAgreementCustomState();
}

class _WalletAgreementCustomState extends State<WalletAgreementCustom> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
            value: context.watch<ExistingWalletBloc>().state.acceptedLegal,
            onChanged: (value) {
              context.read<ExistingWalletBloc>().add(ToggleLegal());
            }),
        const Text(
          'I’ve read and accept the Terms of Service and Privacy Policy',
        ),
      ],
    );
  }
}
