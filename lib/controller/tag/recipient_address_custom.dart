import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/recipient_address_custom/recipient_address_custom_cubit.dart';

import 'package:geniuswallet/bloc/recipient_address_custom/recipient_address_custom_state.dart';

class RecipientAddressCustom extends StatefulWidget {
  final Widget child;
  RecipientAddressCustom({Key key, this.child}) : super(key: key);

  @override
  _RecipientAddressCustomState createState() => _RecipientAddressCustomState();
}

class _RecipientAddressCustomState extends State<RecipientAddressCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          RecipientAddressCustomCubit(RecipientAddressCustomInitial()),
      child:
          BlocBuilder<RecipientAddressCustomCubit, RecipientAddressCustomState>(
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
