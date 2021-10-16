import 'package:flutter/material.dart';

class RecipientAddress extends StatefulWidget {
  final Widget child;
  RecipientAddress({Key key, this.child}) : super(key: key);

  @override
  _RecipientAddressState createState() => _RecipientAddressState();
}

class _RecipientAddressState extends State<RecipientAddress> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
