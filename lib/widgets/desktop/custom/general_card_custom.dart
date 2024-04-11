import 'package:genius_wallet/widgets/desktop/general_card.g.dart';

import 'package:flutter/material.dart';

class GeneralCardCustom extends StatefulWidget {
  final Widget? child;
  const GeneralCardCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _GeneralCardCustomState createState() => _GeneralCardCustomState();
}

class _GeneralCardCustomState extends State<GeneralCardCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child ??
        const GeneralCard(BoxConstraints(
          maxWidth: 572.0,
          maxHeight: 519.0,
        ));
  }
}
