import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/cryto_details_scroll_view/cryto_details_scroll_view_cubit.dart';

import 'package:geniuswallet/bloc/cryto_details_scroll_view/cryto_details_scroll_view_state.dart';

class CrytoDetailsScrollView extends StatefulWidget {
  final Widget child;
  CrytoDetailsScrollView({Key key, this.child}) : super(key: key);

  @override
  _CrytoDetailsScrollViewState createState() => _CrytoDetailsScrollViewState();
}

class _CrytoDetailsScrollViewState extends State<CrytoDetailsScrollView> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CrytoDetailsScrollViewCubit(CrytoDetailsScrollViewInitial()),
      child:
          BlocBuilder<CrytoDetailsScrollViewCubit, CrytoDetailsScrollViewState>(
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
