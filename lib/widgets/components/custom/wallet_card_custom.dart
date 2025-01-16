import 'package:genius_wallet/widgets/components/wallet_card.g.dart';

import 'package:flutter/material.dart';

class WalletCardCustom extends StatefulWidget {
  final Widget? child;
  WalletCardCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _WalletCardCustomState createState() => _WalletCardCustomState();
}

class _WalletCardCustomState extends State<WalletCardCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child ?? WalletCard();
  }
}
