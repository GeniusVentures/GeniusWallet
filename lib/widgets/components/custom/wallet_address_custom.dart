import 'package:flutter/material.dart';

class WalletAddressCustom extends StatefulWidget {
  final Widget? child;
  WalletAddressCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _WalletAddressCustomState createState() => _WalletAddressCustomState();
}

class _WalletAddressCustomState extends State<WalletAddressCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
