import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/buy/buy_cubit.dart';
import 'package:geniuswallet/bloc/buy/buy_state.dart';
import 'package:geniuswallet/bloc/buy_custom/buy_custom_cubit.dart';

import 'package:geniuswallet/bloc/buy_custom/buy_custom_state.dart';
import 'package:geniuswallet/screens/buy_crypto/mobile/buy_crypto_vertical.g.dart';

class BuyCustom extends StatefulWidget {
  final Widget child;
  BuyCustom({Key key, this.child}) : super(key: key);

  @override
  _BuyCustomState createState() => _BuyCustomState();
}

class _BuyCustomState extends State<BuyCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BuyCubit(BuyInitial()),
      child: BlocBuilder<BuyCubit, BuyState>(builder: (context, state) {
        return GestureDetector(
          child: widget.child,
          onTap: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => BuyCryptoVertical()));
          },
        );
      }),
    );
  }
}
