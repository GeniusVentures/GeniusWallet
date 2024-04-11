import 'package:flutter/material.dart';

class NavWalletButton2Custom extends StatefulWidget {
  final Widget? child;
  NavWalletButton2Custom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _NavWalletButton2CustomState createState() => _NavWalletButton2CustomState();
}

class _NavWalletButton2CustomState extends State<NavWalletButton2Custom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
