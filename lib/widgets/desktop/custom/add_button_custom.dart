import 'package:genius_wallet/widgets/desktop/add_button.g.dart';

import 'package:flutter/material.dart';

class AddButtonCustom extends StatefulWidget {
  final Widget? child;
  AddButtonCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _AddButtonCustomState createState() => _AddButtonCustomState();
}

class _AddButtonCustomState extends State<AddButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child ??
        AddButton(BoxConstraints(
          maxWidth: 35.0,
          maxHeight: 35.0,
        ));
  }
}
