import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/price_slider_custom/price_slider_custom_cubit.dart';

import 'package:geniuswallet/bloc/price_slider_custom/price_slider_custom_state.dart';

class PriceSliderCustom extends StatefulWidget {
  final Widget child;
  PriceSliderCustom({Key key, this.child}) : super(key: key);

  @override
  _PriceSliderCustomState createState() => _PriceSliderCustomState();
}

class _PriceSliderCustomState extends State<PriceSliderCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PriceSliderCustomCubit(PriceSliderCustomInitial()),
      child: BlocBuilder<PriceSliderCustomCubit, PriceSliderCustomState>(
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
