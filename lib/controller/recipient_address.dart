import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/recipient_address/recipient_address_cubit.dart';

import 'package:geniuswallet/bloc/recipient_address/recipient_address_state.dart';

class RecipientAddress extends StatefulWidget {
  final Widget child;
  RecipientAddress({Key key, this.child}) : super(key: key);

  @override
  _RecipientAddressState createState() => _RecipientAddressState();
}

class _RecipientAddressState extends State<RecipientAddress> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RecipientAddressCubit(RecipientAddressInitial()),
      child: BlocBuilder<RecipientAddressCubit, RecipientAddressState>(
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
