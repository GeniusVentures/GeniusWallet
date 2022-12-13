import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BackButtonDashboardCustom extends StatefulWidget {
  final Widget? child;
  BackButtonDashboardCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _BackButtonDashboardCustomState createState() =>
      _BackButtonDashboardCustomState();
}

class _BackButtonDashboardCustomState extends State<BackButtonDashboardCustom> {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.replace('/dashboard');
        }
      },
      child: widget.child!,
    );
  }
}
