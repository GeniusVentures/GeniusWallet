import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/graph_custom/graph_custom_cubit.dart';

import 'package:geniuswallet/bloc/graph_custom/graph_custom_state.dart';

class GraphCustom extends StatefulWidget {
  final Widget child;
  GraphCustom({Key key, this.child}) : super(key: key);

  @override
  _GraphCustomState createState() => _GraphCustomState();
}

class _GraphCustomState extends State<GraphCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GraphCustomCubit(GraphCustomInitial()),
      child: BlocBuilder<GraphCustomCubit, GraphCustomState>(
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
