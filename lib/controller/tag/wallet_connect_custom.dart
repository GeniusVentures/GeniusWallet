import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/wallet_connect_custom/wallet_connect_custom_cubit.dart';

import 'package:geniuswallet/bloc/wallet_connect_custom/wallet_connect_custom_state.dart';

class WalletConnectCustom extends StatefulWidget {
  final Widget child;
  WalletConnectCustom({Key key, this.child}) : super(key: key);

  @override
  _WalletConnectCustomState createState() => _WalletConnectCustomState();
}

class _WalletConnectCustomState extends State<WalletConnectCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WalletConnectCustomCubit(WalletConnectCustomInitial()),
      child: BlocBuilder<WalletConnectCustomCubit, WalletConnectCustomState>(
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
