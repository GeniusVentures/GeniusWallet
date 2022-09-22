import 'package:genius_wallet/widgets/components/passcode_entry.g.dart';

import 'package:flutter/material.dart';

class PasscodeEntryCustom extends StatefulWidget {
  final Widget? child;
  PasscodeEntryCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _PasscodeEntryCustomState createState() => _PasscodeEntryCustomState();
}

class _PasscodeEntryCustomState extends State<PasscodeEntryCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child ??
        PasscodeEntry(BoxConstraints(
          maxWidth: 317.0,
          maxHeight: 50.0,
        ));
  }
}
