import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/price_slider/price_slider_cubit.dart';

import 'package:geniuswallet/bloc/price_slider/price_slider_state.dart';

class PriceSlider extends StatefulWidget {
  final Widget child;
  PriceSlider({Key key, this.child}) : super(key: key);

  @override
  _PriceSliderState createState() => _PriceSliderState();
}

class _PriceSliderState extends State<PriceSlider> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PriceSliderCubit(PriceSliderInitial()),
      child: BlocBuilder<PriceSliderCubit, PriceSliderState>(
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
