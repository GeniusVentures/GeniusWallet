import 'package:flutter/material.dart';
import 'package:genius_wallet/onboarding/widgets/paste_field.dart';

class AddressTabView extends StatelessWidget {
  final TextEditingController controller;
  const AddressTabView({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PasteField(
      height: 150,
      hintText: 'Wallet Address',
      controller: controller,
      subtitle:
          'You can “watch” any public address without divulging your private key. This let’s you view balances and transactions, but not send transactions.',
    );
  }
}
