import 'package:flutter/material.dart';
import 'package:genius_wallet/landing/widgets/paste_field.dart';

class PhraseTabView extends StatelessWidget {
  const PhraseTabView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const PasteField(
      subtitle: 'Typically 12 (sometimes 24) words separated by single spaces.',
    );
  }
}
