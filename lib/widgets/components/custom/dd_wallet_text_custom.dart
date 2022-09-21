import 'package:flutter/material.dart';

class DdWalletTextCustom extends StatefulWidget {
  final Widget? child;
  DdWalletTextCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _DdWalletTextCustomState createState() => _DdWalletTextCustomState();
}

class _DdWalletTextCustomState extends State<DdWalletTextCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
