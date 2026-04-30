import 'package:flutter/material.dart';
import 'package:genius_wallet/onboarding/widgets/paste_field.dart';

class PrivateKeyTabView extends StatelessWidget {
  final TextEditingController controller;
  const PrivateKeyTabView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return PasteField(
      hintText: "Wallet Private Key",
      controller: controller,
      subtitle: 'Typically 64 alphanumeric characters.',
    );
  }
}
