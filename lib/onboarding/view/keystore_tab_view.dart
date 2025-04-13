import 'package:flutter/material.dart';
import 'package:genius_wallet/onboarding/widgets/paste_field.dart';
import 'package:genius_wallet/components/text_entry_field_widget.g.dart';
import 'package:genius_wallet/components/text_form_field_logic.g.dart';

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
      additionalWidget: SizedBox(
        height: 60,
        child: LayoutBuilder(builder: (context, constraints) {
          return TextEntryFieldWidget(
            logic: TextFormFieldLogic(
              context,
              controller: passwordController,
              obscureText: true,
              hintText: 'Password',
            ),
          );
        }),
      ),
      subtitle:
          'Several lines of text beginning with “{...}” plus the password you used to encrypt it',
    );
  }
}
