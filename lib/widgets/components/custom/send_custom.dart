import 'package:flutter/material.dart';

class SendCustom extends StatefulWidget {
  final Widget? child;
  SendCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _SendCustomState createState() => _SendCustomState();
}

class _SendCustomState extends State<SendCustom> {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {},
      child: widget.child!,
    );
  }
}
