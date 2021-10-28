import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/cryto_details_scroll_view_custom/cryto_details_scroll_view_custom_cubit.dart';

import 'package:geniuswallet/bloc/cryto_details_scroll_view_custom/cryto_details_scroll_view_custom_state.dart';

class CrytoDetailsScrollViewCustom extends StatefulWidget {
  final Widget child;
  CrytoDetailsScrollViewCustom({Key key, this.child}) : super(key: key);

  @override
  _CrytoDetailsScrollViewCustomState createState() =>
      _CrytoDetailsScrollViewCustomState();
}

class _CrytoDetailsScrollViewCustomState
    extends State<CrytoDetailsScrollViewCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CrytoDetailsScrollViewCustomCubit(
          CrytoDetailsScrollViewCustomInitial()),
      child: BlocBuilder<CrytoDetailsScrollViewCustomCubit,
          CrytoDetailsScrollViewCustomState>(builder: (context, state) {
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
