import 'package:flutter/material.dart';
import 'package:genius_wallet/onboarding/widgets/paste_field.dart';

class PhraseTabView extends StatelessWidget {
  final TextEditingController controller;
  const PhraseTabView({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PasteField(
      hintText: 'Wallet Mnemonic Phrase',
      subtitle: 'Typically 12 (sometimes 24) words separated by single spaces.',
      controller: controller,
    );
  }
}
