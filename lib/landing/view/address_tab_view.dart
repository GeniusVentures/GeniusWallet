import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/text_entry_field_widget.g.dart';
import 'package:genius_wallet/widgets/text_form_field_logic.g.dart';

class AddressTabView extends StatelessWidget {
  final TextEditingController controller;
  const AddressTabView({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextEntryFieldWidget(
          logic: TextFormFieldLogic(context,
              controller: controller, hintText: 'Address'),
        ),
        const SizedBox(height: 20),
        const Text(
            'You can “watch” any public address without divulging your private key. This let’s you view balances and transactions, but not send transactions.')
      ],
    );
  }
}
