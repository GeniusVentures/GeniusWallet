import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/text_entry_field_widget.g.dart';

class AddressTabView extends StatelessWidget {
  const AddressTabView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextEntryFieldWidget(),
        const SizedBox(height: 20),
        const Text(
            'You can “watch” any public address without divulging your private key. This let’s you view balances and transactions, but not send transactions.')
      ],
    );
  }
}
