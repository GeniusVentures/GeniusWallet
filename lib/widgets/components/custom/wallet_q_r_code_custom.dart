import 'package:flutter/material.dart';

class WalletQRCodeCustom extends StatefulWidget {
  final Widget? child;
  WalletQRCodeCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _WalletQRCodeCustomState createState() => _WalletQRCodeCustomState();
}

class _WalletQRCodeCustomState extends State<WalletQRCodeCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
