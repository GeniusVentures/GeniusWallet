import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/buy_crypto_button_custom/buy_crypto_button_custom_cubit.dart';

import 'package:geniuswallet/bloc/buy_crypto_button_custom/buy_crypto_button_custom_state.dart';

class BuyCryptoButtonCustom extends StatefulWidget {
  final Widget child;
  BuyCryptoButtonCustom({Key key, this.child}) : super(key: key);

  @override
  _BuyCryptoButtonCustomState createState() => _BuyCryptoButtonCustomState();
}

class _BuyCryptoButtonCustomState extends State<BuyCryptoButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BuyCryptoButtonCustomCubit(BuyCryptoButtonCustomInitial()),
      child:
          BlocBuilder<BuyCryptoButtonCustomCubit, BuyCryptoButtonCustomState>(
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
