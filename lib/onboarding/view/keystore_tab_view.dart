import 'package:flutter/material.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/onboarding/widgets/paste_field.dart';

class KeystoreTabView extends StatelessWidget {
  final TextEditingController pasteFieldController;
  final TextEditingController passwordController;
  const KeystoreTabView({
    Key? key,
    required this.pasteFieldController,
    required this.passwordController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PasteField(
      controller: pasteFieldController,
      hintText: 'Wallet Keystore JSON',
      additionalWidget: GWTextField(
        controller: passwordController,
        obscureText: true,
        hint: 'Password',
      ),
      subtitle:
          'Several lines of text beginning with “{...}” plus the password you used to encrypt it',
    );
  }
}
