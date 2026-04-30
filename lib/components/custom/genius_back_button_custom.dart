import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GeniusBackButtonCustom extends StatefulWidget {
  final Widget? child;
  const GeniusBackButtonCustom({
    super.key,
    this.child,
  });

  @override
  State<GeniusBackButtonCustom> createState() => _GeniusBackButtonCustomState();
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
