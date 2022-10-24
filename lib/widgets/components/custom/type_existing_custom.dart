import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TypeExistingCustom extends StatefulWidget {
  final Widget? child;
  const TypeExistingCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _TypeExistingCustomState createState() => _TypeExistingCustomState();
}

class _TypeExistingCustomState extends State<TypeExistingCustom> {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        context.push('/import_existing_wallet');
      },
      child: widget.child!,
    );
  }
}
