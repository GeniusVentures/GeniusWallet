import 'package:flutter/material.dart';

class BuyCryptoButtonCustom extends StatefulWidget {
  final Widget child;
  BuyCryptoButtonCustom({Key key, this.child}) : super(key: key);

  @override
  _BuyCryptoButtonCustomState createState() => _BuyCryptoButtonCustomState();
}

class _BuyCryptoButtonCustomState extends State<BuyCryptoButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
