import 'package:flutter/material.dart';

class CryptoItemCustom extends StatefulWidget {
  final Widget child;
  CryptoItemCustom({Key key, this.child}) : super(key: key);

  @override
  _CryptoItemCustomState createState() => _CryptoItemCustomState();
}

class _CryptoItemCustomState extends State<CryptoItemCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
