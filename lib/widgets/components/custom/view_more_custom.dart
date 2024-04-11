import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ViewMoreCustom extends StatefulWidget {
  final Widget? child;
  const ViewMoreCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _ViewMoreCustomState createState() => _ViewMoreCustomState();
}

class _ViewMoreCustomState extends State<ViewMoreCustom> {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        context.push('/transactions');
      },
      child: widget.child!,
    );
  }
}
