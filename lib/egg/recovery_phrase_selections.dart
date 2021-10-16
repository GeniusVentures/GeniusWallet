import 'package:flutter/material.dart';

class RecoveryPhraseSelections extends StatefulWidget {
  final Widget child;
  RecoveryPhraseSelections({Key key, this.child}) : super(key: key);

  @override
  _RecoveryPhraseSelectionsState createState() =>
      _RecoveryPhraseSelectionsState();
}

class _RecoveryPhraseSelectionsState extends State<RecoveryPhraseSelections> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
