import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/buy_crypto_custom/buy_crypto_custom_cubit.dart';

import 'package:geniuswallet/bloc/buy_crypto_custom/buy_crypto_custom_state.dart';

class BuyCryptoCustom extends StatefulWidget {
  final Widget child;
  BuyCryptoCustom({Key key, this.child}) : super(key: key);

  @override
  _BuyCryptoCustomState createState() => _BuyCryptoCustomState();
}

class _BuyCryptoCustomState extends State<BuyCryptoCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BuyCryptoCustomCubit(BuyCryptoCustomInitial()),
      child: BlocBuilder<BuyCryptoCustomCubit, BuyCryptoCustomState>(
          builder: (context, state) {
        /// TODO: @developer implement bloc and map the states to widgets as desired.
        /// For example, in a counter app you may have something like
        ///
        /// if(state is CounterInProgress){
        ///   return Text('${state.value}');
        /// } else {
        ///   return Text('0');
        /// }
        return widget.child;
      }),
    );
  }
}
