import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/buy/buy_cubit.dart';

import 'package:geniuswallet/bloc/buy/buy_state.dart';
import 'package:geniuswallet/screens/buy_crypto/mobile/buy_crypto_vertical.g.dart';

class Buy extends StatefulWidget {
  final Widget child;
  Buy({Key key, this.child}) : super(key: key);

  @override
  _BuyState createState() => _BuyState();
}

class _BuyState extends State<Buy> {
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
