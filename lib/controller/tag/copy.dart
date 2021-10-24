import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/copy/copy_cubit.dart';

import 'package:geniuswallet/bloc/copy/copy_state.dart';

class Copy extends StatefulWidget {
  final Widget child;
  Copy({Key key, this.child}) : super(key: key);

  @override
  _CopyState createState() => _CopyState();
}

class _CopyState extends State<Copy> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CopyCubit(CopyInitial()),
      child: BlocBuilder<CopyCubit, CopyState>(builder: (context, state) {
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
