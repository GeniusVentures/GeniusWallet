import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/buy_button_custom/buy_button_custom_cubit.dart';

import 'package:geniuswallet/bloc/buy_button_custom/buy_button_custom_state.dart';

class BuyButtonCustom extends StatefulWidget {
  final Widget child;

  BuyButtonCustom({Key key, this.child}) : super(key: key);

  @override
  _BuyButtonCustomState createState() => _BuyButtonCustomState();
}

class _BuyButtonCustomState extends State<BuyButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // When the child is tapped, show a snackbar.
        onTap: () {
          const snackBar = SnackBar(content: Text('Tap'));

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
        child: BlocProvider(
          create: (_) => BuyButtonCustomCubit(BuyButtonCustomInitial()),
          child: BlocBuilder<BuyButtonCustomCubit, BuyButtonCustomState>(
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
        ));
  }
}
