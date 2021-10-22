import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/link_to_data_selector_custom/link_to_data_selector_custom_cubit.dart';

import 'package:geniuswallet/bloc/link_to_data_selector_custom/link_to_data_selector_custom_state.dart';

class LinkToDataSelectorCustom extends StatefulWidget {
  final Widget child;
  LinkToDataSelectorCustom({Key key, this.child}) : super(key: key);

  @override
  _LinkToDataSelectorCustomState createState() =>
      _LinkToDataSelectorCustomState();
}

class _LinkToDataSelectorCustomState extends State<LinkToDataSelectorCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          LinkToDataSelectorCustomCubit(LinkToDataSelectorCustomInitial()),
      child: BlocBuilder<LinkToDataSelectorCustomCubit,
          LinkToDataSelectorCustomState>(builder: (context, state) {
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
