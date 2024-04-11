import 'package:genius_wallet/widgets/mobile/wallet_agreement.g.dart';

import 'package:flutter/material.dart';

class WalletAgreementCustom extends StatefulWidget {
  final Widget? child;
  const WalletAgreementCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _WalletAgreementCustomState createState() => _WalletAgreementCustomState();
}

class _WalletAgreementCustomState extends State<WalletAgreementCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child ??
        const WalletAgreement(BoxConstraints(
          maxWidth: 327.0,
          maxHeight: 34.0,
        ));
  }
}
