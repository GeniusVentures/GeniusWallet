import 'package:flutter/material.dart';
import 'package:genius_wallet/landing/widgets/paste_field.dart';

class PrivateKeyTabView extends StatelessWidget {
  const PrivateKeyTabView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const PasteField(
      subtitle: 'Typically 64 alphanumeric characters.',
    );
  }
}
