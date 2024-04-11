import 'package:genius_wallet/widgets/components/add_wallet_block.g.dart';

import 'package:flutter/material.dart';

class AddWalletBlockCustom extends StatefulWidget {
  final Widget? child;
  AddWalletBlockCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _AddWalletBlockCustomState createState() => _AddWalletBlockCustomState();
}

class _AddWalletBlockCustomState extends State<AddWalletBlockCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child ??
        AddWalletBlock(BoxConstraints(
          maxWidth: 311.0,
          maxHeight: 297.0,
        ));
  }
}
