import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/dashboard/wallets/send/cubit/send_cubit.dart';
import 'package:genius_wallet/dashboard/wallets/send/routes/send_flow.dart';

class SendButtonCustom extends StatefulWidget {
  final Widget? child;
  SendButtonCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _SendButtonCustomState createState() => _SendButtonCustomState();
}

class _SendButtonCustomState extends State<SendButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return BlocProvider(
            create: (context) => SendCubit(),
            child: const SendFlow(),
          );
        }));
      },
      child: widget.child!,
    );
  }
}
