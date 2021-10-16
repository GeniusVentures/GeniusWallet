import 'package:flutter/material.dart';

class RecoveryPhraseField extends StatefulWidget {
  final Widget child;
  RecoveryPhraseField({Key key, this.child}) : super(key: key);

  @override
  _RecoveryPhraseFieldState createState() => _RecoveryPhraseFieldState();
}

class _RecoveryPhraseFieldState extends State<RecoveryPhraseField> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
