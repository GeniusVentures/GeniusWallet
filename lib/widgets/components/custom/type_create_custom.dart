import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TypeCreateCustom extends StatefulWidget {
  final Widget? child;
  TypeCreateCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _TypeCreateCustomState createState() => _TypeCreateCustomState();
}

class _TypeCreateCustomState extends State<TypeCreateCustom> {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () => context.go('/backup_phrase'),
      child: widget.child,
    );
  }
}
