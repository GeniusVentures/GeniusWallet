import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/price_alerts_custom/price_alerts_custom_cubit.dart';

import 'package:geniuswallet/bloc/price_alerts_custom/price_alerts_custom_state.dart';

class PriceAlertsCustom extends StatefulWidget {
  final Widget child;
  PriceAlertsCustom({Key key, this.child}) : super(key: key);

  @override
  _PriceAlertsCustomState createState() => _PriceAlertsCustomState();
}

class _PriceAlertsCustomState extends State<PriceAlertsCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PriceAlertsCustomCubit(PriceAlertsCustomInitial()),
      child: BlocBuilder<PriceAlertsCustomCubit, PriceAlertsCustomState>(
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
