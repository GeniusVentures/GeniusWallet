import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GeniusBackButtonCustom extends StatefulWidget {
  final Widget? child;
  GeniusBackButtonCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _GeniusBackButtonCustomState createState() => _GeniusBackButtonCustomState();
}

class _GeniusBackButtonCustomState extends State<GeniusBackButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      },
      child: widget.child,
    );
  }
}
