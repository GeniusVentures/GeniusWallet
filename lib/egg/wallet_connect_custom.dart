import 'package:flutter/material.dart';

class WalletConnectCustom extends StatefulWidget {
  final Widget child;
  WalletConnectCustom({Key key, this.child}) : super(key: key);

  @override
  _WalletConnectCustomState createState() => _WalletConnectCustomState();
}

class _WalletConnectCustomState extends State<WalletConnectCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
