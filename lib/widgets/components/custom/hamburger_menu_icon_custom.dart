import 'package:flutter/material.dart';

class HamburgerMenuIconCustom extends StatefulWidget {
  final Widget? child;
  HamburgerMenuIconCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _HamburgerMenuIconCustomState createState() =>
      _HamburgerMenuIconCustomState();
}

class _HamburgerMenuIconCustomState extends State<HamburgerMenuIconCustom> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: widget.child!,
      onTap: () {
        Scaffold.of(context).openEndDrawer();
      },
    );
  }
}
