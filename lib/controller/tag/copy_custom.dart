import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/copy_custom/copy_custom_cubit.dart';

import 'package:geniuswallet/bloc/copy_custom/copy_custom_state.dart';

class CopyCustom extends StatefulWidget {
  final Widget child;
  CopyCustom({Key key, this.child}) : super(key: key);

  @override
  _CopyCustomState createState() => _CopyCustomState();
}

class _CopyCustomState extends State<CopyCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CopyCustomCubit(CopyCustomInitial()),
      child: BlocBuilder<CopyCustomCubit, CopyCustomState>(
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
