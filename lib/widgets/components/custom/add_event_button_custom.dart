import 'package:flutter/material.dart';

class AddEventButtonCustom extends StatefulWidget {
  final Widget? child;
  AddEventButtonCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _AddEventButtonCustomState createState() => _AddEventButtonCustomState();
}

class _AddEventButtonCustomState extends State<AddEventButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
