import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/scan_custom/scan_custom_cubit.dart';

import 'package:geniuswallet/bloc/scan_custom/scan_custom_state.dart';

class ScanCustom extends StatefulWidget {
  final Widget child;
  ScanCustom({Key key, this.child}) : super(key: key);

  @override
  _ScanCustomState createState() => _ScanCustomState();
}

class _ScanCustomState extends State<ScanCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScanCustomCubit(ScanCustomInitial()),
      child: BlocBuilder<ScanCustomCubit, ScanCustomState>(
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
