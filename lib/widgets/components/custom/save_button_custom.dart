import 'package:genius_wallet/widgets/components/save_button.g.dart';

import 'package:flutter/material.dart';

class SaveButtonCustom extends StatefulWidget {
  final Widget? child;
  SaveButtonCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _SaveButtonCustomState createState() => _SaveButtonCustomState();
}

class _SaveButtonCustomState extends State<SaveButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child ??
        SaveButton(BoxConstraints(
          maxWidth: 311.0,
          maxHeight: 35.0,
        ));
  }
}
