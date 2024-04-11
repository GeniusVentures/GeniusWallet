import 'package:flutter/material.dart';

class NavWalletButtonCustom extends StatefulWidget {
  final Widget? child;
  const NavWalletButtonCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _NavWalletButtonCustomState createState() => _NavWalletButtonCustomState();
}

class _NavWalletButtonCustomState extends State<NavWalletButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
