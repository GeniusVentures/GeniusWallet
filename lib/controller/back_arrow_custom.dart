import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/back_arrow_custom/back_arrow_custom_cubit.dart';

import 'package:geniuswallet/bloc/back_arrow_custom/back_arrow_custom_state.dart';

class BackArrowCustom extends StatefulWidget {
  final Widget child;
  BackArrowCustom({Key key, this.child}) : super(key: key);

  @override
  _BackArrowCustomState createState() => _BackArrowCustomState();
}

class _BackArrowCustomState extends State<BackArrowCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BackArrowCustomCubit(BackArrowCustomInitial()),
      child: BlocBuilder<BackArrowCustomCubit, BackArrowCustomState>(
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
