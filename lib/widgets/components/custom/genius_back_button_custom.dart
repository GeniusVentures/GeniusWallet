import 'package:genius_wallet/widgets/components/genius_back_button.g.dart';

import 'package:flutter/material.dart';

class GeniusBackButtonCustom extends StatefulWidget {
  final Widget? child;
  GeniusBackButtonCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _GeniusBackButtonCustomState createState() => _GeniusBackButtonCustomState();
}

class _GeniusBackButtonCustomState extends State<GeniusBackButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child ??
        GeniusBackButton(BoxConstraints(
          maxWidth: 5.0,
          maxHeight: 9.0,
        ));
  }
}
