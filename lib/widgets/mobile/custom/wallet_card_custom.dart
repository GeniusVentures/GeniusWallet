import 'package:genius_wallet/widgets/mobile/wallet_card.g.dart';

import 'package:flutter/material.dart';

class WalletCardCustom extends StatefulWidget {
  final Widget? child;
  const WalletCardCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _WalletCardCustomState createState() => _WalletCardCustomState();
}

class _WalletCardCustomState extends State<WalletCardCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child ??
        const WalletCard(BoxConstraints(
          maxWidth: 311.0,
          maxHeight: 55.0,
        ));
  }
}
