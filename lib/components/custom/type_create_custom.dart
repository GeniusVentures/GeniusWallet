import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TypeCreateCustom extends StatefulWidget {
  final Widget? child;
  const TypeCreateCustom({
    super.key,
    this.child,
  });

  @override
  State<TypeCreateCustom> createState() => _TypeCreateCustomState();
}

class _TypeCreateCustomState extends State<TypeCreateCustom> {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        context.push('/create_wallet');
      },
      child: widget.child,
    );
  }
}
