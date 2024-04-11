import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/dashboard/wallets/send/cubit/send_cubit.dart';

class GeniusCloseButtonCustom extends StatefulWidget {
  final Widget? child;
  const GeniusCloseButtonCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _GeniusCloseButtonCustomState createState() =>
      _GeniusCloseButtonCustomState();
}

class _GeniusCloseButtonCustomState extends State<GeniusCloseButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        context.flow<SendState>().complete();
      },
      child: widget.child!,
    );
  }
}
