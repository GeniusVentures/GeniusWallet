import 'package:flutter/material.dart';

class CryptoLogoCustom extends StatefulWidget {
  final Widget child;
  CryptoLogoCustom({Key key, this.child}) : super(key: key);

  @override
  _CryptoLogoCustomState createState() => _CryptoLogoCustomState();
}

class _CryptoLogoCustomState extends State<CryptoLogoCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
