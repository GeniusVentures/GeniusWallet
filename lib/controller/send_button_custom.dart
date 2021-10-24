import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/send_button_custom/send_button_custom_cubit.dart';

import 'package:geniuswallet/bloc/send_button_custom/send_button_custom_state.dart';
import 'package:geniuswallet/screens/send_crypto/mobile/send_crypto_vertical.g.dart';

class SendButtonCustom extends StatefulWidget {
  final Widget child;
  SendButtonCustom({Key key, this.child}) : super(key: key);

  @override
  _SendButtonCustomState createState() => _SendButtonCustomState();
}

class _SendButtonCustomState extends State<SendButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SendButtonCustomCubit(SendButtonCustomInitial()),
      child: BlocBuilder<SendButtonCustomCubit, SendButtonCustomState>(
          builder: (context, state) {
        return GestureDetector(
            child: widget.child,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SendCryptoVertical(),
                ),
              );
            });
      }),
    );
  }
}
