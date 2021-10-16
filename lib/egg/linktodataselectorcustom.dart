import 'package:flutter/material.dart';

class LinkToDataSelectorCustom extends StatefulWidget {
  final Widget child;
  LinkToDataSelectorCustom({Key key, this.child}) : super(key: key);

  @override
  _LinkToDataSelectorCustomState createState() =>
      _LinkToDataSelectorCustomState();
}

class _LinkToDataSelectorCustomState extends State<LinkToDataSelectorCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
