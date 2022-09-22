import 'package:genius_wallet/widgets/components/copy_wallet_i_d.g.dart';

import 'package:flutter/material.dart';

class CopyWalletIDCustom extends StatefulWidget {
  final Widget? child;
  CopyWalletIDCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _CopyWalletIDCustomState createState() => _CopyWalletIDCustomState();
}

class _CopyWalletIDCustomState extends State<CopyWalletIDCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child ??
        CopyWalletID(BoxConstraints(
          maxWidth: 54.0,
          maxHeight: 17.0,
        ));
  }
}
