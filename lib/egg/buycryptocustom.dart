import 'package:flutter/material.dart';

class BuyCryptoCustom extends StatefulWidget {
  final Widget child;
  BuyCryptoCustom({Key key, this.child}) : super(key: key);

  @override
  _BuyCryptoCustomState createState() => _BuyCryptoCustomState();
}

class _BuyCryptoCustomState extends State<BuyCryptoCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
