import 'package:genius_wallet/widgets/desktop/harmburger_menu.g.dart';

import 'package:flutter/material.dart';

class HarmburgerMenuCustom extends StatefulWidget {
  final Widget? child;
  HarmburgerMenuCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _HarmburgerMenuCustomState createState() => _HarmburgerMenuCustomState();
}

class _HarmburgerMenuCustomState extends State<HarmburgerMenuCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child ??
        HarmburgerMenu(BoxConstraints(
          maxWidth: 18.0,
          maxHeight: 12.0,
        ));
  }
}
