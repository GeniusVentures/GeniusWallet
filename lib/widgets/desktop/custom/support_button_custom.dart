import 'package:genius_wallet/widgets/desktop/support_button.g.dart';

import 'package:flutter/material.dart';

class SupportButtonCustom extends StatefulWidget {
  final Widget? child;
  const SupportButtonCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _SupportButtonCustomState createState() => _SupportButtonCustomState();
}

class _SupportButtonCustomState extends State<SupportButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child ??
        const SupportButton(BoxConstraints(
          maxWidth: 96.0,
          maxHeight: 35.0,
        ));
  }
}
